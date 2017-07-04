#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


/* Takes a list of words (ingredienser) and calculates Levensh'tein distance matrix 
   output: upper right distance matrix, like this:
   1 2 3
     4 5
       6

   If the difference in lengths of the 2 strings is greater or equal than CUTOFF, then skip the calculation and just return CUTOFF (because the purpose of the algo is to find strings that are like each other)
 */
/* #define CUTOFF	10 */
#define CUTOFF	6

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
    if (matrix==NULL) exit(1);
    for(x=0;x<s2len+1;x++){ matrix[x] = (unsigned int *) malloc((s1len+1) * sizeof(unsigned int)); if (matrix[x] == NULL) {exit(1);}; memset(matrix[x], 0x00, (s1len+1) * sizeof(unsigned int)); }
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


int main(int argc, char *argv[])
{
  init("wordlist");
  if (wordlist == NULL) {
    fprintf(stderr,"could not make a proper wordlist. exiting.\n");
    exit(1);
  }

  calc_and_print_matrix(nw, wordlist);

  free_wordlist();
  exit(0);
}

