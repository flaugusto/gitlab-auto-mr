#!/usr/bin/env bash
# Auto Merge Request creation script
# version 1.1

if [ -z "$PERSONAL_ACCESS_TOKEN" ]; then
  echo "GitLab Private Access Token not set."
  echo "Please set the GitLab Private Access Token as PERSONAL_ACCESS_TOKEN on GitLab runner variables."
  exit 1
fi

if [ $# -eq 0 ]; then
    echo "Lack of parameters. Usage: $0 <release|develop> TwikiName(Gatekeeper)"
    exit 1;
fi 

# Extract the CI_PROJECT_URL where the server is running, and add the URL to the APIs
[[ $CI_PROJECT_URL =~ ^https?://[^/]+ ]] && CI_PROJECT_URL="${BASH_REMATCH[0]}/api/v4/projects/"

# Get the Gatekeeper ID (passed as argument)
GK=`curl --silent "${BASH_REMATCH[0]}/api/v4/users?username=${2}" | jq --raw-output .[0].id`

# Patterns
feature="^feature-[A-z]{3}-[0-9]+_.+"
featMOP="^feature-[A-z]{3}_[0-9]{6}"
release="^release-[A-z]{3}_[0-9]{6}"

# Check branch pattern, set MR title accordingly
if [[ $CI_COMMIT_REF_NAME =~ $feature ]]; then
    MSG=${BASH_REMATCH[0]/feature-/}
    MSG=${MSG/_/: }
    DESC=${MSG#*:}
    MSG=`sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' <<< ${DESC}`
elif [[ $CI_COMMIT_REF_NAME =~ $featMOP ]]; then
    MSG=${BASH_REMATCH[0]/feature-/}
    MSG="Pacote ${MSG/_/ }"
elif [[ $CI_COMMIT_REF_NAME =~ $release ]]; then
    MSG=${BASH_REMATCH[0]/release-/}
    MSG="Entrega ${MSG/_/ }"
else
    MSG=$CI_COMMIT_REF_NAME
fi

# The description of our new MR, based on branch type passed as argument
BODY="{
    \"id\": ${CI_PROJECT_ID},
    \"source_branch\": \"${CI_COMMIT_REF_NAME}\",
    \"target_branch\": \"${1}\",
    \"title\": \"WIP: ${MSG}\",
    \"assignee_id\":\"${GK}\"";

if [ $1 = "develop" ]; then
    BODY="${BODY},
    \"remove_source_branch\": true";
elif [ $1 = "master" ]; then
    BODY="${BODY},
    \"remove_source_branch\": false";
fi

BODY="${BODY}
}";

# Require a list of all the merge request and take a look if there is already
# one with the same source branch
LISTMR=`curl --silent "${CI_PROJECT_URL}${CI_PROJECT_ID}/merge_requests?state=opened" --header "PRIVATE-TOKEN:${PERSONAL_ACCESS_TOKEN}"`;
COUNTBRANCHES=`grep -o "\"source_branch\":\"${CI_COMMIT_REF_NAME}\"" <<< ${LISTMR} | wc -l`;

# No MR found, let's create a new one
if [ ${COUNTBRANCHES} -eq "0" ]; then
    curl --silent -X POST "${CI_PROJECT_URL}${CI_PROJECT_ID}/merge_requests" \
        --header "PRIVATE-TOKEN:${PERSONAL_ACCESS_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "${BODY}";

    echo -e "\n\nOpened a new merge request: 'WIP: ${MSG}' and assigned to GK (${2}).\n";
    exit;
fi

echo "No new merge request opened";
