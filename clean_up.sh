#!/bin/sh
rm *~
fromdos *.xml
xmllint --noout *.xml
