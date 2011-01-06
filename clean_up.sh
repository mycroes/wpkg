#!/bin/bash
find . -type f -name '*~' -delete
test -x fromdos && fromdos *.xml
xml=$(which xmllint)
if [ -x ${xml} ] ; then
  ${xml} --noout *.xml
else
  echo xmllint not found - please use some other XML checker to validate...
  exit 1
fi
find . -name '*.xml' -print0 | xargs -0 sed -i 's/[ \t]\+$//g'
