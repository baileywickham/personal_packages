---
name: devbox
description: Use when the user wants to create, list, delete, resume, SSH into, forward ports for, or SNAPSHOT/BRANCH a "dev box" / devbox / microVM, or mentions devbox/devboxd. Covers driving the devbox control plane, warm snapshot/branch clones, connecting through the bastion, and running mailbox workers inside boxes.
---

# devbox

Manage long-lived dev boxes (Cloud Hypervisor microVMs) via the **`devbox`**
client CLI, which talks to a control plane (**`devboxd`**). All state lives in
`devboxd`; `devbox` is a thin client.

> Naming (renamed 2026-06): the **client is `devbox`**, the **daemon is
> `devboxd`** (runs `serve`/`controld`/`bastion`, plus host-local
> `start`/`stop`/`list`/`snapshot`/`branch`). The old `devboxctl` name is gone.

## Setup / connection

`devbox` must be on PATH. If not, build from the repo: `go build -o devbox
./cmd/devbox` (the daemon is `go build -o devboxd ./cmd/devboxd`).

It resolves the control plane in precedence order: `--controld` flag →
`devbox.json` (searched upward from cwd) → `$DEVBOXD_URL` / `$DEVBOX_AGENT_TOKEN`
→ localhost default. A repo usually carries `devbox.json` like
`{"controld_url": "http://HOST:8643"}` with the token in the environment.

Verify before acting: `devbox list`. `no token` → set `DEVBOX_AGENT_TOKEN` (or
add `"token"` to `devbox.local.json`). `connection refused` → wrong/unreachable
`controld_url`.

## Commands

| Goal | Command |
|---|---|
| List boxes (name, IP, status, size) | `devbox list` |
| Create | `devbox create <name> --github-user <login>` |
| Create (explicit key / sizing) | `devbox create <name> --ssh-key PATH --cpus N --memory G --disk G` |
| Delete (destroys the disk) | `devbox delete <name>` |
| Wake a hibernated box | `devbox resume <name>` |
| SSH into a box (through bastion) | `devbox ssh <name>` |
| Reconcile port forwards to devbox.json | `devbox sync <name>` |
| Manage agent hosts | `devbox host {list \| add <url> \| rm <url>}` |

Port forwards are **declarative**: list them under `"ports"` in `devbox.json`,
then `devbox sync <name>` applies them (and prunes any the box has that the
config no longer lists). There are no imperative `expose`/`unexpose` commands.
| **Snapshot a warm box** | `devbox snapshot <box> --as <name>` |
| **List snapshots** | `devbox snapshots` |
| **Branch (restore) a snapshot** | `devbox branch <new> --from <snapshot>` |
| **Delete a snapshot** | `devbox snapshot rm <name>` |

`--github-user` defaults from `$DEVBOX_GITHUB_USER` → `$GITHUB_USER` → `gh` CLI →
`git config github.user`; keys are fetched from `https://github.com/<login>.keys`.
`create` prints `created <name> on <host> (ssh dev@<ip> …)`.

Shell completion is built in (cobra): `source <(devbox completion zsh)` (or
bash/fish). Box-name args (delete/resume/ssh/sync/snapshot) and
snapshot-name args (`branch --from`, `snapshot rm`) complete live from the
control plane.

## Snapshot / branch — warm clones in ~seconds

The headline capability: keep a "golden" box with services already running
(e.g. FE + backend warm), **snapshot its live RAM + disk**, then **branch**
copies that resume the running processes — *with their in-memory state* — in
~1–3 s, instead of cold-booting and re-running setup. Use it to spin up a fresh
warm environment per task/branch.

```sh
devbox snapshot main --as golden     # pause main, capture RAM+disk, resume
devbox branch feat-x --from golden    # restore a NEW box from the snapshot
```

A branch boots from the snapshot's frozen RAM, so its processes/sockets/caches
continue exactly where the snapshot left off. devbox then resets the clone's
identity (machine-id, hostname, SSH host keys, MAC, IP) to its own and runs
`/etc/devbox/on-resume <branch>` in the guest if present — that hook is the
**only stack-specific seam** (e.g. `git checkout <branch>` + restart services);
devbox itself knows nothing about your stack.

**Constraints (current SSH-reset implementation):**
- **The snapshot's source box must be hibernated while branching.** A clone
  boots at the source's IP until reset; `branch` errors with "staging IP …
  occupied" if the source is still running. Treat the snapshotted box as a
  template you keep hibernated and branch from.
- Branches from the same snapshot **serialize** (each briefly occupies the
  staging IP during reset); they then run concurrently at distinct IPs.
- **File storage backend only** for snapshots. Each snapshot stores a full
  guest-RAM image on disk — reclaim with `devbox snapshot rm`.
- **RAM headroom:** each live box (template + every branch) costs its full guest
  RAM. A 3–4 GB host fits ~one box at a time; concurrent branching needs a
  bigger host.
- Snapshots are host-local; branching is pinned to the snapshot's host.

## SSH into a box

Boxes sit on a private NAT network — NOT reachable by their `192.168.x.x` IP.
Reach them **through the bastion (port 2222) by box NAME**. The bastion runs on
the `controld_url` host. Easiest: `devbox ssh <name>`. Manually:

```sh
ssh -J <controld-host>:2222 dev@<box-name>
```

Use the **box name** (not IP) — the bastion resolves it and tunnels to `:22`.
Your loaded SSH key must match one registered at create time (`ssh-add -l`).
`~/.ssh/config` shortcut:

```
Host <box-name>
  ProxyJump <controld-host>:2222
  User dev
```

## Running mailbox workers inside boxes

`mailbox` (the agent-orchestration CLI — see the **mailbox** skill) can run a
worker Claude agent *inside* a devbox microVM via its `devbox` runtime:

```sh
mailbox spawn <name> --runtime devbox --task "<task>"
```

The mailbox devbox adapter drives lifecycle through this same `devbox` client.
Config (env or `devbox.json`):
- `MAILBOX_DEVBOX_CLI` / json `devbox_cli` — how to invoke the client (e.g.
  `go run -C /path/to/devbox-mvp ./cmd/devbox`, or bare `devbox` on PATH).
- `MAILBOX_DEVBOX_BASTION` / `MAILBOX_DEVBOX_USER` / `MAILBOX_DEVBOX_HOME` /
  `MAILBOX_DEVBOX_BIN` — how to reach/operate the box (json: `bastion`,
  `box_user`, `box_home`, `bin`). The adapter talks tmux-over-SSH and scp-syncs
  message files. Combining warm **branch** + mailbox is the path to spinning up
  many ready-to-work agent boxes fast.

## Daemon / ops (devboxd)

`devboxd` runs the long-lived servers on the host(s): `serve` (per-host agent,
:8642), `controld` (control plane, :8643), `bastion` (:2222); `start`/`stop` are
systemd hooks for `devbox@<name>.service`. Host-local debug commands
`devboxd list|snapshot|branch` operate directly on agent state and **bypass the
control-plane registry** — use the `devbox` client for normal work; these are
for on-host debugging. Bring-up is `host-setup.sh` (see the repo's DEPLOY.md);
it builds both binaries, generates the agent token and the SSH reset key
(`/etc/devbox/reset_ed25519`, trusted by every box so the agent can reset a
clone's identity).

## Common errors

| Symptom | Cause / fix |
|---|---|
| `503 no host has capacity` | Host full (CPU/mem/disk). Smaller box, delete one, or `devbox host add` capacity. A branch also needs the snapshot's full RAM free. |
| `no token` | Set `DEVBOX_AGENT_TOKEN` or add `"token"` to `devbox.local.json`. |
| `connection refused` on list | `devboxd` not running / wrong `controld_url`. |
| `staging IP … occupied` on branch | The snapshot's source box is still running — hibernate it first (`devbox` has no stop; use the control plane's idle hibernation or stop the unit on the host). |
| SSH hangs / rejects key | Use box NAME not IP, key not loaded, or port 2222 not open to your IP. |
