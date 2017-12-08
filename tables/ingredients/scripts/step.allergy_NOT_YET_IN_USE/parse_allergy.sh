#!/bin/bash
# VERY IMPORTANT: 98 ingredients with more than 1 allergen, the consumers
# will really want to know if their "favourite" allergen is included
# later in the list.
# I mean:
# "may contain nuts" => important if you're allergic to nuts
# "may contain sellery, shrimps, strawberries and nuts" => ALSO important if you're allergic to nuts

if [ ! -f ../step3/tmp3.final ]; then
  echo "ERROR need ../step3/tmp3.final to continue"
  exit 1
fi


# line 2: EU law allergens, substitute __ALLERGY_NUTS__
cat ../step3/tmp3.final |\
  sed -e 's/kan innehålla spår av \(jordnöt\(\|ter\)\|valnötter\|nötter\)\.*/__ALLERGY_NUTS__/' |\
  cat > tmp4.01

cp tmp4.01 tmp4.final

wc -l tmp4.final

# filter out undesired words

exit 0

