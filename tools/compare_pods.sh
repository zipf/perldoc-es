#!/bin/bash
#
# Compare versions of pods documents.
# Joaquin Ferrero. 2012.07.25
#
# Given a pod filename, this program
# get it form source/ and target/ directories,
# convert them to manual pages (with perldoc)
# and show the diffs face to face.
#

COLS=$(tput cols)
POD=$1

test -n "$POD"                             || exit;
cd ~/perlspanish                           || exit
test -f source/$POD && test -f target/$POD || exit;

# Formating pod with MANWIDTH width
MEDIO=$[$COLS/2-5]
MANWIDTH=$MEDIO perldoc -d $POD.en source/$POD

# This encoding line is necessary because target/ pods
# don't pass by postprocess program, yet
echo -e "=encoding utf-8\n\n" > $POD.es.org
cat target/$POD >> $POD.es.org
MANWIDTH=$MEDIO perldoc -d $POD.es $POD.es.org

# Show face to face
diff -y -W $COLS $POD.{en,es} |less

# Fin: Delete temporal files
rm $POD.{en,es,es.org}
