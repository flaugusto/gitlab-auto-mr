#!/usr/bin/env bash

feature="^feature-[A-z]{3}-[0-9]+_.+"
featMOP="^feature-[A-z]{3}_[0-9]{6}"
release="^release-[A-z]{3}_[0-9]{6}"


# Check branch pattern, set MR title accordingly
if [[ $CI_COMMIT_REF_NAME =~ $feature ]]; then
    MSG=${BASH_REMATCH[0]/feature-/}
    MSG=${MSG/_/: }
elif [[ $CI_COMMIT_REF_NAME =~ $featMOP ]]; then
    MSG=${BASH_REMATCH[0]/feature-/}
    MSG="Pacote ${MSG/_/ }"
elif [[ $CI_COMMIT_REF_NAME =~ $release ]]; then
    MSG=${BASH_REMATCH[0]/release-/}
    MSG="Entrega ${MSG/_/ }"
else
    MSG=$CI_COMMIT_REF_NAME
fi
echo "test"

echo -e "\n\nOpened a new merge request: 'WIP: ${MSG}' and assigned to you.";