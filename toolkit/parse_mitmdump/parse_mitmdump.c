#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>

/* Quick and dirty program to parse mitmdump "HTTPFlow" output files
   Copyright © 2017 Consupedia AB
   Author: Frits Daalmans <frits@consupedia.com>
   License: not yet decided, contact the author
 */

typedef struct hdr_proto {
  size_t len;
  uint8_t *buf;
  uint8_t *value;
} hdr_t, *hdr_p;

#define CONTEXT_MAIN	 0
#define CONTEXT_RESPONSE 1
#define CONTEXT_REQUEST	 2
/* TODO suspect that metadata is also a subcontext */
#define NCONTEXT	(CONTEXT_REQUEST+1)
static char contextstring[3][20] = { "main context", "response context", "request context" };

struct whereami_proto {
  int curcontext; /* = CONTEXT_MAIN */;
  size_t entrynr;
  size_t current_request_startpos;
  size_t current_request_len;
  size_t current_request_pos;
  size_t current_response_startpos;
  size_t current_response_len;
  size_t current_response_pos;
} whereami;

void init_whereami(struct whereami_proto *w)
{
  w->curcontext = CONTEXT_MAIN;
  w->entrynr = 0;
  w->current_request_startpos = 0;
  w->current_request_len = 0;
  w->current_request_pos = 0;
  w->current_response_startpos = 0;
  w->current_response_len = 0;
  w->current_response_pos = 0;
}

#define ERRORLOG	"errors.log"

#define HTTPSTATUSDUMPNAME	"tmp.http.status.dump"
FILE *httpstatusdumpfile = NULL;
#define HTTPERRORWINDOWLEN 10
static char httperrorwindow[HTTPERRORWINDOWLEN+1];
static int httperrorcursor=0;

typedef struct lextable_proto {
  int keyidx;
#define MAXKEYWORDL	20 /* guesstimate */
  char keyword[MAXKEYWORDL];
  void *(*func)(FILE *s, const int keyidx, int *return_nextcontext);
} lextable_t, *lextable_p;

/* need some forward declarations */
void *keyw_generic_kv(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_generic_kv_part2(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_generic_list_of_kvs(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_boring_generic_list_of_kvs(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_status_code(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_response(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_request(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_content(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_headers(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_generic_kv_table(FILE *s, const int keyidx, int *return_nextcontext);
void *keyw_http_version(FILE *s, const int keyidx, int *return_nextcontext);

#define NKEYW	(KEYW_DUMMY2+1)
lextable_t lextable[] = {
#define KEYW_DUMMY	 0
  { KEYW_DUMMY, "dummy keyword", NULL}
#define KEYW_TYPE	 1
  , { KEYW_TYPE, "type", keyw_generic_kv }
#define KEYW_METADATA	 2
  , { KEYW_METADATA, "metadata", keyw_generic_kv }
#define KEYW_CLIENTCONN	 3
  , { KEYW_CLIENTCONN, "client_conn", keyw_boring_generic_list_of_kvs }
#define KEYW_SERVERCONN	 4
  , { KEYW_SERVERCONN, "server_conn", keyw_boring_generic_list_of_kvs }

/* the following are associated with a response: */
#define KEYW_MARKED	 5
  , { KEYW_MARKED, "marked", keyw_generic_kv }
#define KEYW_VERSION	 6
  , { KEYW_VERSION, "version", keyw_generic_kv }
#define KEYW_INTERCEPTED	 7
  , { KEYW_INTERCEPTED, "intercepted", keyw_generic_kv }

/* this is the most important one for data mining! */
#define KEYW_RESPONSE	 8
  , { KEYW_RESPONSE, "response", keyw_response }

/* content occurs in CONTEXT_RESPONSE */
#define KEYW_CONTENT	 9
  , { KEYW_CONTENT, "content", keyw_content }

/* headers occurs in CONTEXT_RESPONSE */
#define KEYW_HEADERS	10
  , { KEYW_HEADERS, "headers", keyw_headers }

/* timestamp_start occurs in CONTEXT_RESPONSE and CONTEXT_REQUEST */
#define KEYW_TIMESTAMP_START	11
  , { KEYW_TIMESTAMP_START, "timestamp_start", keyw_generic_kv }
/* reason occurs in CONTEXT_RESPONSE */
#define KEYW_REASON	12
  , { KEYW_REASON, "reason", keyw_generic_kv_table }
/* timestamp_end occurs in CONTEXT_RESPONSE */
#define KEYW_TIMESTAMP_END	13
  , { KEYW_TIMESTAMP_END, "timestamp_end", keyw_generic_kv }
/* status_code occurs in CONTEXT_RESPONSE but is not the last field */
#define KEYW_STATUS_CODE	14
  , { KEYW_STATUS_CODE, "status_code", keyw_status_code }

/* http_version occurs in CONTEXT_RESPONSE and is the last field */
#define KEYW_HTTP_VERSION	15
  , { KEYW_HTTP_VERSION, "http_version", keyw_http_version }

/* mode occurs in CONTEXT_REQUEST (first field) */
#define KEYW_MODE	16
  , { KEYW_MODE, "mode", keyw_generic_kv }
/* id occurs in CONTEXT_REQUEST */
#define KEYW_ID		17
  , { KEYW_ID, "id", keyw_generic_kv }
/* error occurs in CONTEXT_REQUEST */
#define KEYW_ERROR	18
  , { KEYW_ERROR, "error", keyw_generic_kv }

/* this one changes the context */
#define KEYW_REQUEST	19
  , { KEYW_REQUEST, "request", keyw_request }

/* is_replay occurs in CONTEXT_REQUEST */
#define KEYW_IS_REPLAY	20
  , { KEYW_IS_REPLAY, "is_replay", keyw_generic_kv }
/* scheme occurs in CONTEXT_REQUEST */
#define KEYW_SCHEME	21
  , { KEYW_SCHEME, "scheme", keyw_generic_kv }
/* port occurs in CONTEXT_REQUEST */
#define KEYW_PORT	22
  , { KEYW_PORT, "port", keyw_generic_kv }
/* host occurs in CONTEXT_REQUEST */
#define KEYW_HOST	23
  , { KEYW_HOST, "host", keyw_generic_kv }
/* path occurs in CONTEXT_REQUEST */
#define KEYW_PATH	24
  , { KEYW_PATH, "path", keyw_generic_kv }

/* method occurs in CONTEXT_RESPONSE */
#define KEYW_METHOD	25
  , { KEYW_METHOD, "method", keyw_generic_kv_table }

/* first_line_format occurs in CONTEXT_RESPONSE */
#define KEYW_FIRST_LINE_FORMAT	26
  , { KEYW_FIRST_LINE_FORMAT, "first_line_format", keyw_generic_kv_table }

#define KEYW_DUMMY2	27
  , { KEYW_DUMMY2, "dummy2 keyword", NULL}
};

/* not really used anymore */
char *values[NKEYW]; /* initialize as NULL */


/* to parse essential HTML headers */
#define HTMLH_DUMMY		  0
#define HTMLH_CONTENT_ENCODING	  1
#define HTMLH_CONTENT_TYPE	  2

/* this is a request header! */
#define HTMLH_COOKIE		  3
#define HTMLH_HOST		  4

#define HTMLH_DUMMY2		  5
#define NHTMLH	(HTMLH_DUMMY2+1)
typedef struct htmlhandler_proto {
  int idx;
  char keyword[64];
  /* the ctx argument is for if I really need to make it more complicated */
  void *(*func)(const int idx, void *ctx);
} htmlhandler_t, *htmlhandler_p;

void *htmlh_content_encoding(const int idx, void *ctx);
void *htmlh_content_type(const int idx, void *ctx);
void *htmlh_cookie(const int idx, void *ctx);
void *htmlh_host(const int idx, void *ctx);

htmlhandler_t htmlhandlers[NHTMLH] = {
  { HTMLH_DUMMY, "this is a dummy header", NULL }
 ,{ HTMLH_CONTENT_ENCODING, "Content-Encoding", htmlh_content_encoding }
 ,{ HTMLH_CONTENT_TYPE, "Content-Type", htmlh_content_type }

  /* request header handlers */
 ,{ HTMLH_COOKIE, "Cookie", htmlh_cookie }
 ,{ HTMLH_HOST, "Host", htmlh_host }

 ,{ HTMLH_DUMMY2, "this is another dummy header", NULL }
};


size_t beginvalue = 0; /* each stream begins with <number>: but I haven't figured out yet what it means */

void init_various(void)
{
  int v;
  for(v=0;v<NKEYW;v++) values[v]=NULL;

  httpstatusdumpfile = fopen(HTTPSTATUSDUMPNAME	, "a");
  if (httpstatusdumpfile == NULL){
    fprintf(stderr,"ERROR appending to %s (ignored)\n", HTTPSTATUSDUMPNAME);
    httpstatusdumpfile = NULL;
  } else {
    fprintf(httpstatusdumpfile, "200 inittial\n");
  }

  httperrorcursor = 0;
  for(v=0;v<HTTPERRORWINDOWLEN;v++) { httperrorwindow[v] = '2'; }
}

void exit_various(void)
{
  int v;
  for(v=0;v<NKEYW;v++) if (values[v]!=NULL) { free(values[v]); values[v]=NULL; }
}


lextable_p lexlookup(const char *keyword)
{
  int t;

  for(t=0;t<NKEYW;t++){
    if (!strcmp(keyword, lextable[t].keyword)) return(&lextable[t]);
  }

  fprintf(stderr,"lexlookup() ERROR UNDEFINED KEYWORD \"%s\"\n", keyword);
  return(NULL);
}



/* looks like: {   4:type;4:http;8:metadata;0:} */
typedef struct metadata_proto {
} metadata_t, *metadata_p;



/* expect: number followed by ':'
   curhdr must already be allocated */
int parse_hdr(FILE *s, hdr_p curhdr)
{
#define MAXHDRLEN	256
  char numbuf[MAXHDRLEN+1+1];
  int i,c,quit,ok;

  memset(numbuf,0x00,MAXHDRLEN+1+1);

  quit=0;
  for(i=0;i<MAXHDRLEN && quit==0;i++){
    c = fgetc(s);
    if (feof(s)) return(1);
    switch(c){
      case '0' ... '9':
        numbuf[i] = c;
//DBG        fprintf(stderr,"<%c>",c);
        break;

      case ':': /* normal termination, now parse */
        quit=1;
        break;
      default:
        /* syntax error */
        return(1);
        break;
    }
  }

  if (!quit) return(1); // number larger than MAXHDRLEN sounds like a hack attempt
  size_t len;
  ok=sscanf(numbuf, "%ld", &len);
  if (ok!=1){
     fprintf(stderr,"parse_hdr(): ERROR parsing <%s>\n",numbuf);
     return(1);
  }
  curhdr->len = len;
//DBG  fprintf(stderr,"parse_hdr(): len = %ld\n",len);

  return(0);
}

int read_entry(FILE *s, hdr_p curhdr)
{
#define MYREADBUF	4096
  size_t toread, got, gotchunk, toreadnow;
  uint8_t *readbuf = NULL, *readp;

  toread = curhdr->len;
  got = 0;
  readbuf = malloc(toread+1 /* just in case it's a string */);
  /* side-effect: if len = 0 it returns an empty string length 1 nul-terminated, instead of NULL */
  if (readbuf==NULL){
    fprintf(stderr,"OUT OF MEMORY allocating %ld read buf\n",toread);
    return(1);
  }
  readbuf[toread] = '\0'; // not technically necessary but saves errors
  readp = &readbuf[0];

  if ( toread > MYREADBUF) {
    toreadnow = ( toread / MYREADBUF );
    gotchunk = fread(readp, MYREADBUF, toreadnow, s);
    if ((gotchunk != toreadnow) || ( feof(s))){
      fprintf(stderr,"read_entry(%ld bytes) ERROR: only got %ld / %ld chunks = %ld bytes\n", toread, gotchunk, toreadnow, gotchunk * MYREADBUF);
      free(readbuf);
      return(1);
    }
    readp += toreadnow * MYREADBUF;
    toread -= toreadnow * MYREADBUF;
  }

  /* and read the last block */
  if (toread>0){
    got = fread(readp, 1, toread, s);
    if (got != toread){
        fprintf(stderr,"read_entry(%ld bytes) ERROR: only got %ld / %ld bytes (last chunk)\n", toread, got, toread);
        free(readbuf);
        return(1);
    }
  }

  if (curhdr->buf != NULL) { free(curhdr->buf); curhdr->buf=NULL; }
  curhdr->buf = readbuf;

  return(0);
}

int dump_entry(const int ctxt, const hdr_p curhdr, const size_t e)
{
  char outfname[256];
  FILE *outf;

  switch(ctxt){
    case CONTEXT_MAIN:
      sprintf(outfname,"entry.%06ld", e);
      break;

    case CONTEXT_RESPONSE:
      sprintf(outfname,"rawres.%06ld", e);
      break;

    case CONTEXT_REQUEST:
      sprintf(outfname,"req.%06ld", e);
      break;

    default:
      fprintf(stderr,"dump_entry() INTERNAL ERROR UMIMPLEMENTED ctxt = %d %s\n", ctxt, contextstring[ctxt]);
      exit(1);
      break;
  }
  outf=fopen(outfname,"w");
  if (outf==NULL){
    fprintf(stderr,"dump_entry(%s): ERROR writing: %s\n", outfname, strerror(errno));
    return(1);
  }

  fprintf(stderr,"DBG dump % 8ld bytes to %s\n", curhdr->len, outfname);
  fwrite(curhdr->buf, curhdr->len, 1, outf);
  fclose(outf);

  return(0);
}

/* reads mitmdump dumpfile as a stream (raw I/O) */
int parse_mitmdump(FILE *s)
{
  int ok;
  hdr_t curhdr;

  fprintf(stderr,"parse_mitmdump: DBG now @ byte %ld\n", ftell(s));

  memset(&curhdr, 0x00, sizeof(curhdr));
   
  ok = parse_hdr(s, &curhdr);
  if (ok!=0) return(ok);

  ok = read_entry(s, &curhdr);
  if (ok!=0) return(ok);

  ok = dump_entry(CONTEXT_MAIN, &curhdr, whereami.entrynr);
  if (ok!=0) return(ok);
  whereami.entrynr++;
  
  return(0);
}

size_t parse_begin(FILE *s)
{
  char beginhdr[16+1];
  int i;
  size_t j;
  
  memset(&beginhdr[0], 0x00, 16);

  for (i=0; i < 16 && !feof(s) && beginhdr[i]!=':'; i++){
    beginhdr[i] = fgetc(s);
    if (feof(s)) break;
    
    switch(beginhdr[i]){
      case '0' ... '9': break;

      case ':': beginhdr[i] = '\0'; i=16; break;

      default:
        beginhdr[i+1]='\0';
        fprintf(stderr,"parse_begin() SYNTAX ERROR \"%s\"\n",beginhdr);
        return(-1);
        break;
    }
  }
  beginhdr[16]='\0';
  if (feof(s)) return(-1);

  if (sscanf(beginhdr, "%ld", &j) != 1){
    fprintf(stderr,"parse_begin(\"%s\"): parse error\n", beginhdr);
    return(-1);
  }

  fprintf(stderr,"parse_begin() got value %ld (unsure what it means)\n", j);
  beginvalue = j;
  return(beginvalue);
}

static int stupid_parse_mitmdump_metadata(FILE *s, metadata_p metap)
{
#define DEFAULTMETASTRING "4:type;4:http;8:metadata;0:}"
#define DEFAULTMETASTRINGL strlen(DEFAULTMETASTRING)
  char metastring[DEFAULTMETASTRINGL+1];
  int ok;
  metastring[DEFAULTMETASTRINGL]='\0';
  ok=fread(metastring, 1, DEFAULTMETASTRINGL, s);
  if ((ok!=DEFAULTMETASTRINGL)||(feof(s))|| (strcmp(metastring, DEFAULTMETASTRING)) ){
    fprintf(stderr,"parse_mitmdump: TODO ERROR UNIMPL metadata string starts with %s\n",metastring);
    return(1);
  }
  fprintf(stderr,"parse_mitmdump: metadata looks standard, now @ byte %ld\n", ftell(s));
  
  return(0);
}

int parse_mitmdump_metadata(FILE *s, metadata_p metap)
{
  int ok;
  /* the file-level header is expected to have:
     - 4:type;
     - 4:http;
     - 8:metadata;
     - 0:
   { - }  yes, there's no open-bracket to match that

   format looks like a sequence of <length>":"<value> terminated by "0:"

   */
  ok = stupid_parse_mitmdump_metadata(s, metap);
  return(ok);
}

/* this one doesnt look relevant */
int parse_clientconn(FILE *s, void *dummy)
{
  hdr_t cchdr;
  int ok;
#define CLIENTCONN	"client_conn"
  char clientconn[strlen(CLIENTCONN)+1];

  fprintf(stderr,"parse_clientconn() STUB @ byte %ld\n", ftell(stdin));

  /* expect: 11:client_conn:<length><lots of crap tilde separated> */
  memset(&cchdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s,&cchdr);
  if(ok!=0)return(ok);
  if (cchdr.len != 11) {return(-1);}
  clientconn[strlen(CLIENTCONN)]='\0';
  ok=fread(clientconn, 1, strlen(CLIENTCONN), s);
  if ((ok!=strlen(CLIENTCONN))||feof(s)||(strcmp(clientconn,CLIENTCONN))) {
    fprintf(stderr,"parse_clientconn() ERROR: got \"%s\"\n",clientconn);
    return(1);
  }

  /* followed by ; */
  ok = fgetc(s);
  if (feof(s)) return(-1);
  if (ok!= ';'){
    fprintf(stderr,"parse_clientconn(\"%s%c\"): parse error\n", clientconn, ok);
  }

  memset(&cchdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s,&cchdr);
  if (ok!=0){
    return(1);
  }
  ok = read_entry(s, &cchdr);
  fprintf(stderr,"successfully parsed client_conn entry %s, now @ byte %ld\n", cchdr.buf, ftell(s));
  
  return(0);
}

int parse_1_char(FILE *s, int expectc)
{
  int c;
  c = fgetc(s);
  if (feof(s)) return(-1);
  if (c!= expectc){
    fprintf(stderr,"parse_1_char(\"%c\" != \"%c\"): parse error\n", c, expectc);
    return(1);
  }
  return(0);
}

/* this one doesnt look relevant */
int parse_serverconn(FILE *s, void *dummy)
{
  hdr_t cchdr;
  int ok;
#define SERVERCONN	"server_conn"
  char serverconn[strlen(SERVERCONN)+1];

  fprintf(stderr,"parse_serverconn() STUB @ byte %ld\n", ftell(stdin));

  /* expect: 11:server_conn:<length><lots of crap tilde separated> */
  memset(&cchdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s,&cchdr);
  if(ok!=0)return(ok);
  if (cchdr.len != 11) {return(-1);}
  serverconn[strlen(SERVERCONN)]='\0';
  ok=fread(serverconn, 1, strlen(SERVERCONN), s);
  if ((ok!=strlen(SERVERCONN))||feof(s)||(strcmp(serverconn,SERVERCONN))) {
    fprintf(stderr,"parse_serverconn() ERROR: got \"%s\"\n",serverconn);
    return(1);
  }

  /* followed by ; */
  ok = fgetc(s);
  if (feof(s)) return(-1);
  if (ok!= ';'){
    fprintf(stderr,"parse_serverconn(\"%s%c\"): parse error\n", serverconn,ok);
  }

  memset(&cchdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s,&cchdr);
  if (ok!=0){
    return(1);
  }
  ok = read_entry(s, &cchdr);
  fprintf(stderr,"successfully parsed server_conn entry %s, now @ byte %ld\n", cchdr.buf, ftell(s));
  
  return(0);
}

/* memory management: fill in and recycle the strings in kvset
   TODO: it looks like kv lists are terminated with a ~ character
 */
int parse_kv(FILE *s, int nkv, hdr_t **kvset)
{
  hdr_t khdr, vhdr;
  int ok;
  int k;
  int res;
  hdr_p kv = NULL;

  memset(&khdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s, &khdr);
  if (ok!=0){
    return(1);
  }
  ok = read_entry(s, &khdr);
  if (ok!=0){
    return(1);
  }
  fprintf(stderr,"\nkey =	%s	", khdr.buf);

  for(k=0;k<nkv;k++){
    if (!strcmp((char *)khdr.buf, (char *)kvset[k]->buf)) break;
  }

  res=0;
  if (k>=nkv){
    fprintf(stderr,"ERROR key %s not found\n", khdr.buf);
    res=1;
  }

  /* unsure what the meaning of this character is
     looks like the keys end with a 0x3b ; */
  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n"); 
  }

  /* read the value regardless! */
  memset(&vhdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s, &vhdr);
  if (ok!=0){
    free(khdr.buf);
    return(1);
  }

  if (vhdr.len==0){ 
    fprintf(stderr,"TODO corner case length of value = 0, e.g. 5:error;0:\n");
    vhdr.buf = malloc(1);
    vhdr.buf[0] = '\0';
  } else {
    ok = read_entry(s, &vhdr);
    if (ok!=0){
      free(khdr.buf);
      return(1);
    }
    if (res==0) {
      fprintf(stderr,"value =	%s\n", vhdr.buf);
    } else {
      free(khdr.buf);
      free(vhdr.buf);
      return(1);
    }
  }

  /* now replace the strings in kvset */
  if (res == 0){
    kv = kvset[k];   

    /* already have this pre-filled-in */
    free(khdr.buf);
    khdr.buf = NULL;

    /* the values are fresh every time */
    if (kv->value != NULL) {
      free(kv->value);
      kv->value=NULL;
    }
    kv->value = vhdr.buf;
    vhdr.buf = NULL;
  }
  
  return(res);
}

static hdr_t **marked_kvset = NULL;
static hdr_t **mode_kvset = NULL;

static int init_kvset1(hdr_p *kvp, const char *text)
{
  hdr_p kv = (hdr_t *) malloc(sizeof(hdr_t));
  if(kv==NULL) return(1);
  *kvp = kv;
  memset(kv, 0x00, sizeof(hdr_t));
  kv->buf = (uint8_t *) strdup(text);
  return(0);
}

int init_kvsets(void)
{
  int nkv=0;
#define N_KV_MARKED	 3
#define N_KV_MODE	 3
  if (marked_kvset==NULL){
    marked_kvset = (hdr_t **) malloc(N_KV_MARKED*sizeof(hdr_t *));
    if(marked_kvset==NULL) return(1);
    memset(marked_kvset, 0x00, N_KV_MARKED*sizeof(hdr_t *));

    nkv = 0;
    if (init_kvset1(&marked_kvset[nkv++], "marked")) return(1);
    if (init_kvset1(&marked_kvset[nkv++], "version")) return(1);
    if (init_kvset1(&marked_kvset[nkv++], "intercepted")) return(1);

    if (nkv != N_KV_MARKED){
      fprintf(stderr,"init_kvsets() INTERNAL ERROR mismatch nkv=%d instead of %d for marked_kvset\n",nkv, N_KV_MARKED);
      return(1);
    }
  }

  /* {mode, id, error } */
  if (mode_kvset==NULL){
    mode_kvset = (hdr_t **) malloc(N_KV_MODE*sizeof(hdr_t *));
    if(mode_kvset==NULL) return(1);
    memset(mode_kvset, 0x00, N_KV_MODE*sizeof(hdr_t *));

    nkv = 0;
    if (init_kvset1(&mode_kvset[nkv++], "mode")) return(1);
    if (init_kvset1(&mode_kvset[nkv++], "id")) return(1);
    if (init_kvset1(&mode_kvset[nkv++], "error")) return(1);

    if (nkv != N_KV_MODE){
      fprintf(stderr,"init_kvsets() INTERNAL ERROR mismatch nkv=%d instead of %d for mode_kvset\n",nkv, N_KV_MODE);
      return(1);
    }
  }

  return(0);
}

#if 0
/* this one doesnt look relevant for now (fields marked, version, intercepted, response and their values */
int parse_marked(FILE *s, void *dummy)
{
  int ok;

  if (marked_kvset==NULL){
    ok=init_kvsets();
    if (ok!=0) {
      fprintf(stderr,"OUT OF MEMORY\n");
      return(1);
    }
  }
  
  fprintf(stderr,"parse_marked() STUB @ byte %ld\n", ftell(stdin));


  /* keep the values in marked_kvset for now */
  
  return(0);
}
#endif

int parse_list_generic(FILE *s, int nkv, hdr_t **kvset)
{
  int ok, peekchar;

  if (kvset==NULL){
    fprintf(stderr,"parse_list_generic() INTERNAL ERROR: argument kvset = NULL\n");
    exit(1);
  }

  fprintf(stderr,"parse_list_generic() STUB @ byte %ld\n", ftell(s));

  ok = 0;
  do {
    peekchar = fgetc(s);
  
    switch(peekchar){
      case '0' ... '9': /* first byte of numeric length, normal entry */
        ungetc(peekchar, s);
        ok = parse_kv(s, nkv, kvset);
        if (ok!=0) {
          return(1);
        }
        break;
  
      default:
        fprintf(stderr,"UNDEFD peekchar %c %02x in parse_list_generic()\n",peekchar,peekchar);
        exit(1);
        break;
    }


    /* *AFTER* reading the k = v (could be EOF) */
    peekchar = fgetc(s);
    if (feof(s)) {
      fprintf(stderr,"got an EOF suddenly\n");
      return(1);
    }

//DONT    ungetc(peekchar, s);

  /* unsure what the meaning of this character is
     looks like the values end with a 0x21 ! (boolean??)
     or with a 0x23 #
 */
    switch(peekchar){
      case '!': /* 0x21, boolean value? */
        break;
      case '#': /* 0x23, type of the value of "version", number or string? */
        break;
      case ';': /* 0x3b, type of the value of "vid", string? */
        break;

      case '~': /* 0x7e, looks like empty value or termination */
        fprintf(stderr,"DBG assuming ~ means termination, return 1\n");
        ok=1;
        break;

      default:
        fprintf(stderr,"INFO: interesting character %c 0x%02x @ %ld after kv pair\n", peekchar, peekchar, ftell(s));
        break;
    }
  } while(ok==0);


  /* keep the values in kvset for now */

  return(0);
}

/* this one doesnt look relevant for now (fields marked, version, intercepted, response and their values */
int parse_marked(FILE *s, void *dummy)
{
  int ok;
  int f, nfields;
  int peekchar;

  ok=init_kvsets();
  if (ok!=0) {
    fprintf(stderr,"OUT OF MEMORY\n");
    return(1);
  }

  /* parse_list_generic() DOESNT WORK; "response" is coming straight after ! */
  // ok = parse_list_generic(s, N_KV_MARKED, marked_kvset);

  /* HACK assume it's only these first 3 fields */
  nfields = N_KV_MARKED;
  for(f=0;f<nfields;f++){
    ok = parse_kv(s, N_KV_MARKED, marked_kvset);
    if (ok!=0) {
      return(1); 
    }
    /* *AFTER* reading the k = v (could be EOF) */
    peekchar = fgetc(s);
    if (feof(s)) {
      fprintf(stderr,"got an EOF suddenly\n");
      return(1);
    }

//DONT    ungetc(peekchar, s);

  /* unsure what the meaning of this character is
     looks like the values end with a 0x21 ! (boolean??)
     or with a 0x23 #
 */
    switch(peekchar){
      case '!': /* 0x21, boolean value? */
        fprintf(stderr,"DBG field type probably bool\n");
        break;
      case '#': /* 0x23, type of the value of "version", number or string? */
        fprintf(stderr,"DBG field type probably int\n");
        break;
      default:
        fprintf(stderr,"INFO: interesting character %c 0x%02x @ %ld after kv pair\n", peekchar, peekchar, ftell(s));
        break;
    }
  } /* next field f */

  return(ok);
}

/* this one doesnt look relevant for now (fields mode, id, error and their values */
int parse_mode(FILE *s, void *dummy)
{
  int ok;
  ok=init_kvsets();
  if (ok!=0) {
    fprintf(stderr,"OUT OF MEMORY\n");
    return(1);
  }
  /* parse_list_generic() DOESNT WORK; "request" is coming straight after ! */
  ok = parse_list_generic(s, N_KV_MODE, mode_kvset);
  return(ok);
}

/* not really good function name; it's for the headers of the
   "big chunks".
   return value: */
int parse_response_header(FILE *s)
{
  hdr_t cchdr;
  int ok;
#define TYPE_RESPONSE	 1
#define TYPE_MODE	 2
#define TYPE_REQUEST	 3
#define TYPE_REQUEST_DONE	 4	/* HACK !!! */

  memset(&cchdr,0x00,sizeof(hdr_t));
  ok=parse_hdr(s,&cchdr);
  if(ok!=0)return(-1);

  ok=read_entry(s,&cchdr);
  if(ok!=0)return(-1);

  fprintf(stderr,"response header: %s\n", cchdr.buf);

  if (!strcmp((char *)cchdr.buf, "response")){
    return(TYPE_RESPONSE);
  }
  if (!strcmp((char *)cchdr.buf, "mode")){
    return(TYPE_MODE);
  }
  if (!strcmp((char *)cchdr.buf, "request")){
    return(TYPE_REQUEST);
  }
  fprintf(stderr,"parse_response_header @ %ld: ERROR UNKNOWN header type \"%s\"\n",ftell(s), cchdr.buf);
  return(-1);
}

int parse_content(FILE *s, const char *entryfilename, size_t entrylen)
{
  char tmps[11+1];
  hdr_t chdr;
  int ok;
  size_t contentlen, nbread, chunksize, nchunks;
  char contentfname[256];
  FILE *contentfile;
  uint8_t *filebuf=NULL;

  fprintf(stderr,"\nparse_content(%s, %ld)\n",entryfilename, entrylen);
  if (!fgets(tmps, 11, s)){
    return(1);
  }
  tmps[11]='\0';
  if (strcmp(tmps, "7:content;")) {
fprintf(stderr,"oops %s \n",tmps);
    return(1);
  }

  memset(&chdr,0x00,sizeof(hdr_t));
  ok = parse_hdr(s, &chdr);
  if (ok) return(1);

  contentlen = chdr.len;
  fprintf(stderr,"content length = %ld bytes\n",contentlen);

  sprintf(contentfname,"c.%s.raw", entryfilename);
  /* content begins immediately now */

  contentfile = fopen(contentfname,"w");
  if (contentfile == NULL){
    fprintf(stderr,"ERROR dumping %s: %s\n",contentfname, strerror(errno));
    return(1);
  }

  /* TODO chunking so it fits in-core for > 1Gb files */
  chunksize=contentlen;
  nchunks=1;

  filebuf = malloc(chunksize);
  if (filebuf==NULL){
    fprintf(stderr,"ERROR dumping %s: out of memory allocating buffer size %ld, TODO implement chunking\n",contentfname, contentlen);
    return(1);
  }
  memset(filebuf,0x00,chunksize);

  nbread = fread(filebuf, chunksize, nchunks, s);
  if (nbread!=nchunks){
    fprintf(stderr,"ERROR dumping %s: truncated file, only %ld of %ld\n",contentfname, nbread*chunksize, contentlen);
    /* ignore this error */
  }
  nbread = fwrite(filebuf, chunksize, nbread, contentfile);
  free(filebuf);

  fclose(contentfile);
  return(0);
}

int parse_request(FILE *s, const char *entryfilename, size_t entrylen)
{
  fprintf(stderr,"parse_request() TODO UNIMPL STUB\n");
  return(0);
}

/* the file is opened and positioned at the beginning of the headers */
int parse_headers(FILE *s, const char *entryfilename, size_t entrylen)
{
  fprintf(stderr,"parse_headers(%s, @ %ld / %ld): UNIMPLEMENTED STUB\n", entryfilename, ftell(s), entrylen);
  return(0);
}

int dump_request_header(const size_t relevant_entrynr, const int delete_values_after_use);

/* exit from subcontext, or die trying.
   side-effect: modify whereami.curcontext */
int do_context_switch(FILE *s)
{
  size_t pos = ftell(s);
  int nextcontext;
  switch(whereami.curcontext){
    case CONTEXT_REQUEST:
      nextcontext = CONTEXT_MAIN;
      break;

    case CONTEXT_RESPONSE:
      nextcontext = CONTEXT_MAIN;
      break;

    case CONTEXT_MAIN:
      fprintf(stderr,"\nWARNING do_context_switch(main->main) shouldnt happen I think\n");
      nextcontext = CONTEXT_MAIN;
      break;

    default:
      fprintf(stderr,"\ndo_context_switch(@ %ld) FAILED: no escape from context %d %s\n\n", pos, whereami.curcontext, contextstring[whereami.curcontext]);
      return(1);
      break;
  }

  /* HACK if the context is a request, dump the request method etc. */
  if (whereami.curcontext == CONTEXT_REQUEST) {
    int relevant_entrynr = whereami.entrynr - 1;
    int delete_values_after_use = 1;
    dump_request_header(relevant_entrynr, delete_values_after_use);
    /* TODO: how to ensure that the values are fresh? maybe just delete them now */
  }

  fprintf(stderr,"\ndo_context_switch(%s -> %s)\n", contextstring[whereami.curcontext], contextstring[nextcontext]);
  /* TODO byte count of subcontext etc. */
  whereami.curcontext = nextcontext;

  return(0);
}


/* the input flow is split up in chunks, syntax:
 { <several digits number>:<flow chunk>}
 */
int flowloop(FILE *s)
{
  int nextchar = '?';
  int quitinner=0;
  int ok;
  hdr_t curhdr;
  char *keyword = NULL;
  lextable_p lexkey = NULL;
  int nextcontext;

    /* inner M A I N   L O O P */
    quitinner=0;

    do {
    /* the rest is context-dependent */
    nextchar=fgetc(s);
    if (feof(s)){
      fprintf(stderr,"unexpected outer-loop EOF after fourcc @ %ld\n", ftell(s));
      return(1);
    }

    switch(nextchar){
      case '0' ... '9':
        /* most common case: <number>:<keyword> */
        ungetc(nextchar, s);
        break;

      /* { */ case '}':
        ok = do_context_switch(s);
        if (ok != 0) return(1);
        break;

      default:
        fprintf(stderr,"UNIMPLEMENTED begincode 0x%02x %c @ %ld in outer loop\n", nextchar,nextchar,ftell(s));
        quitinner=1;
        break;
    }

    if(quitinner)return(0);

    /* expect <size>:<keyword> */
    memset(&curhdr,0x00, sizeof(hdr_t));
    ok = parse_hdr(s, &curhdr);
    if (ok!=0) break;
    ok = read_entry(s, &curhdr);
    if (ok!=0) break;
 
    keyword = (char *)curhdr.buf; /* don't forget to deallocate */
    curhdr.buf = NULL;

    fprintf(stderr,"keyword = %ld:%s\n", curhdr.len, keyword);

    lexkey = lexlookup(keyword);
    if (lexkey == NULL){
      fprintf(stderr,"wrong keyword %s, stopping @@ %ld\n", keyword, ftell(s));
      return(1);
    }

    /* assert(lexkey->keyword); */
    free(keyword);
    keyword = NULL;

    if (lexkey->func == NULL){
      fprintf(stderr,"INTERNAL ERROR: no handler for keyword \"%s\" (ignored)\n", lexkey->keyword);
    } else {
      nextcontext = whereami.curcontext;
      lexkey->func(s, lexkey->keyidx, &nextcontext);

      fprintf(stderr,"DBG finished parsing %s @ %ld\n", lexkey->keyword, ftell(s));
      if (nextcontext != whereami.curcontext){
        fprintf(stderr,"DBG switch context from %d %s to %d %s\n", whereami.curcontext,contextstring[whereami.curcontext],nextcontext,contextstring[nextcontext]);
        whereami.curcontext = nextcontext;
      }
    }
    
      if(quitinner)return(0);
    } while(1); // outer loop
    fprintf(stderr,"\nDBG end of inner loop @ byte %ld, context = %s\n\n", ftell(s), contextstring[whereami.curcontext]);

  return(0);
}


int main(int argc, char *argv[])
{
  FILE *s = stdin;
  int ok;
  int quit=0;
  size_t nbrw, nbt;
  size_t bvl;
  uint8_t *workbuf = NULL;

  workbuf = malloc(4096+1);
  if (workbuf==NULL) exit(1);
  memset(workbuf,0x00, 4096+1);

  setvbuf(s, NULL, _IONBF, 0);
  memset(&whereami, 0x00, sizeof(struct whereami_proto));
  init_whereami(&whereami);
  whereami.entrynr = 0; // TODO optional begin with a selected entry nr
  init_various();

  /* outer M A I N   L O O P */
  quit=0;
  do {
    /* parse file-level header */
    bvl = ftell(s);
    beginvalue = parse_begin(s);

    if (feof(s)) break;
  
    if (beginvalue == -1){
      fprintf(stderr,"SYNTAX ERROR @ %ld (outer main loop)\n",ftell(s));
      break;
    }
    bvl = ftell(s) - bvl; /* this includes the : that terminates the number */
  
    fprintf(stderr,"DBG first bytes (outer loop): %ld, hdr length: %ld\n", beginvalue, bvl);

    /* dump to tmp.curflow and then read back
       disadvantage: double as much I/O
       advantage: can see current flow if/when things crash
     */
    FILE *flowfile = fopen("tmp.curflow", "w");
    if (flowfile == NULL) {
      fprintf(stderr,"ERROR writing to tmp.curflow: %s\n", strerror(errno));
      exit(1);
    }

    nbt = beginvalue + 1 /* terminating close brace */;
    while ( nbt >= 4096 ) {
      nbrw = fread(workbuf, 4096, 1, s);
      if ((nbrw!=1)||(feof(s))){
        fprintf(stderr,"ERROR premature EOF reading in %ld bytes flow\n", beginvalue + bvl);
        quit=1;
        break;
      }

      nbrw = fwrite(workbuf, 4096, 1, flowfile);
      if ((nbrw!=1)||(feof(flowfile))){
        fprintf(stderr,"ERROR premature EOF writing out %ld bytes flow\n", beginvalue + bvl);
        quit=1;
        break;
      }

      nbt -= 4096;
    }

    if (nbt > 0) {
      nbrw = fread(workbuf, nbt, 1, s);
      if ((nbrw!=1)||(feof(s))){
        fprintf(stderr,"ERROR premature EOF reading in %ld bytes flow\n", beginvalue + bvl);
        quit=1;
        break;
      }

      nbrw = fwrite(workbuf, nbt, 1, flowfile);
      if ((nbrw!=1)||(feof(flowfile))){
        fprintf(stderr,"ERROR premature EOF writing out %ld bytes flow\n", beginvalue + bvl);
        quit=1;
        break;
      }
    }

    fclose(flowfile);

    if (quit) break;

    /* OK the flow file (exactly 1 flow) is written and
       can be re-read until EOF */

    /* re-open */
    flowfile = fopen("tmp.curflow", "r");
    if (flowfile == NULL) {
      fprintf(stderr,"ERROR reading tmp.curflow: %s\n", strerror(errno));
      exit(1);
    }

    ok = flowloop(flowfile);

    fclose(flowfile);

    if (ok!=0) quit=1;

  } while(quit==0);


  fprintf(stderr,"\nDBG end of outer loop @ byte %ld, context = %s\n\n", ftell(s), contextstring[whereami.curcontext]);

  exit_various();

  free(workbuf);

  exit(0);
}

void *keyw_generic_kv(FILE *s, const int keyidx, int *return_nextcontext)
{
  char *value;
  fprintf(stderr,"keyw_%s() @ %ld: STUB\n", lextable[keyidx].keyword, ftell(s));
// return(NULL);
  value = keyw_generic_kv_part2(s, keyidx, return_nextcontext);
  if (value==NULL) return(NULL);

  fprintf(stderr,"keyword \"%s\" = \"%s\"\n", lextable[keyidx].keyword, value);
  /* just overwrite in array values[keyidx] for now */
  if (values[keyidx]){
    free(values[keyidx]);
    values[keyidx]=NULL;
  }
  values[keyidx]=value;
  return((void *)value);
}


/* this is part of a { keyword, value } pair, but we have already
   read and parsed the keyword (use keyidx as index to table lextable)
   what we expect now is:
   - ";"
   - <len of value>
   - ":"
   - <value>
   - <1 char to define datatype?>

   return value: <value> or NULL
   it's the parent function's responsibility to deallocate value
    */
void *keyw_generic_kv_part2(FILE *s, const int keyidx, int *return_nextcontext)
{
  int ok = 0;
  hdr_t vhdr;
  char *value = NULL;
  int nextchar = '?';

  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n"); 
  }
  memset(&vhdr,0x00,sizeof(hdr_t));
  ok = parse_hdr(s, &vhdr);
  if (ok!=0){
    fprintf(stderr,"keyw_generic_kv_part2() ERROR: couldnt parse value length @ %ld\n",ftell(s));
    return(NULL);
  }

  ok = read_entry(s, &vhdr);
  if (ok!=0){
    fprintf(stderr,"keyw_generic_kv_part2() ERROR: couldnt read value @ %ld\n",ftell(s));
    return(NULL);
  }

  value = (char *)vhdr.buf;
  vhdr.buf=NULL;

  /* after entry comes 1-char ; */
  nextchar = fgetc(s);
  /* DOESN'T MATTER if EOF */
  switch(nextchar){
    case '!': /* 0x21 boolean */
      fprintf(stderr,"DBG probably a boolean\n");
      break;

    case '#': /* 0x23 int (I think) */
      fprintf(stderr,"DBG probably an int\n");
      break;

    case ',': /* 0x2c table value (I think) */
      fprintf(stderr,"DBG probably a table value\n");
      break;

    case ';': /* 0x3e string */
      fprintf(stderr,"DBG probably a string\n");
      break;

    case '^': /* 0x5e double precision? timestamp */
      fprintf(stderr,"DBG probably a time_t with fraction of seconds\n");
      break;

    default:
      fprintf(stderr,"WARNING unexpected value type 0x%02x %c for %s = %s\n", nextchar, nextchar, lextable[keyidx].keyword, value);
      break;
  }

  /* return the value string */
  
  return(value);
}

/* syntax:
   <size of list block>
   ":"
   list of k,v pairs
{  "}"
*/
void *keyw_generic_list_of_kvs_1(FILE *s, const int keyidx, int *return_nextcontext, const int do_analyse_list)
{
  size_t listlen, nbread;
  hdr_t listhdr;
  int ok;
  uint8_t *readaheadbuf = NULL;

  fprintf(stderr,"keyw_%s() @ %ld: STUB implemented with generic_list_of_kvs()\n", lextable[keyidx].keyword, ftell(s));

  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n"); 
  }

  memset(&listhdr, 0x00, sizeof(hdr_t));
  ok = parse_hdr(s, &listhdr);
  if (ok!=0){
    fprintf(stderr,"parse ERROR reading %s len @ %ld\n", lextable[keyidx].keyword, ftell(s));
    return(NULL);
  }
  listlen = listhdr.len;

  if (do_analyse_list) {
    /* TODO read the k,vs */
    fprintf(stderr,"generic_list_of_kvs(%s): ERROR UNIMPLEMENTED STUB\n", lextable[keyidx].keyword);
  } else {
    readaheadbuf = (uint8_t *) malloc((listlen+1) * sizeof(uint8_t));
    if (readaheadbuf == NULL) return((void *)-1);
    memset(readaheadbuf, 0x00, listlen);
    readaheadbuf[listlen] = '\0';


    nbread=fread(readaheadbuf, 1, listlen, s);
    if ((nbread!=listlen) || (feof(s))) {
      fprintf(stderr,"generic_list_of_kvs(%s): ERROR only read %ld/%ld bytes\n", lextable[keyidx].keyword, nbread, listlen);
      return((void *)-1);
    }

    fprintf(stderr,"boring_generic_list_of_kvs(%s): DBG: unparsed, list contains \"%s\"\n", lextable[keyidx].keyword, readaheadbuf);

    free(readaheadbuf);
    readaheadbuf = NULL;
  } /* endif do_analyse_list */

  if (parse_1_char(s, /* { */ '}')) {
    fprintf(stderr,"expected a ;. oh well.\n"); 
  }

  return((void *)listlen);
}

void *keyw_generic_list_of_kvs(FILE *s, const int keyidx, int *return_nextcontext)
{
  return(keyw_generic_list_of_kvs_1(s, keyidx, return_nextcontext, 1 /* do_analyse_list */));
}

/* don't parse the contents of the list */
void *keyw_boring_generic_list_of_kvs(FILE *s, const int keyidx, int *return_nextcontext)
{
  return(keyw_generic_list_of_kvs_1(s, keyidx, return_nextcontext, 0 /* do_analyse_list */));
}

/* NB this function can make the program exit if more than HTTPERRORWINDOW errors */
int analyse_httperrorwindow(const char *newstatus) {
  char statusletter = newstatus[0];
  int pos = httperrorcursor, workpos, noerrorslot = 0;

  switch(statusletter){
  
    default: /* huh?? */
      fprintf(httpstatusdumpfile, "999 UNDEFINED letter 0x%02x %c for %s\n", statusletter, statusletter, newstatus);
      httperrorwindow[pos++] = statusletter;
      if (pos>=HTTPERRORWINDOWLEN){
        /* wraparound */
        pos = 0;
      }
    break;

    case '2': /* OK */
    case '3': /* Redirect */
      httperrorwindow[pos++] = statusletter;
      if (pos>=HTTPERRORWINDOWLEN){
        /* wraparound */
        pos = 0;
      }
    break;

    case '4': /* client access error */
    case '5': /* server error */
      /* normal processing would be: drop the last from the FIFO queue,
         insert this one as "most recent" 
         BUT I want errors to count much more */
//       httperrorwindow[pos++] = statusletter;
//       if (pos>=HTTPERRORWINDOWLEN){
//         /* wraparound */
//         pos = 0;
//       }

         noerrorslot = pos;
         /* treat the errorwindow now not as a ringbuffer but as 2 stretches
            before and after current cursor */
         for(workpos=pos-1;workpos >= 0; workpos--) {
           if ((httperrorwindow[workpos] == '2') || (httperrorwindow[workpos] == '3')) {
             /* found an empty slot */
             fprintf(stderr,"DBG slot # %d for error %c %s\n", workpos, statusletter, newstatus);
             noerrorslot = workpos;
             httperrorwindow[noerrorslot] = statusletter;
             /* do NOT advance the cursor !! */
             return(0);
           }
         } /* previous workpos */

         /* now do the same from end of window to pos+1 */
         for(workpos=HTTPERRORWINDOWLEN - 1;workpos >= pos+1; workpos--) {
           if ((httperrorwindow[workpos] == '2') || (httperrorwindow[workpos] == '3')) {
             /* found an empty slot */
             fprintf(stderr,"DBG slot # %d for error %c %s\n", workpos, statusletter, newstatus);
             noerrorslot = workpos;
             httperrorwindow[noerrorslot] = statusletter;
             /* do NOT advance the cursor !! */
             return(0);
           }
         } /* previous workpos */
         
         /* only one option left to dump the error in */
         workpos = pos;
         if ((httperrorwindow[workpos] == '2') || (httperrorwindow[workpos] == '3')) {
             fprintf(stderr,"DBG last slot # %d for error %c %s\n", workpos, statusletter, newstatus);
             noerrorslot = workpos;
             httperrorwindow[noerrorslot] = statusletter;
             /* do NOT advance the cursor !! */
             return(0);
         }

         /* OK the error window is filled with errors now. QUIT. */
         fprintf(httpstatusdumpfile, "999 all the last %d HTTP requests gave errors, time to QUIT\n", HTTPERRORWINDOWLEN );
         exit(1);
         return(1);

    break;
  }

  return(0);
}


void *keyw_status_code(FILE *s, const int keyidx, int *return_nextcontext)
{
  char *value = (char *) keyw_generic_kv(s, keyidx, return_nextcontext);

  switch (keyidx) {
    default: /* unexpected; ignore */
      fprintf(stderr,"keyw_status_code(): IGNORE strange keyidx %d (%s) value %s\n", keyidx, lextable[keyidx].keyword, value);
      break;

    case KEYW_STATUS_CODE:
      fprintf(stderr," DBG keyw_status_code(%s)\n", value);
      fprintf(httpstatusdumpfile , "%s\n", value);
      analyse_httperrorwindow(value);

      break;
  }

  return((void *)value);
}


/*
   This function modifies the context to CONTEXT_RESPONSE
   It also changes values in the "whereami" context struct

   syntax:
   8:response;
   <reponse len>:7:content;<content len>:<content blob>,
   MORE HEADERS AFTER CONTENT
*/
void *keyw_response(FILE *s, const int keyidx, int *return_nextcontext)
{
  size_t responselen;
  hdr_t responsehdr;
  int ok;

  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  ok = parse_hdr(s, &responsehdr);
  if (ok!=0) return((void *)-1);
  responselen = responsehdr.len;
  fprintf(stderr,"DBG keyw_response(response length = %ld)\n", responselen);

  /* side-effect: change context, and already set responselen */
  *return_nextcontext = CONTEXT_RESPONSE;
  /* HACK this should really only be set after keyw_response() returns, I suppose */
  whereami.current_response_startpos = ftell(s);
  whereami.current_response_len = responselen;
  whereami.current_response_pos = 0;

  return((void *)-1);
}


int dump_request_header(const size_t relevant_entrynr, const int delete_values_after_use)
{
  FILE *hdrdumpfile;
  char hdrdumpfilename[256];
  char requestheaderstring[4096+1], tmpstr[4096+1];
  int which_headers_have_i_got; /* bitmap */

  fprintf(stderr,"HACK: after request content, dump method header into req.%06ld.info\n", relevant_entrynr);
  sprintf(hdrdumpfilename,"req.%06ld.info", relevant_entrynr);
  hdrdumpfile = fopen(hdrdumpfilename, "a");
  if (hdrdumpfile == NULL){
    fprintf(stderr,"dump_request_header(): ERROR writing to %s: %s\n",hdrdumpfilename, strerror(errno));
    return(-1);
  }
  memset(&requestheaderstring, 0x00, 4096+1);
  memset(&tmpstr, 0x00, 4096+1);
  requestheaderstring[0] = '\0';

  /* finally get to use the values[] array */
  which_headers_have_i_got = 0x0000;

  if (values[KEYW_METHOD]){
    which_headers_have_i_got |= 0x0001;
  }
  if (values[KEYW_SCHEME]){
    which_headers_have_i_got |= 0x0002;
  }

  /* N.B. there are 2 host headers:
     one in the mitmdump request structure,
     which means the Internet address (IPv4 or IPv6) or FQDN that identifies the Internet host that the request was sent to.
     The other is from a field Host: in the HTML request header
     that is used by the receiving webserver to differentiate between multiple
     virtual webservers hosted on the same Internet host (see how Apache does it).
   */
  if (values[KEYW_HOST]){
    which_headers_have_i_got |= 0x0004;
  }
  if (values[KEYW_PORT]){
    which_headers_have_i_got |= 0x0008;
  }
  if (values[KEYW_PATH]){
    which_headers_have_i_got |= 0x0010;
  }

  /* following rules are just to make the output prettier */
  /* HACK: don't display port if it's the default port for the scheme */
  if ((which_headers_have_i_got & 0x000a) == 0x000a){
    if ((!strcmp(values[KEYW_SCHEME],"http")) && (!strcmp(values[KEYW_PORT],"80"))){
      which_headers_have_i_got &= ~0x0008;
    }

    if ((!strcmp(values[KEYW_SCHEME],"https")) && (!strcmp(values[KEYW_PORT],"443"))){
      which_headers_have_i_got &= ~0x0008;
    }
  }

  if (which_headers_have_i_got & 0x0010) {
    if (!strcmp(values[KEYW_PATH], "/")){
      which_headers_have_i_got &= ~0x0010;
    }
  }

  switch(which_headers_have_i_got){
    case 0x001f: /* method, scheme, host, port, path */
      sprintf(requestheaderstring, "%s %s://%s:%s%s", values[KEYW_METHOD], values[KEYW_SCHEME], values[KEYW_HOST], values[KEYW_PORT], values[KEYW_PATH]);
      break;

    case 0x0017: /* method, scheme, host,       path */
      sprintf(requestheaderstring, "%s %s://%s%s", values[KEYW_METHOD], values[KEYW_SCHEME], values[KEYW_HOST], values[KEYW_PATH]);
      break;

    case 0x0007: /* method, scheme, host,            */
      sprintf(requestheaderstring, "%s %s://%s/", values[KEYW_METHOD], values[KEYW_SCHEME], values[KEYW_HOST] );
      break;

    default:
      sprintf(requestheaderstring,"dump_request_header(): insufficient info, 0x%04x\n", (uint32_t)which_headers_have_i_got);
      break;
  }

  if (requestheaderstring[0]) {
    fprintf(hdrdumpfile, "%s\n", requestheaderstring);
    fprintf(stderr,"DBG: dump_request_header() gives %s\n", requestheaderstring);
  }
  fclose(hdrdumpfile);

  if (delete_values_after_use){
    if (values[KEYW_METHOD]){ free(values[KEYW_METHOD]); values[KEYW_METHOD]=NULL; }
    if (values[KEYW_SCHEME]){ free(values[KEYW_SCHEME]); values[KEYW_SCHEME]=NULL; }
    if (values[KEYW_HOST]){ free(values[KEYW_HOST]); values[KEYW_HOST]=NULL; }
    if (values[KEYW_PORT]){ free(values[KEYW_PORT]); values[KEYW_PORT]=NULL; }
    if (values[KEYW_PATH]){ free(values[KEYW_PATH]); values[KEYW_PATH]=NULL; }
  }

  return(0);
}

/* syntax: 
   7:content;<content len>:<content blob>,
*/
void *keyw_content(FILE *s, const int keyidx, int *return_nextcontext)
{
  size_t contentlen;
  hdr_t contenthdr;
  int ok;

  fprintf(stderr,"keyw_content(context = %s) STUB\n", contextstring[whereami.curcontext]);
  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  memset(&contenthdr,0x00,sizeof(hdr_t));
  ok = parse_hdr(s, &contenthdr);
  if (ok!=0) return((void *)-1);
  contentlen = contenthdr.len;
  fprintf(stderr,"DBG keyw_content(content length = %ld)\n", contentlen);

  /* sanity check */
  switch(whereami.curcontext){
    case CONTEXT_RESPONSE:
      if ((contentlen <0 ) || (1 + contentlen >= whereami.current_response_len)) {
        fprintf(stderr,"keyw_content() ERROR: response len %ld but contentlen %ld\n", whereami.current_response_len, contentlen);
        return((void *)-1);
      }
      break;

    case CONTEXT_REQUEST:
      if ((contentlen <0 ) || (1 + contentlen >= whereami.current_request_len)) {
        fprintf(stderr,"keyw_content() ERROR: request len %ld but contentlen %ld\n", whereami.current_request_len, contentlen);
        return((void *)-1);
      }
      break;

    default:
      fprintf(stderr,"keyw_content() INTERNAL ERROR UNIMPLEMENTED context %d %s\n", whereami.curcontext, contextstring[whereami.curcontext]);
      exit(1);
      break;
  }

  ok = read_entry(s, &contenthdr);
  if (ok!=0) return((void *)-1);

  ok = dump_entry(whereami.curcontext, &contenthdr, whereami.entrynr);

  /* important!! content usually takes a large chunk of memory */
  free(contenthdr.buf);
  contenthdr.buf = NULL;

  if (ok!=0) return((void *)-1);
  whereami.entrynr++;

  if (parse_1_char(s, ',')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  return(NULL);
}

/* hp must be pre-allocated!
   expected syntax:
 [ <total header len>:<header name len>:<header name>,<header value len>:<header value>,]
 */
int read_1_header(FILE *bs, hdr_p hp)
{
  int ok;
  hdr_t lenhdr, valhdr;

  memset(&lenhdr, 0x00, sizeof(hdr_t));
  ok = parse_hdr(bs, &lenhdr);
  if (ok!=0) return(ok);

  ok = parse_hdr(bs, hp);
  if (ok!=0) return(ok);

  ok = read_entry(bs, hp);
  if (ok!=0) return(ok);

  if (parse_1_char(bs, ',')) {
    fprintf(stderr,"expected a ,. oh well.\n");
  }

  memset(&valhdr, 0x00, sizeof(hdr_t));
  ok = parse_hdr(bs, &valhdr);
  if (ok!=0) return(ok);
  
  ok = read_entry(bs, &valhdr);
  if (ok!=0) return(ok);

  /* rearrange */
  hp->value = valhdr.buf;
  valhdr.buf = NULL;

  if (parse_1_char(bs, ',')) {
    fprintf(stderr,"expected a ,. oh well.\n");
  }
  if (parse_1_char(bs, /* [ */ ']')) {
    fprintf(stderr,"expected a close bracket. oh well.\n");
  }

  return(ok);
}

int parse_html_header(const hdr_p hp)
{
  int h;

  for(h=0;h<NHTMLH;h++){
    if (!strcasecmp((char *)hp->buf, htmlhandlers[h].keyword)){
      htmlhandlers[h].func(h, (void *) hp);
      return(h);
    }
  }
  /* if doesn't match, just ignore it. */
  fprintf(stderr,"DBG parse_html_header(%s) no handler\n", hp->buf);
  return(0);
}

/* syntax:
 [ 7:headers;<headers len>]
*/
void *keyw_respheaders(FILE *s, const int keyidx, int *return_nextcontext)
{
  int ok;
  hdr_t headershdr;
  size_t headerslen, nbread;
  uint8_t *readaheadbuf = NULL;
  FILE *bufstream = NULL;
  hdr_t curhdr;

  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  ok = parse_hdr(s, &headershdr);
  if (ok!=0) return((void *)-1);
  headerslen = headershdr.len;
  fprintf(stderr,"DBG keyw_headers(headers length = %ld)\n", headerslen);


  /* TODO don't parse them yet */
  readaheadbuf = (uint8_t *) malloc((headerslen+1) * sizeof(uint8_t));
  if (readaheadbuf == NULL) return((void *)-1);
  memset(readaheadbuf, 0x00, headerslen);
  readaheadbuf[headerslen] = '\0';


  nbread=fread(readaheadbuf, 1, headerslen, s);
  if ((nbread!=headerslen) || (feof(s))) {
    fprintf(stderr,"keyw_headers: ERROR only read %ld/%ld bytes\n", nbread, headerslen);
    return((void *)-1);
  }

  fprintf(stderr,"keyw_headers(): DBG: unparsed, list contains \"%s\"\n", readaheadbuf);

  if (parse_1_char(s, /* [ */ ']')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  /* the following may well be a bit Linux-specific ... */
  bufstream = fmemopen(readaheadbuf, headerslen, "r");
  if (bufstream == NULL){
    fprintf(stderr,"keyw_headers(): fmemopen() ERROR: %s\n",strerror(errno));
    exit(1);
  }
  memset(&curhdr, 0x00, sizeof(hdr_t));

  do {
     if (curhdr.buf) { free(curhdr.buf); curhdr.buf = NULL; }
     if (curhdr.value) { free(curhdr.value); curhdr.value = NULL; }

     ok = read_1_header(bufstream, &curhdr);
     if (ok!=0) break;
     fprintf(stderr,"DBG in keyw_headers() just read \"%s\" = \"%s\"\n", curhdr.buf, curhdr.value);
     ok = parse_html_header(&curhdr);
  } while(1);

  fclose(bufstream);
  free(readaheadbuf);
  readaheadbuf = NULL;

//  fprintf(stderr,"STOP HERE FOR NOW\n");exit(1);


  return(NULL);
}

/* syntax:
 [ 7:headers;<headers len>]
*/
void *keyw_reqheaders(FILE *s, const int keyidx, int *return_nextcontext)
{
  int ok;
  hdr_t headershdr;
  size_t headerslen, nbread;
  uint8_t *readaheadbuf = NULL;
  FILE *bufstream;
  hdr_t curhdr;

  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  ok = parse_hdr(s, &headershdr);
  if (ok!=0) return((void *)-1);
  headerslen = headershdr.len;
  fprintf(stderr,"DBG keyw_headers(headers length = %ld)\n", headerslen);


  /* TODO don't parse them yet */
  readaheadbuf = (uint8_t *) malloc((headerslen+1) * sizeof(uint8_t));
  if (readaheadbuf == NULL) return((void *)-1);
  memset(readaheadbuf, 0x00, headerslen);
  readaheadbuf[headerslen] = '\0';


  nbread=fread(readaheadbuf, 1, headerslen, s);
  if ((nbread!=headerslen) || (feof(s))) {
    fprintf(stderr,"keyw_headers: ERROR only read %ld/%ld bytes\n", nbread, headerslen);
    free(readaheadbuf);
    return((void *)-1);
  }

  fprintf(stderr,"keyw_headers(): DBG: unparsed, list contains \"%s\"\n", readaheadbuf);

  /* the following may well be a bit Linux-specific ... */
  bufstream = fmemopen(readaheadbuf, headerslen, "r");
  if (bufstream == NULL){
    fprintf(stderr,"keyw_headers(): fmemopen() ERROR: %s\n",strerror(errno));
    exit(1);
  }
  memset(&curhdr, 0x00, sizeof(hdr_t));

  do {
     if (curhdr.buf) { free(curhdr.buf); curhdr.buf = NULL; }
     if (curhdr.value) { free(curhdr.value); curhdr.value = NULL; }

     ok = read_1_header(bufstream, &curhdr);
     if (ok!=0) break;
     fprintf(stderr,"DBG in keyw_headers() just read \"%s\" = \"%s\"\n", curhdr.buf, curhdr.value);
     ok = parse_html_header(&curhdr);
  } while(1);

  fclose(bufstream);

  free(readaheadbuf);
  readaheadbuf = NULL;

  if (parse_1_char(s, /* [ */ ']')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }
  return(NULL);
}

void *keyw_headers(FILE *s, const int keyidx, int *return_nextcontext)
{
  fprintf(stderr,"keyw_headers(context = %s) STUB\n", contextstring[whereami.curcontext]);
  switch(whereami.curcontext){
    case CONTEXT_RESPONSE:
      return(keyw_respheaders(s, keyidx, return_nextcontext));
      break;

    /* I know it's a bit duplicate code just now, but just in case. */
    case CONTEXT_REQUEST:
      return(keyw_reqheaders(s, keyidx, return_nextcontext));
      break;

    default:
      fprintf(stderr,"keyw_headers() INTERNAL ERROR UNIMPLEMENTED for context = %d %s\n", whereami.curcontext, contextstring[whereami.curcontext]);
      exit(1);
      break;
  }
}

/* TODO: check the value against a list of allowed values for this keyword

   reason = "OK"
   http_version = "HTTP/1.1"
   method = "GET"
   first_line_value = "relative" ???
*/
void *keyw_generic_kv_table(FILE *s, const int keyidx, int *return_nextcontext)
{
  void *valuep;
  char *value;
//  fprintf(stderr,"keyw_generic_kv_table(%s) STUB TODO implemented as generic kv for now\n", lextable[keyidx].keyword);
  valuep = keyw_generic_kv(s, keyidx, return_nextcontext);

  if (valuep==NULL) return((void *)-1);

  value = (char *) valuep;

  fprintf(stderr,"keyw_generic_kv_table(%s = %s) STUB TODO implemented as generic kv for now\n", lextable[keyidx].keyword, value);
  return(valuep);
}

/* HACK:
   http_version is a normal kv pair, but
   because it is the last field in a response context,
   parse the termination of response context as well.
*/
void *keyw_http_version(FILE *s, const int keyidx, int *return_nextcontext)
{
  void *valuep;
  fprintf(stderr,"keyw_http_version in context %d %s STUB\n", whereami.curcontext, contextstring[whereami.curcontext]);

  switch(whereami.curcontext){
    case CONTEXT_RESPONSE:
      /* ASSUMPTION: that http_version is not the last field so act normally */
      valuep = keyw_generic_kv_table(s, keyidx, return_nextcontext);
      if (valuep==NULL) return((void *)-1);
      return(valuep);
      break;

    case CONTEXT_REQUEST:
      /* ASSUMPTION: that http_version is not the last field so act normally */
      valuep = keyw_generic_kv_table(s, keyidx, return_nextcontext);
      if (valuep==NULL) return((void *)-1);
      return(valuep);
      break;

    default:
      fprintf(stderr,"keyw_http_version() INTERNAL ERROR UNIMPLEMENTED for context = %d %s\n", whereami.curcontext, contextstring[whereami.curcontext]);
      exit(1);
      break;
  }

#if 0

  valuep = keyw_generic_kv_table(s, keyidx, return_nextcontext);
  if (valuep==NULL) return((void *)-1);
  /* not actually all that interested in its value */

  /* finish off response context */

  /* TODO verify that we used up the exact amount of response bytes */

  int nextbyte = fgetc(s);
  if (nextbyte == /* { */ '}' ){
    /* change context back to main */
    *return_nextcontext = CONTEXT_MAIN;

    return(NULL);
  }

  fprintf(stderr,"WARNING unexpected next char = 0x%02x %c\n",nextbyte,nextbyte);
  ungetc(nextbyte, s);
#endif

  return((void *) -1);
}

/*
   This function modifies the context to CONTEXT_REQUEST
   It also changes values in the "whereami" context struct

   syntax:
   7:request;
   <request len>:7:content;<content len>:<content blob>,
   MORE HEADERS AFTER CONTENT
*/
void *keyw_request(FILE *s, const int keyidx, int *return_nextcontext)
{
  size_t requestlen;
  hdr_t requesthdr;
  int ok;

  if (parse_1_char(s, ';')) {
    fprintf(stderr,"expected a ;. oh well.\n");
  }

  ok = parse_hdr(s, &requesthdr);
  if (ok!=0) return((void *)-1);
  requestlen = requesthdr.len;
  fprintf(stderr,"DBG keyw_request(request length = %ld)\n", requestlen);

  /* side-effect: change context, and already set requestlen */
  *return_nextcontext = CONTEXT_REQUEST;
  /* HACK this should really only be set after keyw_request() returns, I suppose */
  whereami.current_request_startpos = ftell(s);
  whereami.current_request_len = requestlen;
  whereami.current_request_pos = 0;

  return((void *)-1);
}

char *stringsanitize(const char *is)
{
  static char buf[256];
  int i, oops;
  if ((is==NULL)||(strlen(is)>=256)) return(NULL);
  buf[0]= '\0';
  buf[strlen(is)] = '\0';

  oops=0;
  for (i=0;i<strlen(is); i++){
    switch(is[i]){
      case 'a' ... 'z':
      case 'A' ... 'Z':
      case '0' ... '9':
      case '.':
      case '_':
        buf[i] = is[i];
        break;


      default:
        oops=1;
        break;
    }

    if(oops) { return(NULL); }
  }

  return(buf);
}

/* TODO high prio uncompress dumpfile
   implementation: system() call */
void *htmlh_content_encoding(const int idx, void *ctx)
{
  hdr_p hp = (hdr_p) ctx;
#define CONTENTENCODING_GZIP	 0
#define NCONTENTENCODING	 1
  struct contentencoding_proto {
    int idx;
    char name[64];
    char cmdtemplate[128];
  } contentencoding[NCONTENTENCODING] = {
    { CONTENTENCODING_GZIP, "gzip", "zcat %s > %s" }
  };
  char tmpstr[256], *tmpstr2;
  char safeinfilename[256];
  char safeoutfilename[256];
  char safecmd[512];
  int ce;
  size_t relevant_entrynr;

  fprintf(stderr,"htmlh_content_encoding(%s) STUB TODO\n", hp->value);

  /* ASSUMPTION !!! */
  relevant_entrynr = whereami.entrynr - 1;

  for(ce=0;ce<NCONTENTENCODING;ce++){
    if (strcmp((char *)hp->value, contentencoding[ce].name)) continue;

    fprintf(stderr,"DBG match #%d %s \"%s\"\n", ce, contentencoding[ce].name, contentencoding[ce].cmdtemplate);

    /* input file name */
    sprintf(tmpstr, "rawres.%06ld", relevant_entrynr);
    tmpstr2 = stringsanitize(tmpstr);
    if (tmpstr2 == NULL) { fprintf(stderr,"SYNTAX ERROR filename \"%s\"\n", tmpstr); break; }
    strcpy(safeinfilename, tmpstr2);
    fprintf(stderr,"input filename = \"%s\"\n", safeinfilename);

    /* output file name */
    sprintf(tmpstr, "res.%06ld.something", relevant_entrynr);
    tmpstr2 = stringsanitize(tmpstr);
    if (tmpstr2 == NULL) { fprintf(stderr,"SYNTAX ERROR filename \"%s\"\n", tmpstr); break; }
    strcpy(safeoutfilename, tmpstr2);
    fprintf(stderr,"output filename = \"%s\"\n", safeoutfilename);

    /* system command. the command template must be written in such a way that it contains 2 %s, first for infilename second for outfilename. */
    sprintf(safecmd, contentencoding[ce].cmdtemplate, safeinfilename, safeoutfilename);
    fprintf(stderr,"DBG system command = %s\n", safecmd);
    system(safecmd);
    /* only 1 entry can match so return */
    return(NULL);
  } /* next ce */

  /* if it comes here, we have an UNDEFINED Content-Encoding: header
     which could easily be a problem. */
  FILE *errf = fopen(ERRORLOG, "a");
  if (errf){
     fprintf(errf,"htmlh_content_encoding() ERROR: UNDEFINED encoding %s for dump file rawres.%06ld\n", hp->value, relevant_entrynr);
    fclose(errf);
  }

  return(NULL);
}

/* TODO make file name extension table and rename dump file to .html, .json, .jpg etc */
void *htmlh_content_type(const int idx, void *ctx)
{
  hdr_p hp = (hdr_p) ctx;
  fprintf(stderr,"htmlh_content_type(%s) STUB TODO\n", hp->value);
  return(NULL);
}

/* appends the cookie to a request info file */
void *htmlh_cookie(const int idx, void *ctx)
{
  hdr_p hp = (hdr_p) ctx;
  size_t relevant_entrynr;
  FILE *infofile=NULL;
  char infofilename[64];

  /* ASSUMPTION !!! */
  relevant_entrynr = whereami.entrynr - 1;

  fprintf(stderr,"htmlh_cookie(%s) STUB TODO\n", hp->value);

  sprintf(infofilename, "req.%06ld.info", relevant_entrynr);
  infofile = fopen(infofilename, "a");
  if (infofile == NULL) return(NULL);

  fprintf(infofile, "%s=%s\n", hp->buf, hp->value);
  fclose(infofile);

  return(NULL);
}

/* appends the Host: to a request info file
   Not to be confused with the KEYW_HOST value */
void *htmlh_host(const int idx, void *ctx)
{
  hdr_p hp = (hdr_p) ctx;
  size_t relevant_entrynr;
  FILE *infofile=NULL;
  char infofilename[64];

  /* ASSUMPTION !!! */
  relevant_entrynr = whereami.entrynr - 1;

  fprintf(stderr,"htmlh_host(%s) STUB TODO\n", hp->value);

  sprintf(infofilename, "req.%06ld.info", relevant_entrynr);
  infofile = fopen(infofilename, "a");
  if (infofile == NULL) return(NULL);

  fprintf(infofile, "%s=%s\n", hp->buf, hp->value);
  fclose(infofile);

  return(NULL);
}
