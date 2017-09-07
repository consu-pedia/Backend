#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include <time.h>

#define BLOCKSZ		4096
#undef DEBUG

static int opt_chunking = 1;
static size_t opt_chunking_high = 131072;


typedef struct hdr_proto {
#define MAXHDRLEN	256
  size_t len;
  uint8_t *buf;
  uint8_t *value;
} hdr_t, *hdr_p;

static int parse_hdr_2(FILE *s, hdr_p curhdr, uint8_t *numbuf, int *return_hdrlen);

/* expect: number followed by ':'
   curhdr must already be allocated */
int parse_hdr(FILE *s, hdr_p curhdr)
{
  int hdrlen=0;
  char numbuf[MAXHDRLEN+1+1];
  int res = parse_hdr_2(s, curhdr, (uint8_t *) &numbuf[0], &hdrlen);
  return(res);
}

/* numbuf must be pre-allocated with size at least MAXHDRLEN+1+1 */
static int parse_hdr_2(FILE *s, hdr_p curhdr, uint8_t *numbuf, int *return_hdrlen)
{
  int i,c,quit,ok;

  memset(numbuf,0x00,MAXHDRLEN+1+1);

  quit=0;
  *return_hdrlen = 0;
  for(i=0;i<MAXHDRLEN && quit==0;i++){
    c = fgetc(s);
    (*return_hdrlen)++;
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
  ok=sscanf((char *)numbuf, "%ld", &len);

  /* whether it was OK or not; append the read character c in numbuf to prevent
     complications. Just do it AFTER the sscanf() ;-) */
  if (i<MAXHDRLEN) numbuf[i-1]=c;

  if (ok!=1){
     fprintf(stderr,"parse_hdr(): ERROR parsing <%s>\n",numbuf);
     return(1);
  }
  curhdr->len = len;
//DBG  fprintf(stderr,"parse_hdr(): len = %ld\n",len);

  return(0);
}

static char *now(void)
{
  static char nowstr[64];
  time_t tnow = time(NULL);

  nowstr[0]='\0';
  nowstr[64-1]='\0';
  strftime(nowstr, 64-1, "%Y%m%d.%H%M", localtime(&tnow));

  return(nowstr);
}

int main(int argc, char *argv[])
{
  hdr_t hdr;
  size_t nbtoread = 0;
  int chunknr=0;
  FILE *inf = stdin;
  FILE *outf = NULL;
  int ok;
  uint8_t numbuf[MAXHDRLEN+1+1];
  int hdrlen=0;
  char outfname[256];
#define DEFAULT_OUTFNAME	"tmp.spit_mitm_chunk"
  size_t nbr, nbw;
  uint8_t blkbuf[BLOCKSZ];
  int quit;
  int do_emit;
  size_t nbrchunks;
  char nowstr[256];

  memset(&hdr, 0x00, sizeof(hdr));
  memset(&numbuf[0], 0x00, sizeof(numbuf));


  nbrchunks = 0;

  /* expect: begins with correct header. exit immediately if corrupt from the beginning. */
  ok = parse_hdr_2(inf, &hdr, &numbuf[0], &hdrlen);
  if (ok!=0){
    fprintf(stderr,"spit_mitm_chunks(): ERROR, stream doesn't begin with a valid header, exiting.\n");
    exit(1);
  }

  /* total # bytes expected to read */
  nbtoread = /* hdrlen + 1 for : + */ hdr.len + 1;
  nbrchunks = hdrlen + nbtoread;

  outf = fopen(DEFAULT_OUTFNAME, "w");
  if (outf==NULL){
    fprintf(stderr,"spit_mitm_chunks(): ERROR writing %s: %s\n", DEFAULT_OUTFNAME, strerror(errno));
    exit(1);
  }

  quit=1;
  do_emit=0;
  do { /* MAIN LOOP */
    /* at the beginning of the main loop we always have:
       - just read a valid header
       - an open output file
     */

    quit=0;
    /* first write the header bytes */
    fwrite(numbuf, 1, hdrlen, outf);

    /* read upto end of first block */
    int lfirstblock = BLOCKSZ - hdrlen;
    /* special case */
    if (hdrlen + hdr.len + 1 < BLOCKSZ) {
      lfirstblock = hdr.len + 1 /* 1 for the terminating bracket */;
      if (lfirstblock <= 0){
        fprintf(stderr,"spit_mitm_chunks(): ERROR negative header %ld\n", hdr.len);
        fclose(outf);
        continue;
      }
    }

    nbr = fread(blkbuf, 1, lfirstblock, stdin);
    if (nbr!=lfirstblock){
        fprintf(stderr,"spit_mitm_chunks(): ERROR truncated input\n");
        quit=1;
    }

    /* N.B. have now read hdrlen + lfirstblock  bytes, of the hdrlen + hdr.len + 1 */
    nbtoread -= nbr;

    nbw = fwrite(blkbuf, 1, nbr, outf);
    if (nbw!=nbr){
        fprintf(stderr,"spit_mitm_chunks(): ERROR truncated output\n");
        quit=1;
    }

#ifdef DEBUG
    fprintf(stderr,"DBG nbtoread %ld\n",nbtoread);
#endif	/* DEBUG */
    /* read/write BLOCKSZ chunks loop */
    while ((!quit) && (nbtoread >= BLOCKSZ)){
#ifdef DEBUG
      fprintf(stderr,"DBG block read nbtoread %ld\n",nbtoread);
#endif	/* DEBUG */

      nbr = fread(blkbuf, BLOCKSZ, 1, stdin);
      if (nbr!=1){
        fprintf(stderr,"spit_mitm_chunks(): ERROR truncated input\n");
        quit=1;
      } else {
        nbw = fwrite(blkbuf, BLOCKSZ, 1, outf);
        if (nbw!=1){
          fprintf(stderr,"spit_mitm_chunks(): ERROR truncated output\n");
          quit=1;
        }
      }

      nbtoread -= BLOCKSZ;
    }

    /* assert ((nbtoread>=0) && (nbtoread < BLOCKSZ)); */

    if (nbtoread > 0){
#ifdef DEBUG
      fprintf(stderr,"DBG final nbtoread %ld\n",nbtoread);
#endif	/* DEBUG */

#ifdef DEBUG
//DBG fwrite("\n\n__LAST__\n\n", 12,1,outf);
#endif	/* DEBUG */
  
      nbr = fread(blkbuf, 1, nbtoread, stdin);
      if (nbr!=nbtoread){
          fprintf(stderr,"spit_mitm_chunks(): ERROR truncated input\n");
          quit=1;
      }
      nbtoread -= nbr;
  
      nbw = fwrite(blkbuf, 1, nbr, outf);
      if (nbw!=nbr){
          fprintf(stderr,"spit_mitm_chunks(): ERROR truncated output\n");
          quit=1;
      }
    }

    do_emit = 0;
    if (opt_chunking == 1){
      if (nbrchunks >= opt_chunking_high) {
        do_emit = 1;
#ifdef DEBUG
      fprintf(stderr,"DBG begin a new chunk %d\n",chunknr);
#endif	/* DEBUG */
      }
      if (quit) {
        do_emit = 1;
      }
    } else {
      do_emit = 1;
    }

    if (do_emit){
      fflush(outf);
      fclose(outf);
      strcpy(nowstr, now());
      sprintf(outfname,"echunk.%05d.%s", chunknr, nowstr);
      rename(DEFAULT_OUTFNAME, outfname);
  
      /* begin next record */
      chunknr++;
      nbrchunks = 0;

      /* open next dump file */
      outf = fopen(DEFAULT_OUTFNAME, "w");
      if (outf==NULL){
        fprintf(stderr,"spit_mitm_chunks(): ERROR writing %s: %s\n", DEFAULT_OUTFNAME, strerror(errno));
        exit(1);
      }
    }

    memset(&hdr, 0x00, sizeof(hdr));
    memset(&numbuf[0], 0x00, sizeof(numbuf));

    /* expect: begins with correct header. exit immediately if corrupt from the beginning. */
    ok = parse_hdr_2(inf, &hdr, &numbuf[0], &hdrlen);
    if (ok!=0){
      quit=1;
      if (!feof(stdin)){
        fprintf(stderr,"spit_mitm_chunks(): ERROR, stream doesn't begin with a valid header, exiting.\n");
        exit(1);
      }
      /* else, normal EOF */
    }

    /* total # bytes expected to read */
    nbtoread = /* hdrlen + 1 for : + */ hdr.len + 1;
    nbrchunks += hdrlen + nbtoread;

  } while(!quit); /* MAIN LOOP */

  if (outf) {
    fclose(outf);
  }
  fprintf(stderr,"summary: wrote %d chunks last chunk %ld bytes (expected)\n", chunknr, nbrchunks);

  exit(0);
}
