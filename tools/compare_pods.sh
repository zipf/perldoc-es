#!/bin/bash
#
# Compare versions of pod documents.
# Joaquin Ferrero. 2012.07.25
#
# Given a pod filename, this program gets the versions 
# contained in source/ and target/ directories,
# converts them to manual pages (using perldoc)
# and shows diffs side-by-side.
#
# Run:
#	compare_pods.sh perl.pod
#

### Config
# Project directory
DIR=/home/explorer/perlspanish
### End config

### Arguments
POD=$1

### Constants
COLS=$(tput cols)

### Checks
test -n "$POD"					|| exit 1
cd $DIR						|| exit 2
test -f source/$POD && test -f target/$POD	|| exit 3

### Format pod with MANWIDTH width
MEDIO=$[$COLS/2-5]
MANWIDTH=$MEDIO perldoc -d $POD.en source/$POD

### This encoding line is required because target/ pods
# don't go through the postprocess program, yet
echo -e "=encoding utf-8\n\n" > $POD.es.org
cat target/$POD >> $POD.es.org
MANWIDTH=$MEDIO perldoc -d $POD.es $POD.es.org

### Show side-by-side
diff -y -W $COLS $POD.{en,es} |less

### Delete temporal files
rm -f $POD.{en,es,es.org}
