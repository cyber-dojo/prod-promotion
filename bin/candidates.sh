#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed kosli jq

KOSLI_HOST="${KOSLI_HOST:-https://app.kosli.com}"
KOSLI_ORG="${KOSLI_ORG:-cyber-dojo}"
KOSLI_API_TOKEN="${KOSLI_API_TOKEN:-read-only-dummy}"
KOSLI_AWS_BETA="${KOSLI_AWS_BETA:-aws-beta}"
KOSLI_AWS_PROD="${KOSLI_AWS_PROD:-aws-prod}"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME}

    Overview:
      TODO

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    '')
      return 0
      ;;
    *)
      show_help
      exit 42
      ;;
  esac
}

candidates()
{
  check_args "$@"
#  diff="$(kosli diff snapshots "${KOSLI_AWS_BETA}" "${KOSLI_AWS_PROD}" \
#      --host="${KOSLI_HOST}" \
#      --org="${KOSLI_ORG}" \
#      --api-token="${KOSLI_API_TOKEN}" \
#       --output=json)"

  diff="$(cat "${ROOT_DIR}/docs/snapshot-diff.json")"
  from="$(echo "${diff}" | jq -r '.snappish1.snapshot_id')"
  to="$(echo "${diff}" | jq -r '.snappish2.snapshot_id')"

  echo "FROM: ${from}"
  echo "  TO: ${to}"

  local -r artifacts_length=$(echo "${diff}" | jq -r '.snappish1.artifacts | length')
  for a in $(seq 0 $(( ${artifacts_length} - 1 )))
  do
      artifact="$(echo "${diff}" | jq -r ".snappish1.artifacts[$a]")"
      name="$(echo "${artifact}" | jq -r '.name')"
      fingerprint="$(echo "${artifact}" | jq -r '.fingerprint')"
      echo "${name}"
      echo "${fingerprint}"
  done

}

candidates "$@"
