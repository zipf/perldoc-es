#!/bin/bash
#
# Muestra un pod añadiéndole antes la línea =encoding utf-8
#
# Joaquin Ferrero. 2012.09.05
#
# Run:
#	ver_pods.sh perl.pod
#

### Config
# Project directory
DIR=/home/explorer/Documentos/Desarrollo/perlspanish-work
### End config

### Arguments
POD=$1

if [ -f $POD ]
then
	POD_TARGET=$POD
else
	POD_TARGET=$DIR/target/$POD
fi

### Constants
COLS=$(tput cols)

### Checks
test -n "$POD"		|| exit 1
#cd $DIR			|| exit 2
test -f $POD_TARGET	|| exit 3

### This encoding line is required because target/ pods
# don't go through the postprocess program, yet
$(egrep -q '^=encoding' $POD_TARGET)
if [ $? -eq 1 ]
then
	echo -e "=encoding utf-8\n\n" > $POD.es
fi
cat $POD_TARGET >> $POD.es

### Show
perldoc $POD.es

### Delete temporal files
rm -f $POD.es
