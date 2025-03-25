#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r script_dir

get_latest_tag() {
  local -r name=$1
  gh api \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/user/packages/container/${name}/versions" |
    tee /tmp/tag-lookup.json |
    jq --raw-output --from-file "${script_dir}/get-latest-tag.jq"
}

write_tag() {
  local -r tag=$1
  local -r file=$2

  yq eval --inplace \
    'select(.kind == "Deployment") | .spec.template.spec.containers[0].image = "ghcr.io/docwhat/website:'"${tag}"'", select(.kind == "Deployment"| not)' \
    "${file}"
}

yamlfile="docwhat-manifests/blog-${1:-staging}.yaml"
if ! [[ -f ${yamlfile} ]]; then
  echo "No such file: ${yamlfile}" 1>&2
  exit 2
fi

new_tag="$(get_latest_tag blog)"
declare -r new_tag
write_tag "${new_tag:?Unable to find a new tag}" "${yamlfile}"

# EOF
