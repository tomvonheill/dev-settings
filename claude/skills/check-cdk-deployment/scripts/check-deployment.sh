#!/usr/bin/env bash
set -euo pipefail

PROFILE="deploy"
REGION="us-west-2"

usage() {
  cat <<'EOF'
Usage: check-deployment.sh <search> [environment]

Check CodePipeline deployment status in the deploy account.

Arguments:
  search       Case-insensitive fuzzy match against pipeline names
  environment  Optional: sandbox, develop, qa, prod (filters to {ENV}-* prefix)

Examples:
  check-deployment.sh coredata              # all CoreDataWriter pipelines
  check-deployment.sh coredata sandbox      # SANDBOX-CoreDataWriter only
  check-deployment.sh bridge develop        # DEVELOP-*bridge* pipelines
  check-deployment.sh admin                 # all AdminPortal pipelines
EOF
  exit 1
}

[[ $# -lt 1 ]] && usage

SEARCH="$1"
ENV_FILTER="${2:-}"

# Normalize environment to uppercase
if [[ -n "$ENV_FILTER" ]]; then
  ENV_FILTER=$(echo "$ENV_FILTER" | tr '[:lower:]' '[:upper:]')
fi

# List all pipelines and fuzzy match
PIPELINES=$(aws codepipeline list-pipelines \
  --profile "$PROFILE" \
  --region "$REGION" \
  --query 'pipelines[*].name' \
  --output text 2>/dev/null | tr '\t' '\n' | grep -i "$SEARCH" || true)

# Filter by environment prefix if provided
if [[ -n "$ENV_FILTER" ]]; then
  PIPELINES=$(echo "$PIPELINES" | grep -i "^${ENV_FILTER}-" || true)
fi

if [[ -z "$PIPELINES" ]]; then
  echo "No pipelines found matching '$SEARCH'${ENV_FILTER:+ in $ENV_FILTER}"
  echo ""
  echo "Hint: try a broader search term. Pipeline names follow {ENV}-{ServiceName} pattern."
  exit 1
fi

COUNT=$(echo "$PIPELINES" | wc -l | tr -d ' ')
echo "Found $COUNT pipeline(s) matching '$SEARCH'${ENV_FILTER:+ in $ENV_FILTER}"
echo ""

# Process each matching pipeline
while IFS= read -r PIPELINE; do
  [[ -z "$PIPELINE" ]] && continue

  echo "═══════════════════════════════════════════════════════"
  echo "  $PIPELINE"
  echo "═══════════════════════════════════════════════════════"

  # Get pipeline state
  STATE_JSON=$(aws codepipeline get-pipeline-state \
    --name "$PIPELINE" \
    --profile "$PROFILE" \
    --region "$REGION" \
    --output json 2>/dev/null) || {
    echo "  ERROR: Could not fetch state for $PIPELINE"
    echo ""
    continue
  }

  # Parse and display each stage
  STAGE_COUNT=$(echo "$STATE_JSON" | python3 -c "import sys,json; print(len(json.load(sys.stdin)['stageStates']))" 2>/dev/null || echo "0")

  for ((i=0; i<STAGE_COUNT; i++)); do
    STAGE_INFO=$(echo "$STATE_JSON" | python3 -c "
import sys, json
from datetime import datetime, timezone

data = json.load(sys.stdin)
stage = data['stageStates'][$i]
name = stage['stageName']
status = stage.get('latestExecution', {}).get('status', 'Unknown')

# Status emoji
icons = {'Succeeded': '✅', 'InProgress': '🔄', 'Failed': '❌', 'Stopped': '⏹️'}
icon = icons.get(status, '❓')

print(f'{icon} {name}: {status}')

# Action details
for action in stage.get('actionStates', []):
    a_name = action.get('actionName', 'unknown')
    a_status = action.get('latestExecution', {}).get('status', 'Unknown')
    a_icon = icons.get(a_status, '❓')

    # Timestamp
    ts = ''
    last_ts = action.get('latestExecution', {}).get('lastStatusChange')
    if last_ts:
        if isinstance(last_ts, (int, float)):
            dt = datetime.fromtimestamp(last_ts, tz=timezone.utc)
        else:
            dt = datetime.fromisoformat(str(last_ts).replace('Z', '+00:00'))
        ts = dt.strftime('%Y-%m-%d %H:%M:%S UTC')

    print(f'    {a_icon} {a_name}: {a_status}  {ts}')

    # Error details for failed actions
    error = action.get('latestExecution', {}).get('errorDetails', {})
    if error:
        msg = error.get('message', '')
        if msg:
            # Truncate long messages
            if len(msg) > 200:
                msg = msg[:200] + '...'
            print(f'       ⚠️  {msg}')

    # External execution URL (e.g. CloudWatch logs link)
    ext_url = action.get('latestExecution', {}).get('externalExecutionUrl')
    if ext_url and a_status in ('Failed', 'InProgress'):
        print(f'       🔗 {ext_url}')

    # Entity URL (e.g. CodeBuild link)
    entity_url = action.get('entityUrl')
    if entity_url and a_status in ('Failed', 'InProgress'):
        print(f'       🔗 {entity_url}')
" 2>/dev/null) || STAGE_INFO="  Could not parse stage $i"

    echo "$STAGE_INFO"
  done

  echo ""
done <<< "$PIPELINES"
