#!/bin/bash

if [ ! -f ../editing/editing.out ]; then
  ( echo "create_ingredientstable.sh: ERROR, first edit the ingredients lists with editing/edit_ingredientslists.sh" 1>&2 ) > /dev/null
  exit 1
fi

cp -p ../editing/editing.out inp

./process_ingredients.sh

exit 0

