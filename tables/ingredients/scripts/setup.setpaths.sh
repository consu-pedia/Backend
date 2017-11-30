PATH_TO_LEVENSHTEIN=/home/frits/github/git/Backend/Backend/toolkit/levenshtein

# DONT BOTHER export PATH_TO_LEVENSHTEIN
# it's not easy to source it as part of the chain

for program in levenshtein printmindist; do
  if [ ! -L $program ]; then
    ln -s $PATH_TO_LEVENSHTEIN/$program ./$program
  fi
done
