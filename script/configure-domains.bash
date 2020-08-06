#!/bin/bash

set -Eeuo pipefail

die() {
  echo "FATAL: $*" 1>&2
  exit 10
}

info() {
  echo "INFO: $*"
}

cluster_external_hostname() {
  kubectl get -n traefik svc traefik '--output=jsonpath={.status.loadBalancer.ingress[0].hostname}'
}

is_a_nodebalancer_hostname() {
  local -r name=$1

  [[ $name == *.nodebalancer.linode.com ]]
}

nodebalancer_id_from_hostname() {
  local -r name=$1

  linode-cli nodebalancers list --json |
    jq -r \
      ".[] | select( .hostname == \"${name}\" ) | .id"
}

nodebalancer_ipv4() {
  local -r nodebalancer_id=$1
  linode-cli nodebalancers view "$nodebalancer_id" --json |
    jq -r '.[0].ipv4'
}

nodebalancer_ipv6() {
  local -r nb_id=$1
  linode-cli nodebalancers view "$nb_id" --json |
    jq -r '.[0].ipv6'
}

hive_domains() {
  linode-cli domains list --tags=hive --json | jq '.[].id'
}

record_ids() {
  local -r domain_id=$1
  local -r type=$2

  linode-cli domains records-list "$domain_id" --json |
    jq -r ".[] | select( .name | IN(\"\", \"*\") ) | select( .type == \"${type}\" ) .id"
}

### MAIN

declare -r hostname=$(cluster_external_hostname)

if ! is_a_nodebalancer_hostname "$hostname"; then
  die "Unable to find external ip: $hostname is not a node balancer"
fi

declare -r nodebalancer_id=$(nodebalancer_id_from_hostname "$hostname")

declare -r ipv4=$(nodebalancer_ipv4 "$nodebalancer_id")
declare -r ipv6=$(nodebalancer_ipv6 "$nodebalancer_id")

info "IPv4: ${ipv4}"
info "IPv6: ${ipv6}"

declare -ra domain_ids=($(hive_domains))

for domain_id in "${domain_ids[@]}"; do
  for record_id in $(record_ids "$domain_id" A); do
    linode-cli domains records-update \
      --type=A \
      --target="${ipv4}" \
      "${domain_id}" \
      "${record_id}"
  done

  for record_id in $(record_ids "$domain_id" AAAA); do
    linode-cli domains records-update \
      --type=AAAA \
      --target="${ipv6}" \
      "${domain_id}" \
      "${record_id}"
  done
done

for domain_id in "${domain_ids[@]}"; do
  linode-cli domains records-list "${domain_id}"
done

echo DONE

# EOF
