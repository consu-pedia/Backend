#!/bin/bash
# Script to combine the output of several successive related flows,
# and present the result to be stored in a DB.
# This script is HIGHLY experimental. Also, current version is only for coop.se
# Copyright © Consupedia AB 2017
# Author: Frits Daalmans <frits@consupedia.com>
#
# TODO: this version doesn't yet know what to do when a product surfing session
# is spread over two or more flow echunks. But I'm working on it.
#
company="coop"
VERSION="0.5"

frags=$( ls e.* )
nexthint=""
curfrag=""
state=16
nextstate=16

echo "start process_product.sh version $VERSION"

while [ $state -ne 32 ]; do
  case "$state" in

"16") # reset
      echo "DBG state $state reset"
      rm -f tmp.html tmp.prodname tmp.imagename tmp.image tmp.json
      nextstate=0
    ;;

"0")  # initial
      echo "DBG state $state initial"

      if [ ! "$nexthint" = "" ]; then
        # begin looking at the hint
        echo "DBG UNIMP hint $nexthint (ignore)"
      fi
      if [ "$curfrag" = "" ]; then
        lookin="$frags"
      else
        lookin=$( echo "$frags" | sed -n '/'"$curfrag"'/,$p' )
      fi
      nl=$( echo "$lookin" | wc -l )
      echo "DBG initial lookin $nl frags"

      if [ "$lookin" = "" ]; then
        echo "DBG end of the line"
        nextstate=32
        break
      fi

      # loop over lookin frags for HTML
      curfrag=""
      for fr in $lookin; do
        hit=$( grep -l -m 1 '^GET.*/handla-online/varor/' sub/$fr/req.* 2>/dev/null )
        if [ ! "$hit" = "" ]; then
          curfrag=$( echo $hit | cut -d/ -f2 )
          nextstate=1
          break
        fi
      done # fr lookin loop
      if [ "$hit" = "" ]; then
        echo "DBG no (more) html found"
        nextstate=32
      fi
    ;;

"1") # HTML found in $curfrag req now parse it
      echo "DBG state $state HTML found in $curfrag"
      zcat sub/$curfrag/rawres.* > tmp.html
      hit=$( grep 'class=.ProductArticle-image' tmp.html )
      if [ "$hit" = "" ]; then
        nextstate=2
        break
      fi
      url=$( echo "$hit" | tr ' ' '\n' | grep 'src=' | sed -e 's@^src="//@@;s@"$@@;' )
      if [ "$url" = "" ]; then
        nextstate=2
        break
      fi
      echo "$url" > tmp.imagename
      prodname=$( echo "$url" | awk -F/ '{print $(NF-1)}' )
      echo "DBG prodname = $prodname"
      echo "$prodname" > tmp.prodname

      nextstate=3
    ;;

"3") # loop from curfrag to rest of lookin, find image and JSON
     # side-effect: set nexthint if we encounter another HTML

      echo "DBG state $state HTML found in $curfrag, now look for JSON and image"

     # modify lookin to start from curfrag
     lookin=$( echo "$lookin" | sed -n '/'"$curfrag"'/,$p' | tail -n +2 )
     if [ "$lookin" = "" ]; then
       echo "DBG state $state no more flows"
       nextstate=35
       break
     fi
     for fr in $lookin; do
       req=$( cat sub/$fr/req.*.info 2>/dev/null )
       if [ "$req" = "" ]; then continue; fi

       #DBG# echo "DBG fr $fr req = $req"

       ishtml=$( echo "$req" | tr -d '\r' | grep -c '^GET.*/handla-online/varor/.' )
       if [ $ishtml -gt 0 ]; then
         nexthint=$fr
         continue
       fi

       hasimage=$( echo "$req" | grep -c '^GET.*'"$url" )
       if [ $hasimage -gt 0 ]; then
         curfrag=$fr
         echo "DBG state $state found image in $curfrag, url $url"
         nextstate=7
         cp -p sub/$fr/rawres.* tmp.image
         break
       fi

       hasjson=$( echo "$req" | grep -c '^POST.*coop' )
       if [ $hasjson -gt 0 ]; then
         reqbody=$( cat sub/$fr/req.*[0-9] )
         echo "DBG reqbody $reqbody"
         hasjson=$( echo "$reqbody" | grep -c 'EntityType.:.Product' )
       fi

       if [ $hasjson -gt 0 ]; then
         curfrag=$fr
         echo "DBG state $state found json in $curfrag"
         nextstate=$(( $nextstate | 8 ))
         zcat sub/$fr/rawres.* > tmp.json.maybe
         # aha but is it the correct JSON?
         correctproduct=$( grep -c $prodname tmp.json.maybe )
         if [ $correctproduct -eq 1 ]; then
           echo "DBG correct product"
           mv tmp.json.maybe tmp.json
           break
         else
           echo "DBG wrong product, continue"
           continue
         fi
       fi

     done # fr lookin loop state 3
    ;;

"7") # loop from curfrag to rest of lookin, find JSON
     # side-effect: set nexthint if we encounter another HTML

      echo "DBG state $state HTML and image found in $curfrag, now look for JSON"

     # modify lookin to start from curfrag
     lookin=$( echo "$lookin" | sed -n '/'"$curfrag"'/,$p' | tail -n +2 )
     if [ "$lookin" = "" ]; then
       echo "DBG state $state no more flows"
       nextstate=39
       break
     fi
     for fr in $lookin; do
       req=$( cat sub/$fr/req.* 2>/dev/null )
       if [ "$req" = "" ]; then continue; fi

       #DBG# echo "DBG fr $fr req = $req"

       ishtml=$( echo "$req" | tr -d '\r' | grep -c '^GET.*/handla-online/varor/.' )
       if [ $ishtml -gt 0 ]; then
         nexthint=$fr
         continue
       fi

       hasjson=$( echo "$req" | grep -c '^POST.*coop' )
       if [ $hasjson -gt 0 ]; then
         reqbody=$( cat sub/$fr/req.*[0-9] )
         echo "DBG reqbody $reqbody"
         hasjson=$( echo "$reqbody" | grep -c 'EntityType.:.Product' )
       fi

       if [ $hasjson -gt 0 ]; then
         curfrag=$fr
         echo "DBG state $state found json in $curfrag"
         nextstate=$(( $nextstate | 8 ))
         zcat sub/$fr/rawres.* > tmp.json.maybe
         # aha but is it the correct JSON?
         correctproduct=$( grep -c $prodname tmp.json.maybe )
         if [ $correctproduct -eq 1 ]; then
           echo "DBG correct product"
           mv tmp.json.maybe tmp.json
           break
         else
           echo "DBG wrong product, continue"
           continue
         fi
       fi

     done # fr lookin loop state 7
     if [ $hasjson -eq 0 ]; then
       nextstate=27
     else
       nextstate=31
     fi
    ;; # end state 7


"11") # loop from curfrag to rest of lookin, find image
     # side-effect: set nexthint if we encounter another HTML

      echo "DBG state $state HTML and JSON found in $curfrag, now look for image"

     # modify lookin to start from curfrag
     lookin=$( echo "$lookin" | sed -n '/'"$curfrag"'/,$p' | tail -n +2 )
     if [ "$lookin" = "" ]; then
       echo "DBG state $state no more flows"
       nextstate=43
       break
     fi
     for fr in $lookin; do
       req=$( cat sub/$fr/req.* 2>/dev/null )
       if [ "$req" = "" ]; then continue; fi

       #DBG# echo "DBG fr $fr req = $req"

       ishtml=$( echo "$req" | tr -d '\r' | grep -c '^GET.*/handla-online/varor/.' )
       if [ $ishtml -gt 0 ]; then
         nexthint=$fr
         continue
       fi

       hasimage=$( echo "$req" | grep -c '^GET.*'"$url" )
       if [ $hasimage -gt 0 ]; then
         curfrag=$fr
         echo "DBG state $state found image in $curfrag, url $url"
         nextstate=$(( $nextstate | 4 ))
         cp -p sub/$fr/rawres.* tmp.image
         break
       fi

     done # fr lookin loop state 11
     if [ $hasimage -eq 0 ]; then
       nextstate=27
     else
       nextstate=31
     fi
    ;; # end state 11


"27") # store HTML and JSON in MongoDB
    echo "state $state: store HTML and JSON of $prodname in MongoDB document $prodname"
    mv tmp.json "$prodname"".json"
    plonk_in_mongodb localhost:coop:json "$prodname"".json"
    rc=$?
    mv tmp.html "$prodname"".html"
    bzip2 -9 "$prodname"".html"
    plonk_in_mongodb localhost:coop:json "$prodname"".html.bz2"
    rc=$?
    nextstate=16
    ;; # end state 27

"31") # store HTML, image and JSON in MongoDB
    echo "state $state: store HTML, image and JSON of $prodname in MongoDB document $prodname"
    mv tmp.json "$prodname"".json"
    plonk_in_mongodb localhost:coop:json "$prodname"".json"
    rc=$?
    mv tmp.jpg "$prodname"".jpg"
    plonk_in_mongodb localhost:coop:json "$prodname"".jpg"
    mv tmp.html "$prodname"".html"
    bzip2 -9 "$prodname"".html"
    plonk_in_mongodb localhost:coop:json "$prodname"".html.bz2"
    rc=$?
    
    nextstate=16
    ;; # end state 31



*)    echo "INTERNAL ERROR UNIMPLEMENTED STATE $state"
      exit 1
    ;;
  esac # $state

  echo "DBG $state -> $nextstate"
  state=$nextstate
done # main loop

echo "process_product.sh: exiting main loop"

exit 0

