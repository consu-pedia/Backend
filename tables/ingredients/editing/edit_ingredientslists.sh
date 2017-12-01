#!/bin/bash


if [ ! -d ../glue/gluedir ]; then
  ( echo "editing: ERROR, first glue the records of the shops together with glue/glue_shops_together.sh" 1>&2 ) > /dev/null
  exit 1
fi

cp -p ../glue/gluedir/raw_ingredientslists inp

./process_ingredients.sh

exit 0

