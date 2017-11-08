#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


/* Takes a upper right distance matrix (on stdin) and a list of words (ingredienser) and prints pairs of words that are more similar than a cutoff distance (command line argument). 
   input: upper right distance matrix, like this:
   1 2 3
     4 5
       6

 */
/* #define CUTOFF	10 */
#define CUTOFF	6
static int cutoff = 0;

#define PAIRFORMAT_TEXT	"TEXT"
#define PAIRFORMAT_SQL	"SQL"
static int sql_recordid = 1;

int nw=0;
char **wordlist = NULL;

char **init_wordlist(const char *wordlistfname, int *return_nw)
{
  int w, nw = 0;
  char **wl = NULL;
  FILE *wlf = NULL;
  char line[4096+1], *curw, *chomp;
  *return_nw = 0;
  line[4096]='\0';

  wlf=fopen(wordlistfname, "r");
  if (wlf==NULL){
    fprintf(stderr,"init_wordlist(): ERROR reading file %s: %s\n", wordlistfname, strerror(errno));
    return(NULL);
  }

  /* first establish nw */
  while(!feof(wlf)){
    fgets(line, 4096, wlf);
    nw++;
  }
  nw--;
  fprintf(stderr,"DBG nw = %d\n", nw);
  if (nw <2) {
    fprintf(stderr,"init_wordlist(): not enough (%d)\n", nw);
    return(NULL);
  }
  *return_nw = nw;

  /* now read */
  rewind(wlf);

  wl = (char **) malloc(nw * sizeof(char *));
  if (wl == NULL) return(NULL);

  for(w=0;w<nw;w++){
    curw = fgets(line, 4096, wlf);
    if (strlen(line)==4096){
      fprintf(stderr,"WARNING entry # %d truncated to 4096 bytes\n", w);
    } else {
      chomp = &curw[strlen(curw)-1];
      if (*chomp == '\n') { *chomp = '\0'; }
    }
    wl[w] = strdup(curw);
  }

  fclose(wlf);

  return(wl);
}

void free_wordlist(void)
{
  int w;
  for(w=0;w<nw;w++){
    free(wordlist[w]);
    wordlist[w]=NULL;
  }
  free(wordlist);
  wordlist=NULL;
  nw=0;
}

void init(const char *fname)
{
  wordlist = init_wordlist(fname, &nw);
  fprintf(stderr,"init_wordlist(): %s has %d words.\n", fname, nw);
}

/* C implementation adapted from example code in Wikipedia page
   https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance
   Attribution:
   License:
*/
#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

int levenshtein(const char *s1, const char *s2) {
    unsigned int x, y, s1len, s2len;
    unsigned int **matrix = NULL;
    /* unsigned int matrix[s2len+1][s1len+1]; */
    int result;

    s1len = strlen(s1);
    s2len = strlen(s2);
    matrix = (unsigned int **) malloc((s2len+1) * sizeof(unsigned int *));
    for(x=0;x<s2len+1;x++){ matrix[x] = (unsigned int *) malloc((s1len+1) * sizeof(unsigned int)); }
    matrix[0][0] = 0;
    for (x = 1; x <= s2len; x++)
        matrix[x][0] = matrix[x-1][0] + 1;
    for (y = 1; y <= s1len; y++)
        matrix[0][y] = matrix[0][y-1] + 1;
    for (x = 1; x <= s2len; x++)
        for (y = 1; y <= s1len; y++)
            matrix[x][y] = MIN3(matrix[x-1][y] + 1, matrix[x][y-1] + 1, matrix[x-1][y-1] + (s1[y-1] == s2[x-1] ? 0 : 1));

    result = matrix[s2len][s1len];

    /* clean up !!! */
    for(x=0;x<s2len+1;x++){ free(matrix[x]); }
    free(matrix);

    return(result);
}

void calc_and_print_matrix(const int nw, char **wl)
{
  size_t ncalcs = nw * (nw - 1 ) / 2;
  int x, y;
  int dist;
  int len1, len2;

  fprintf(stderr,"levenshtein matrix: size %d, doing %ld calculations.\n", nw, ncalcs);
  printf("%d\n", nw);

  for(x=0;x<nw;x++){
    if ((x%1000)==0) fprintf(stderr,"..%d ", x);
    for(y=x+1;y<nw;y++) {
      /* DONT BOTHER if strings too dissimilar
         string length differ more than CUTOFF implies:
         Levenshtein edit distance differs more than CUTOFF as well */
      len1 = strlen(wl[x]);
      len2 = strlen(wl[y]);
      if ( (len1 - len2 >= CUTOFF) || (len2 - len1 >= CUTOFF) ){
        dist = CUTOFF;
      } else {
        dist = levenshtein(wl[x], wl[y]);
      }
      if (y)printf("\t");
      printf("%d", dist);
    }
    printf("\n");
  }
  fprintf(stderr,"\n");
}

int print_pair_text(FILE *outf, const int dist, const int x, const int y)
{
  fprintf(outf, "%d\t%d\t%s\t%d\t%s\t\n", dist, x, wordlist[x], y, wordlist[y]);
  return(0);
}

static char *sanitize(char *inp){
  /* TODO implement input sanitizing */
  return(inp);
}

int print_pair_sql(FILE *outf, const int dist, const int x, const int y)
{
 // fprintf(outf, "TODO %d\t%d\t%s\t%d\t%s\t\n", dist, x, wordlist[x], y, wordlist[y]);
  fprintf(outf, "INSERT INTO compare_ingredients VALUES ( %d , %d , \"%s\" , %d , \"%s\" , %d , %d , %d );\n",
          sql_recordid,
          x, sanitize(wordlist[x]),
          y, sanitize(wordlist[y]),
          dist,
          4 /* default value for result */,
          0 /* default value for processed */
         );

  sql_recordid++;

  return(0);
}

int print_pair(const char *pairformat, FILE *outf, const int dist, const int x, const int y)
{
  int res=0;

  if (pairformat==NULL) { return(0);}
  if (!strcmp(pairformat,PAIRFORMAT_TEXT)) {
    res=print_pair_text(outf, dist, x, y); 
  } else {
    if (!strcmp(pairformat,PAIRFORMAT_SQL)) {
      res=print_pair_sql(outf, dist, x, y); 
    } else {
      fprintf(stderr,"INTERNAL ERROR print_pair(pairformat=%s): only \"TEXT\" or \"SQL\" supported\n", pairformat);
      return(-1);
    }
  }
  return(res);
}

int print_create_table_jamfor_ingredienser(FILE *stream)
{
  fprintf(stream, "DROP TABLE IF EXISTS `compare_ingredients`;\n");
  fprintf(stream, "\n");
  fprintf(stream, "CREATE TABLE `compare_ingredients` (\n");
  fprintf(stream, "  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,\n");
  fprintf(stream, "  `record_1_id` int(10) unsigned NOT NULL,\n");
  fprintf(stream, "  `record_1_text` text COLLATE utf8_bin NOT NULL,\n");
  fprintf(stream, "  `record_2_id` int(10) unsigned NOT NULL,\n");
  fprintf(stream, "  `record_2_text` text COLLATE utf8_bin NOT NULL,\n");
  fprintf(stream, "  `edit_distance` int(10) unsigned NOT NULL,\n");
  fprintf(stream, "  `result` int(1) NOT NULL,\n");
  fprintf(stream, "  `processed` int(1) NOT NULL,\n");
  fprintf(stream, "  PRIMARY KEY (`id`)\n");
  fprintf(stream, ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;\n");
  fprintf(stream, "\n");
  return(0);
}

int parse_matrix_and_print_pairs(const char *pairformat, const int nw, char **wl, int co)
{
  int x, y;
  char *stdinline = NULL, *curystring = NULL;
  int ok, dist, vrf_nw;

  /* HACK: reset record number if SQL output. This number gets
     used is record index and incremented with each call to print_pair() */
  if (!strcmp(pairformat,PAIRFORMAT_SQL)){
    sql_recordid = 0;
    print_create_table_jamfor_ingredienser(stdout);
  }

  stdinline=(char *) malloc(65536+1);
  memset(stdinline, 0x00, 65536+1);

  /* 1st line: header line containing nw */
  fgets(stdinline, 65536, stdin);
  if (feof(stdin)||(stdinline[0]=='\0') || (strlen(stdinline) >= 65536) ) {
    fprintf(stderr,"couldnt read header line of distance matrix\n");
    fprintf(stderr,"dont forget to give it on stdin\n");
    exit(1);
  }
  if (stdinline[strlen(stdinline)-1]=='\n') stdinline[strlen(stdinline)-1]='\0';

  ok = sscanf(stdinline, "%d", &vrf_nw);
  if ((ok!=1)||(vrf_nw != nw)){
    fprintf(stderr,"parse_matrix_and_print_pairs() ERROR: stdin doesn't look like an edit distance matrix, header doesn't contain %d but \"%s\"\n", nw, stdinline);
    exit(1);
  }
  

  for(x=0;x<nw-1;x++){
    //DBG fprintf(stderr,"DBG parsing for x = %d\n",x);
    stdinline[0]='\0';
    fgets(stdinline, 65536, stdin);
    if (feof(stdin)||(stdinline[0]=='\0') )break;
    if (strlen(stdinline)>=65536){
      fprintf(stderr,"INTERNAL ERROR: line #%d too long in distance matrix input, rewrite function parse_matrix_and_print_pairs()\n", x);
      exit(1);
    }
    /* chomp() */
    if (stdinline[strlen(stdinline)-1]=='\n') stdinline[strlen(stdinline)-1]='\0';

    y = x + 1;
    curystring = strtok(stdinline, "\t");
    if (curystring == NULL) break;
    ok = sscanf(curystring, "%d", &dist);
    if (ok!=1) break;
    if (dist < co){
      print_pair(pairformat, stdout, dist, x, y);
    }
    // fprintf(stdout,"DBG dist[%d][%d]= %d\n",x,y,dist);
    
    y++;
    for(; y < nw; y++){
      curystring = strtok(NULL, "\t");
      if (curystring == NULL) break;
      ok = sscanf(curystring, "%d", &dist);
      if (ok!=1) break;
      if (dist < co){
        print_pair(pairformat, stdout, dist, x, y);
      }
      //DBG fprintf(stdout,"DBG dist[%d][%d]= %d\n",x,y,dist);
    }

  } /* next x */
  if (x<nw-1){
    fprintf(stderr,"ERROR premature end of x = %d (out of %d)\n",x, nw);
  }


  free(stdinline);

  if (!strcmp(pairformat,PAIRFORMAT_SQL)){
    fprintf(stdout, "\n");
  }

  return(0);
}

int main(int argc, char *argv[])
{
  int ok;
  char wordlistfname[4096];

  if (argc!=3){
    fprintf(stderr,"Usage: printmindist <cutoff edit distance> <filename of wordlist>\nYou need to provide a matrix of edit distances on stdin\n");
    exit(1);
  }

  ok = sscanf(argv[1], "%d", &cutoff);
  strcpy(wordlistfname, argv[2]);
  if (ok!=1){
    fprintf(stderr,"Usage: printmindist <cutoff edit distance> <filename of wordlist>\nYou need to provide a matrix of edit distances on stdin (e.g. output of levenshtein program)\n");
    exit(1);
  }

  init(wordlistfname);
  if (wordlist == NULL) {
    fprintf(stderr,"could not read a proper wordlist from %s. exiting.\n",wordlistfname);
    exit(1);
  }
  
  fprintf(stderr,"Printing TAB-separated pairs of words (from a list of %s %d words) whose edit distance is <= %d\n", wordlistfname, nw, cutoff);
  

  // calc_and_print_matrix(nw, wordlist);
  parse_matrix_and_print_pairs(PAIRFORMAT_SQL, nw, wordlist, cutoff);

  free_wordlist();
  exit(0);
}
