#!/bin/bash

# run this step before step.mark_quantities.sh and BEFORE splitting ingredients on the comma
# A lot of ingredients lists from the Coop set had 
# numbers with fractions separated by a comma and space, like this:
# Innehåller mer än 1, 5 mg fluorid per liter. Bör ej intas regelbundet av barn under sju år.
# Ekologisk äpplejuice. Juice från koncentrat. 1, 75 liter motsvarar juice från ca 2, 5 kg äpple.

# TODO: think of scenarios where this could go wrong.

cat |\
  sed -e 's/\([0-9]\), \([0-9]\)/\1.\2/g' |\
  sed -e 's/\([0-9]\),\([0-9]\)/\1.\2/g' |\
  cat

exit 0

