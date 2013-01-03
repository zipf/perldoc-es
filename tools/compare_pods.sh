#!/bin/bash -x
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

if [ -f $POD ]
then
	POD_SOURCE=$POD
	POD_TARGET=$2
else
	POD_SOURCE="source/$POD"
	POD_TARGET="target/$POD"
fi

### Constants
COLS=$(tput cols)

### Checks
test -n "$POD"					|| exit 1
cd $DIR						|| exit 2
test -f $POD_SOURCE && test -f $POD_TARGET	|| exit 3

## Middle-point of screen
MEDIO=$[$COLS/2]

W_EN=$[$MEDIO*95/100]
W_ES=$[$MEDIO*100/100]

echo "Columnas: $COLS"
echo "Medio:    $MEDIO"
echo "EN:       $W_EN"
echo "ES:       $W_ES"
#exit

### Format pod with MANWIDTH width
MANWIDTH=$W_EN PERLDOC_POD2="" perldoc -d $POD.en $POD_SOURCE

### This encoding line is required because target/ pods
# don't go through the postprocess program, yet
echo -e "=encoding utf-8\n\n" > $POD.es.org
cat $POD_TARGET >> $POD.es.org
MANWIDTH=$W_ES PERLDOC_POD2="" perldoc -d $POD.es $POD.es.org

### Show side-by-side
diff -d -y -W $COLS $POD.{en,es} |less

### Delete temporal files
rm -f $POD.{en,es,es.org}
