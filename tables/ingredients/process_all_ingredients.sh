#!/bin/bash
# This script is a successor for the process_ingredients.sh scripts for
# each shop.

# It can be subdivided in the following conceptual steps:


# PHASE 1: NORMALIZATION
# for each shop, its original input data is massaged so that it forms
# a comma separated ingredients list, one ingredients list (=product)
# per line.
# The programs to get it normalized can be different for each shop,
# have slightly differing steps etc.

# for shop in oldcoop; do
#   cd $shop; ./process_ingredients.sh; cd ..
# done


# PHASE 1.5: GLUING
# I see no reason why we can't glue all of the records together now already.
# export them (end of phase 1) and glue them at beginning of the phase 2 script.

# cd glue; ./glue_shops_together.sh; cd ..


# PHASE 2: EDITING
# The steps in this phase are complicated editing steps (with sed) to
# extract quantities, units, and lists of vitamins and E-numbers.
# There is also one step, for blacklists/whitelists, that is interactive

# cd editing; ./edit_ingredientslists.sh; cd ..

# PHASE 3: TABLE SPLITTING
# The steps in this phase are complicated scripts that split the
# original ingredients lists to form an SQL table of ingredients and a
# product_contents SQL table.

# many steps do not change the original products file, but instead
# operate on the derived ingredients table.


# PHASE 4: DATA CLEANUP  
# There are far too many ingredients, almost all the same.
# Use the Levenshtein algorithm to find the closest ones, then let a
# human operator edit the result.

exit 0


