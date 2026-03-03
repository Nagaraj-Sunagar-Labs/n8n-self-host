#!/usr/bin/env bash
set -euo pipefail

# Loads DUCKDNS_TOKEN and SUBDOMAIN from .env if present.
if [ -f ".env" ]; then
  # shellcheck disable=SC1091
  source ".env"
fi

: "${SUBDOMAIN:?SUBDOMAIN is required (e.g. n8nsunagarlabs)}"
: "${DUCKDNS_TOKEN:?DUCKDNS_TOKEN is required}"

# DuckDNS expects only subdomain in `domains`, not full FQDN.
curl -fsS "https://www.duckdns.org/update?domains=${SUBDOMAIN}&token=${DUCKDNS_TOKEN}&ip=" -o duck.log
echo "DuckDNS update response: $(cat duck.log)"
