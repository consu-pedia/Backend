#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <mongo.h>
#include <glib.h>
#include <glib/gstring.h>
#define MONGO_PORT	27017 /* seems to be the default port */

#define INIT_MONGO_DB	1

static char dbname[256];
static char collname[256];

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

  fprintf(stderr,"\n*** INVOKING init_mongo_db(new db %s , new coll %s ) ***\n", newdb, newcoll);

  seeifexists = mongo_sync_cmd_exists(conn, newdb, newcoll);
  if (seeifexists == NULL){
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
  } else {
    fprintf(stderr,"DB %s / coll %s exists.\n", newdb, newcoll);
    /* TODO how does one deallocate a bison? */
  }
  fprintf(stderr,"\n*** FINISHED init_mongo_db() ***\n");
  return(res);
}

int main(int argc, char *argv[])
{
  char connstring[256];
  char fname[256];
  mongo_sync_connection *conn = NULL;

  if (argc!=3) {
    fprintf(stderr,"Usage: plonk_in_mongodb <connection> <record file name>\n");
    exit(1);
  }

  strcpy(connstring, argv[1]);
  strcpy(fname, argv[2]);

  conn = mongoconnect(connstring);

  if (conn == NULL){
    fprintf(stderr,"Couldn't connect to DB, quitting\n");
    exit(1);
  }

  fprintf(stderr,"connected to %s !!\n", connstring);

#ifdef INIT_MONGO_DB
  init_mongo_db(conn, dbname, collname);
#endif	/* INIT_MONGO_DB */
 
  mongo_sync_disconnect(conn);

  exit(0);
}
