#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <mongo.h>
#include <glib.h>
#include <glib/gstring.h>
#include "mongodatastats.h"

#define MONGO_PORT	27017 /* seems to be the default port */

#define INIT_MONGO_DB	1

static char dbname[256];
static char collname[256];
static char mongonamespace[513];

static mongo_sync_connection *mongoconnect1(const char *addr, const char *db, const char *coll);
static mongo_sync_connection *mongoconnect(const char *addr_db_coll);


/* side-effect: sets dbname, collname */
static mongo_sync_connection *mongoconnect(const char *addr_db_coll)
{
  char *addr=NULL, *db=NULL, *coll=NULL;
  char work[256], *w;
  if (addr_db_coll==NULL) return(NULL);
  
  strcpy(work, addr_db_coll);
  w = strtok(work, ":");
  if (w==NULL) return(NULL);
  addr = w;
 
  w = strtok(NULL, ":");
  if (w==NULL) return(NULL);
  db = w;
 
  w = strtok(NULL, ":");
  if (w==NULL) return(NULL);
  coll = w;

  dbname[255]='\0';
  strncpy(dbname, db, 255);
  collname[255]='\0';
  strncpy(collname, coll, 255);

  sprintf(mongonamespace, "%s.%s", dbname, collname);
  fprintf(stderr,"DBG set mongonamespace to: %s\n", mongonamespace);
 
  return(mongoconnect1(addr, db, coll));
}

static mongo_sync_connection *mongoconnect1(const char *addr, const char *db, const char *coll)
{
  mongo_sync_connection *conn = NULL;
  gchar *error = NULL;

  fprintf(stderr,"DBG mongoconnect1(addr = %s , db = %s , coll = %s )\n",addr, db, coll);
  conn = mongo_sync_connect(addr, MONGO_PORT, TRUE);

  if (conn == NULL){
    mongo_sync_cmd_get_last_error (conn /* = NULL */, db, &error);

    fprintf(stderr,"ERROR: %s : %s\n", error, strerror(errno));
  }

  return(conn);
}


/* this function should only be run once; it creates the db and
   collection.

   documentation: /usr/include/mongo-client/mongo-sync.h, look for
   mongo_sync_cmd_create()
 */
static int init_mongo_db(mongo_sync_connection *conn , const char *newdb, const char *newcoll)
{
  gint flags = 0;
  GString *db_g =NULL, *coll_g =NULL;
  gboolean res = TRUE;
  bson *seeifexists = NULL;

  seeifexists = mongo_sync_cmd_exists(conn, newdb, newcoll);
  if (seeifexists != NULL){
//    fprintf(stderr,"DB %s / coll %s exists.\n", newdb, newcoll);
    bson_free(seeifexists);
    return(res);
  }

  fprintf(stderr,"\n*** INVOKING init_mongo_db(new db %s , new coll %s ) ***\n", newdb, newcoll);
  fprintf(stderr,"DB %s / coll %s doesn't exist, creating it!\n", newdb, newcoll);

  flags = MONGO_COLLECTION_DEFAULTS;
/* from docu:
 * This command can be used to explicitly create a MongoDB collection,
 * with various parameters pre-set.
 *
 * @param conn is the connection to work with.
 * @param db is the name of the database.
 * @param coll is the name of the collection to create.
 * @param flags is a collection of flags for the collection.  Any
 * combination of MONGO_COLLECTION_DEFAULTS, MONGO_COLLECTION_CAPPED,
 * MONGO_COLLECTION_CAPPED_MAX, MONGO_COLLECTION_SIZED and
 * MONGO_COLLECTION_AUTO_INDEX_ID is acceptable.
 *
 * @tparam size @b MUST be a 64-bit integer, if
 * MONGO_COLLECTION_CAPPED or MONGO_COLLECTION_SIZED is specified, and
 * it must follow the @a flags parameter.
 * @tparam max @b MUST be a 64-bit integer, if
 * MONGO_COLLECTION_CAPPED_MAX is specified, and must follow @a size.
 *
 */
  db_g = g_string_new(newdb);
  coll_g = g_string_new(newcoll);

  res = mongo_sync_cmd_create(conn, newdb, newcoll, flags);
  fprintf(stderr,"DBG res = %d\n", res);

  /* WARNING: looking in /usr/include/glib-2.0/glib/gstring.h, it is
     not very bloody clear what the meaning of the g_string_free()'s 
     second parameter, gboolean free_segment, actually is. */
  g_string_free(db_g, TRUE);
  g_string_free(coll_g, TRUE);

  fprintf(stderr,"\n*** FINISHED init_mongo_db() ***\n");
  return(res);
}

static uint8_t *readfile(const char *fname, size_t *return_len, time_t *return_ts)
{
  uint8_t *buf = NULL;
  FILE *f = NULL;
  size_t len;
  int ok;
  struct stat statbuf;

  f=fopen(fname, "r");
  if (f==NULL) {
    fclose(f);
    return(NULL);
  }

  *return_ts = (time_t) 0;
  struct timespec tsp;
  memset(&statbuf,0x00,sizeof(struct stat));
  ok=fstat(fileno(f), &statbuf);
  if (ok==0){
    memcpy(&tsp , &statbuf.st_mtime, sizeof(struct timespec));
    /* don't care about the fraction-of-seconds bit, tv_nsec */
    *return_ts = tsp.tv_sec;
  }

  ok=fseek(f, 0L, SEEK_END);
  if(ok!=0) {
    fclose(f);
    return(NULL);
  }

  len = ftell(f);
  *return_len = len;

  rewind(f);

  buf = (uint8_t *) malloc(len);
  if (buf==NULL){
    fclose(f);
    return(NULL);
  }
  ok=fread(buf, 1, len, f);
  if (ok!=len){
    fprintf(stderr,"fread() ok=%d len=%ld\n",ok,len);
    fclose(f);
    return(NULL);
  }

  fclose(f);
  return(buf);
}


/* see /usr/include/mongo-client/bson.h for BSON AIP */
bson *make_document(uint8_t *filebuf, size_t filelen, const time_t ts, mongo_sync_connection *conn)
{
  bson *newfbson = NULL;
  int docstatus = 0x00;
  int ok;
  bson_binary_subtype subtype;
  gint32 filelen32;
  gchar *error = NULL;
  char tsstring[64];

  if (filelen >= (2LL << 32L)){
    fprintf(stderr,"INTERNAL ERROR document too long (%ld bytes), fix make_document()\n", filelen);
    return(NULL);
  }
  filelen32 = filelen;

  strftime(tsstring, 64, "%Y-%m-%dT%H:%M:%S", gmtime(&ts));

  /* So I downloaded the actual Devuan libbson source code.
     and in src/bson/bson.c and bson-types.h it said:
     see http://bsonspec.org for more information.
     bson_binary_subtype is in any case an enum
     it's the "Generic binary subtype" that should be default
     (hex 0x00), encoded in hdr file as BSON_SUBTYPE_BINARY

     N.B. in mongo-client/bson.h it has a different name !
   */
  subtype = BSON_BINARY_SUBTYPE_GENERIC;
  /* N.B. DO NOT USE BSON_BINARY_SUBTYPE_BINARY, that's obsoleted */

  /* default: unprocessed, status 0x00 */
  docstatus = MONGODATASTATUS_NEW;

  newfbson = bson_build(
               BSON_TYPE_INT32, "status", docstatus,
               BSON_TYPE_INT32, "gtin_id", 42,
               BSON_TYPE_STRING, "source", "coop", -1,
               BSON_TYPE_STRING, "timestamp", tsstring, -1,
               BSON_TYPE_INT32, "length", filelen,
               BSON_TYPE_NONE );

  if (newfbson == NULL){
    mongo_sync_cmd_get_last_error (conn, dbname, &error);
    fprintf(stderr,"make_document() ERROR: %s : %s\n", error, strerror(errno));
    return(NULL);
  }

  /* BSON_TYPE_DOCUMENT? NO; that expects a BSON array as argument.
     BSON_TYPE_BINARY? */
  /* use bson_append_xyz() */
  ok = bson_append_binary(newfbson, "content", subtype, filebuf, filelen32);
  if (ok==FALSE){
    fprintf(stderr,"ERROR bson_append_binary() FAILED\n");
    return(newfbson);
  }

  bson_finish (newfbson);
  return(newfbson);
}

int main(int argc, char *argv[])
{
  char connstring[256];
  char fname[256];
  mongo_sync_connection *conn = NULL;
  uint8_t *filebuf = NULL;
  size_t filelen = 0;
  bson *fbson = NULL;
  gchar *error = NULL;
  int ok;
  int argi;
  int nfwant, nfdone;

  if (argc<3) {
    fprintf(stderr,"Usage: plonk_in_mongodb <connection> <record file name>\n");
    exit(1);
  }

  strcpy(connstring, argv[1]);
  argi = 2;
  nfwant = 0;
  nfdone = 0;

  conn = mongoconnect(connstring);

  if (conn == NULL){
    fprintf(stderr,"Couldn't connect to DB, quitting\n");
    exit(1);
  }

  fprintf(stderr,"connected to %s !!\n", connstring);

#ifdef INIT_MONGO_DB
  init_mongo_db(conn, dbname, collname);
#endif	/* INIT_MONGO_DB */

  do {
    strcpy(fname, argv[argi]);
    argi++;
    nfwant++;

    /* ASSUMPTION: that the file containing the JSON record is not very large */
    time_t ts = (time_t) 0;
    filebuf = readfile(fname, &filelen, &ts);
    if (filebuf==NULL){
      fprintf(stderr,"ERROR reading %s: %s\n",fname, strerror(errno));
      continue;
    }

    /* plonk it in! */
    fprintf(stderr,"DBG plonk in %ld bytes %s\n", filelen, fname);

    fbson = make_document(filebuf, filelen, ts, conn);

    if (fbson == NULL){
      fprintf(stderr,"ERROR creating document of %s\n", fname);
      free(filebuf);
      continue;
    }

    // works, but prefer the other syntax ok = mongo_sync_cmd_insert(conn, fname, fbson, NULL);
    const bson *herd[1];
    int nb=0;
    herd[nb++] = fbson;


    /* IMPORTANT: second arg. of mongo_sync_cmd_insert_n() is namespace ns,
       this is NOT properly explained there in mongo-client/mongo-sync.h,
       instead look at l. 303 docu of mongo_sync_cmd_query():
       "
       * @param ns is the namespace, the database and collection name
       * concatenated, and separated with a single dot.
       "
     */

    ok = mongo_sync_cmd_insert_n(conn, mongonamespace, nb, herd);
    if (ok!=TRUE){
      mongo_sync_cmd_get_last_error (conn, dbname, &error);
      fprintf(stderr,"ERROR storing %s: %s , %s\n", fname, error, strerror(errno));
    }

    nfdone++;

    bson_free(fbson);
    free(filebuf);
  } while(argi < argc);

  fprintf(stderr,"INFO plonk_in_mongodb: processed %d / %d files.\n", nfdone, nfwant);
 
  mongo_sync_disconnect(conn);

  exit(0);
}
