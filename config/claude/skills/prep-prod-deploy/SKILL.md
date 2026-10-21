---
name: prep-prod-deploy
description: "Bailey's production deploy prep, only when he types /prep-prod-deploy or asks to prep or get ready for a prod deploy: what a deploy-production.yml dispatch would promote, what ships since the live release, which gates would refuse it, and the exact commands for him to run. Read-only; never dispatches."
---

# /prep-prod-deploy

Gets Bailey to the point of dispatching a production deploy himself, with no surprises at the gates.
Lives in `personal_packages/config/claude/skills/prep-prod-deploy`, symlinked into `~/.claude/skills/`.
Written for `hone-hq/hone`; the repo's skills govern and win where they say more: [[ops-deploys]]
(`references/production-promotion.md`), [[rollout-safety]], [[deploying-fast-safely]], [[live-systems]].

## Rules

- **Read-only.** Never dispatch, cancel or re-run `deploy-production.yml` or any Terraform run; never
  approve or reject the `production-terraform` environment; never write an `infra-applied-sha` marker;
  never post to Slack. The commands at the end are Bailey's to run.
- Invoking this skill is Bailey's ask for these production reads, and only these: GitHub (runs, logs,
  commit statuses, PRs), `https://app.hone.com/api/ready`, the view-only `mobius-production` kubectl
  context, and the `HoneDevtoolsReadOnly-019493640348` AWS profile. Never an `AWSAdministratorAccess`
  profile and never `mobius-production-admin` (it isn't on this machine; don't create it).
- Unknown is not pass. A gate you could not read is reported as **unknown** with what blocked it.

## 1. Live and in-flight

```bash
git fetch -q origin main
```

1. Any `deploy-production.yml` run queued or in progress? (`gh run list --repo hone-hq/hone --workflow
   deploy-production.yml --limit 5 --json databaseId,status,conclusion,createdAt,url`). If one is
   running, say so first: a new dispatch queues behind it (concurrency group `deploy-production`).
2. The live production SHA is the promoted SHA of the newest **successful** run, not its `headSha`
   (that is main at dispatch time). Read it from the `Select promoted SHA` job log:
   ```bash
   run=$(gh run list --repo hone-hq/hone --workflow deploy-production.yml --status success --limit 1 --json databaseId --jq '.[0].databaseId')
   job=$(gh run view "$run" --repo hone-hq/hone --json jobs --jq '.jobs[] | select(.name=="Select promoted SHA") | .databaseId')
   gh run view --job "$job" --repo hone-hq/hone --log | grep -oE 'Promoting [0-9a-f]{40} .*' | head -1
   ```
   Confirm against the cluster: `kubectl --context mobius-production -n mobius get deploy mobius-api
   -o jsonpath='{.spec.template.spec.containers[0].image}'`. If they disagree (a rollback, a failed
   roll), the cluster wins; say which.
3. `curl -s https://app.hone.com/api/ready`.

## 2. Candidate

Run the workflow's own selector from main's head, floored at the live SHA:

```bash
GITHUB_REPOSITORY=hone-hq/hone GITHUB_SERVER_URL=https://github.com \
  .github/scripts/select-attested-staging-sha.sh "$(git rev-parse origin/main)" <LIVE_SHA>
```

Stdout is `<sha> <staging_run_url>`; stderr lists each commit it skipped and why. If Bailey named a
commit, pass it as the first argument instead. Report how many main commits sit above the candidate
unattested, and why (staging hasn't rolled them yet: next roll window is `:07`/`:37`; quarantined;
evidence failed). A quarantined or failed head is worth a line of its own.

Candidate equal to live: nothing to ship. Stop there and say so (a `redeploy=true` restart only if
Bailey asks for one).

## 3. Gates the dispatch will run

Judge each as **pass**, **refuse** or **unknown**, the way `select_sha` and the Infra applied gate will.

1. **Infra applied.** Refuses when `infra/terraform/` changed between the applied marker and the
   candidate. Try the real check first:
   ```bash
   AWS_PROFILE=HoneDevtoolsReadOnly-019493640348 .github/scripts/production-terraform-preflight.sh <CANDIDATE>
   ```
   The read-only role usually lacks `ssm:GetParameter` on the marker. On AccessDenied, approximate it
   and label it approximate: take the head SHA of the newest successful `terraform.yml` run on main as
   the marker and check `git diff --name-only <that>..<CANDIDATE> -- infra/terraform/`. Also list any
   `terraform.yml` / `terraform-production.yml` run on main that is `waiting` (an apply waiting on a
   reviewer): if it covers the candidate's Terraform, the apply has to be approved first, by Bailey.
2. **Cloud mode.** `hone_cloud_enabled` in `infra/terraform/production.tfvars` must match between
   `origin/main` and the candidate (`git show <ref>:infra/terraform/production.tfvars | grep
   hone_cloud_enabled`).
3. **Cutover prerequisites.** `scripts/ci/production_prerequisites.py` needs the production admin
   context and Postgres, so it can't run here. Read `CUTOVERS` and `DATA_GUARDS` on `origin/main`; any
   entry whose `activates` SHA is in `<LIVE>..<CANDIDATE>` is flagged with its reader SHA and whether
   the live SHA already contains that reader (`git merge-base --is-ancestor`). No entry activating in
   range: pass, since the gate has nothing new to judge.
4. **Direction.** The candidate descends from live (`git merge-base --is-ancestor <LIVE> <CANDIDATE>`).

## 4. What ships

`git log --first-parent --format='%h %s' <LIVE>..<CANDIDATE>`: the count, and the PR numbers from
the subjects. Flag, by path (`git diff --name-only <LIVE>..<CANDIDATE>`) and PR body:

| Flag | How |
| --- | --- |
| Migrations | `packages/core/src/hone_core/migrations/` touched. Name each revision; destructive ones (drop, rename, `NOT NULL` on an existing column) get a line each. |
| Rollout-safety changes | PRs whose body has a filled `## Rollout impact`. Quote its promote/rollback notes and whether **observed** on staging was appended; missing observations go under needs-attention. |
| Terraform | `infra/terraform/` (ties to gate 1). |
| Deploy path | `.github/workflows/deploy-production.yml`, `.github/actions/roll-k8s-runtime`, `.github/scripts/*production*`: the deploy itself changes in this release. |
| MicroVM image / substrate | PRs that moved the MicroVM pin ([[rollout-safety]] `references/microvm-pins.md`). |
| Reverts | `Revert` subjects, and anything reverted later on main above the candidate. |

Read PR bodies with `gh pr view <n> --repo hone-hq/hone --json title,body,author,mergedAt`; fan out to
a subagent when there are more than ~15 PRs. Bailey's own PRs in the range go first.

## 5. Staging health

- The candidate's `staging/evidence` run (from step 2) and its conclusion.
- `staging/quarantine` on any commit between the candidate and main's head:
  `gh api repos/hone-hq/hone/commits/<sha>/status --jq '.statuses[] | select(.context|startswith("staging/"))'`.
- `https://stage.hone.com/api/ready`, and the newest `staging-long-tail.yml` runs.
- Datadog monitors in Alert or Warn for `env:staging` (Datadog MCP, read-only).
- When the range has a rollout-safety change: `scripts/ops/fleet-impact-scan.sh staging` and paste the
  relevant lines. The prod census needs `mobius-production-admin`; say it was not run.

## 6. Hand Bailey the brief

One short report, in this order:

1. **Live**: SHA, subject, when deployed. **Candidate**: SHA, subject, staging evidence link,
   N commits / M PRs.
2. **Gates**: one line each, pass / refuse / unknown, with the reason for anything not pass.
3. **Needs attention**: migrations, rollout-impact PRs, reverts, quarantines, staging alerts.
   Nothing worth flagging: say so.
4. **Commands**, one per `bash` block. Pin the candidate SHA so what he dispatches is what was
   reviewed (auto-selection advances if staging attests a newer commit in the meantime):
   ```bash
   AWS_PROFILE=<production profile> .github/scripts/production-terraform-preflight.sh <CANDIDATE>
   ```
   ```bash
   gh workflow run deploy-production.yml --ref main --repo hone-hq/hone -f sha=<CANDIDATE>
   ```
   and the rollback line, to keep at hand:
   ```bash
   gh workflow run deploy-production.yml --ref main --repo hone-hq/hone -f sha=<LIVE> -f allow_rollback=true
   ```
5. **Not verified**: every gate marked unknown or approximate, and the prod census.

Close with `mcp__ccd_turn__wrap_up`, asking whether to watch the deploy once he dispatches it.

## 7. After he dispatches (only if he says yes)

Watch read-only with one background `Bash` loop on the run's status (a deploy, not CI). Then, per
[[ops-deploys]]: the run's conclusion; `app.hone.com/api/ready`; the `mobius-api` image tag on
`mobius-production` equals the candidate; and one real session claimed, replied and settled
(`hone-trace`, [[investigating-engine-behavior]]). For a rollout-safety release, read three first
sessions on the new build ([[rollout-safety]] step 4). A failed run: read which job failed and why,
tell Bailey, and hand him the rollback line. Never re-run or roll back yourself.
