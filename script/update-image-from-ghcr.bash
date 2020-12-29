#!/usr/bin/env bash

set -Eeuo pipefail

# This only works because currently, ghcr.io keeps the tag list
# in the order created.

get_latest_tag() {
  local -r name=$1
  curl \
    -sS \
    -X GET \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://ghcr.io/v2/${name}/tags/list" |
    jq -r '([.tags[] | select(startswith("sha-"))])[-1]'
}

write_tag() {
  local -r tag=$1
  local -r file=$2

  yq eval --inplace \
    'select(.kind == "Deployment") | .spec.template.spec.containers[0].image = "ghcr.io/docwhat/blog:'"$tag"'", select(.kind == "Deployment"| not)' \
    "$file"
}

write_tag "$(get_latest_tag docwhat/blog)" docwhat-manifests/blog-staging.yaml

# EOF
