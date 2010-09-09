#!/bin/sh
find . -type f -name '*~' -print0 | xargs -0 rm
fromdos *.xml
xmllint --noout *.xml
