#!/usr/bin/env bash
# Requires: jq (https://jqlang.github.io/jq/download/)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$STAGE_DIR/lib/architecture_definition"
TEMPLATE="$OUTPUT_DIR/architecture.json.tpl"

usage() {
    cat <<EOF
Usage: $(basename "$0") -r ROOT_ID [-i true|false] [-d true|false] [-l true|false] [-s true|false] [-e true|false]

  -r ROOT_ID    Management group prefix, e.g. "contoso" (required)
  -i            Include Identity MG       (default: prompt)
  -d            Include Decommissioned MG (default: prompt)
  -l            Include Local MG          (default: prompt)
  -s            Include Sandboxes MG      (default: prompt)
  -e            Include Security MG       (default: prompt)

Examples:
  # Interactive
  ./scripts/setup-lib.sh -r contoso

  # Non-interactive (CI)
  ./scripts/setup-lib.sh -r contoso -i true -d false -l false -s true -e true
EOF
    exit 1
}

read_yn() {
    local answer
    read -r -p "$1 [Y/n]: " answer
    [[ -z "$answer" || "$answer" =~ ^[Yy] ]]
}

root_id=""
include_identity=""
include_decommissioned=""
include_local=""
include_sandboxes=""
include_security=""

while getopts ":r:i:d:l:s:e:" opt; do
    case $opt in
        r) root_id="$OPTARG" ;;
        i) include_identity="$OPTARG" ;;
        d) include_decommissioned="$OPTARG" ;;
        l) include_local="$OPTARG" ;;
        s) include_sandboxes="$OPTARG" ;;
        e) include_security="$OPTARG" ;;
        *) usage ;;
    esac
done

[[ -z "$root_id" ]] && usage

if ! [[ "$root_id" =~ ^[a-z][a-z0-9-]{1,30}[a-z0-9]$ ]]; then
    echo "Error: root_id must be 3-32 lowercase alphanumeric characters or hyphens." >&2
    exit 1
fi

command -v jq &>/dev/null || { echo "Error: jq is required. Install it from https://jqlang.github.io/jq/download/" >&2; exit 1; }

# Prompt for any flag not passed explicitly
[[ -z "$include_identity"       ]] && { read_yn "Include Identity MG?       (recommended for most orgs)"          && include_identity=true       || include_identity=false; }
[[ -z "$include_decommissioned" ]] && { read_yn "Include Decommissioned MG?  (add when retiring subscriptions)"   && include_decommissioned=true  || include_decommissioned=false; }
[[ -z "$include_local"          ]] && { read_yn "Include Local MG?           (Azure Local / HCI workloads only)"  && include_local=true           || include_local=false; }
[[ -z "$include_sandboxes"      ]] && { read_yn "Include Sandboxes MG?       (recommended for dev/test isolation)" && include_sandboxes=true      || include_sandboxes=false; }
[[ -z "$include_security"       ]] && { read_yn "Include Security MG?        (recommended for SOC/SIEM workloads)" && include_security=true       || include_security=false; }

# Build the JSON array of IDs to exclude
excluded_ids=()
[[ "$include_identity"       != "true" ]] && excluded_ids+=("$root_id-identity")
[[ "$include_decommissioned" != "true" ]] && excluded_ids+=("$root_id-decommissioned")
[[ "$include_local"          != "true" ]] && excluded_ids+=("$root_id-local")
[[ "$include_sandboxes"      != "true" ]] && excluded_ids+=("$root_id-sandboxes")
[[ "$include_security"       != "true" ]] && excluded_ids+=("$root_id-security")

if [[ ${#excluded_ids[@]} -eq 0 ]]; then
    excluded_json="[]"
else
    excluded_json=$(printf '%s\n' "${excluded_ids[@]}" | jq -R . | jq -s .)
fi

output_file="$OUTPUT_DIR/$root_id.alz_architecture_definition.json"

find "$OUTPUT_DIR" -name "*.alz_architecture_definition.json" -delete

sed "s/__ROOT_ID__/${root_id}/g" "$TEMPLATE" \
    | jq --argjson excluded "$excluded_json" \
         '.management_groups |= [.[] | select(.id as $id | ($excluded | index($id)) == null)]' \
    > "$output_file"

echo ""
echo "Generated: $output_file"
echo ""
echo "Copy the following block into your terraform.tfvars:"
echo ""
echo "  root_id = \"$root_id\""
echo "  management_groups_config = {"
echo "    include_identity       = $include_identity"
echo "    include_decommissioned = $include_decommissioned"
echo "    include_local          = $include_local"
echo "    include_sandboxes      = $include_sandboxes"
echo "    include_security       = $include_security"
echo "  }"
