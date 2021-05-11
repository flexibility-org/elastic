#!/usr/bin/env bash

set -euo pipefail

wait_n_secs=30
max_attempts=4

attempt=1
until curl localhost:5601 || [[ ${attempt} -eq ${max_attempts} ]]
do
  printf "Kibana not yet responding (attempt %d/%d).\n" \
    "${attempt}" "${max_attempts}"
  printf "Waiting %d seconds before attempting one more time..\n" \
    "${wait_n_secs}"
  sleep "${wait_n_secs}s"
  attempt=$((attempt+1))
done

if [[ $attempt -eq $max_attempts ]]; then
  printf "Kibana did not respond after %d attempts" "${max_attempts}\n" >&2
  exit 1
fi

printf "Looks like Kibana is up and running!\n"
