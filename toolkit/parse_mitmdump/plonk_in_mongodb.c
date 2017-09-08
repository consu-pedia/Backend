#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <mongo.h>
#include <glib.h>
#define MONGO_PORT	27017 /* seems to be the default port */

static mongo_sync_connection *mongoconnect1(const char *addr, const char *db, const char *coll);
static mongo_sync_connection *mongoconnect(const char *addr_db_coll);

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
 
  mongo_sync_disconnect(conn);

  exit(0);
}
