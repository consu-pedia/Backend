#!/bin/bash
# Copyright © Consupedia AB 2017
# Author: Frits Daalmans <frits@consupedia.com>
# Helper script for mitmdump output analysis
# This script makes a directory sub and puts the components of each flow
# in a subdirectory under sub/<flowname>
#
# Documentation: see parse_mitmdump.c source code
#
# Input: a directory with flow files (e.*), e.g. prepared by
# spit_mitm_chunks with the -s option.
#
# output: for each flow e.xyz, a directory sub/e.xyz/ with the following files:
# file req.000000.info with the HTTP command line (GET or POST)
# file req.000000 (mostly empty) with the body of the HTTP command.
#                 in case of a POST request, will contain the POST data.
# rawres.000001   raw resource (body of the response)
# errs            log file of parse_mitmdump
# tmp.curflow     the input flow e.xyz (can be deleted)


fl=$( ls e.* |sort )
mkdir -p sub
cd sub || exit 1

for f in $fl; do mkdir $f; cd $f; ls -l ../../$f;parse_mitmdump < ../../$f >& errs; cd ..;done

file -i e.*/rawres.* > ft

exit 0

