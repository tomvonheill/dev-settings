---
name: check-cdk-deployment
description: Check AWS CodePipeline deployment progress for a project in the deploy account. Use when the user asks about deployment status, wants to check if a deploy succeeded, or monitor a rollout.
allowed-tools: Bash
argument-hint: <search> [environment] — e.g. "coredata sandbox", "bridge develop", "admin"
---

# Check CDK Deployment

Check CodePipeline deployment status in the AWS deploy account (`--profile deploy`, account 700154229199).

## Usage

```bash
~/.claude/skills/check-cdk-deployment/scripts/check-deployment.sh <search> [environment]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `search` | Yes | Case-insensitive fuzzy match against pipeline names |
| `environment` | No | Filter to environment: `sandbox`, `develop`, `qa`, `prod` |

## Examples

```bash
# Check all CoreDataWriter pipelines across environments
~/.claude/skills/check-cdk-deployment/scripts/check-deployment.sh coredata

# Check CoreDataWriter in sandbox only
~/.claude/skills/check-cdk-deployment/scripts/check-deployment.sh coredata sandbox

# Check bridge deployments in develop
~/.claude/skills/check-cdk-deployment/scripts/check-deployment.sh bridge develop

# Check AdminPortal across all envs
~/.claude/skills/check-cdk-deployment/scripts/check-deployment.sh admin
```

## Output

Shows each matching pipeline with:
- Stage-by-stage status (Source, Build, UpdatePipeline, Assets, {ENV})
- Action-level details with timestamps
- Error messages for failed actions
- Links to CloudWatch logs / CodeBuild for failed or in-progress actions

## Pipeline Naming Convention

Pipelines follow the pattern `{ENV}-{ServiceName}`:
- `SANDBOX-CoreDataWriter`
- `DEVELOP-AdminPortal`
- `PROD-LegacyNextgenBridge`
- `CoreDataSchemas-{ENV}-*` (some pipelines use a different prefix pattern)

## Prerequisites

- AWS SSO session active for the `deploy` profile
- If session expired, run: `aws sso login --profile deploy`
