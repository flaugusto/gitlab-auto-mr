#!/usr/bin/env bash

CI_COMMIT_REF_NAME="ALP-1686: CorrecaoButtonKey"
DESC=${CI_COMMIT_REF_NAME#*:}
MSG=`sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' <<< ${DESC}`
echo ${MSG}