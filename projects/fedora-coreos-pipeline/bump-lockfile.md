# bump-lockfile: Daily RPM Lockfile Regeneration

**Plain-language explainer:** [bump-lockfile-eli15.md](bump-lockfile-eli15.md)

The `bump-lockfile` job regenerates RPM lockfiles for CoreOS streams daily.
It ensures the OS image tracks the latest packages from upstream repositories
while keeping builds reproducible.

## What lockfiles do

A lockfile (`manifest-lock.${arch}.json`) pins every RPM in the OS image to an
exact name-version-release-arch. Without it, a build would pull whatever is
newest in the repos at build time, making builds non-reproducible.

## Flow

The daily `bump-lockfiles.Jenkinsfile` (note the "s") triggers one
`bump-lockfile.Jenkinsfile` per stream in parallel. Each per-stream job:

1. Runs `cosa init` to set up a workspace from the stream's config repo/branch
2. Deletes existing lockfiles
3. Runs `cosa build --force` to build the OS with latest packages
4. Captures the generated `manifest-lock.generated.${arch}.json` as the new
   lockfile for each architecture
5. Runs tests (osbuild, kola, testiso)
6. Commits and pushes the updated lockfiles
7. Bumps `.tekton/trigger` to trigger a Konflux build

If packages have not changed for two days, the job pushes a timestamp-only
bump to keep the build ID current.

![FCOS vs RHCOS bump-lockfile flow comparison](bump-lockfile-fcos-vs-rhcos.png)

- [Diagram source](bump-lockfile-fcos-vs-rhcos.drawio)

## FCOS vs RHCOS lockfile layout

FCOS and RHCOS store lockfiles differently:

| Aspect | FCOS | RHCOS |
|---|---|---|
| Config repo | `coreos/fedora-coreos-config` | `coreos/rhel-coreos-config` |
| Branching model | One branch per stream (e.g. `testing-devel`) | All streams share `main` |
| Lockfile path | `manifest-lock.${arch}.json` (repo root) | `lockfiles/${stream}/manifest-lock.${arch}.json` |
| Package repos | Public Fedora repos | RHEL repos (subscription required) |

Both the `build-rootfs` script and the `konflux-rpm-lockfile` tool support
the `lockfiles/${stream}/` directory layout via a `get_lockfile_dir()` function
that first checks `lockfiles/${stream}/`, then falls back to the repo root.

## Stream selection

The `enable_bump_lockfile` pipecfg flag controls which streams get bump-lockfile
runs. It can be set globally and overridden per stream. Per-stream values take
precedence; streams without an override inherit the global default. When no
global flag is set, it defaults to `false` (no streams bumped).

The `bump_lockfile_streams()` helper in `utils.groovy` reads both levels and
returns the filtered list of stream names. Both `bump-lockfile.Jenkinsfile`
(STREAM dropdown) and `bump-lockfiles.Jenkinsfile` (cron trigger) use this
helper.

FCOS sets the global flag to `true` and disables it on production streams:

```yaml
enable_bump_lockfile: true

streams:
  stable:
    enable_bump_lockfile: false
  testing:
    enable_bump_lockfile: false
  testing-devel:
    type: development
```

RHCOS leaves the global default (`false`) and enables it per stream:

```yaml
streams:
  c10s:
    enable_bump_lockfile: true
  rhel-10.2:
    enable_bump_lockfile: true
  4.18-9.4:
    # no override, inherits global false - excluded
```

## Pipeline configuration

The job reads its config from `config.yaml` in the pipeline repo.

FCOS uses the defaults (one branch per stream, lockfiles at repo root):

```yaml
source_config:
  url: https://github.com/coreos/fedora-coreos-config

streams:
  testing-devel:
    type: development
```

RHCOS sets `lockfiles_subdir: true` at the `source_config` level so all
streams use the `lockfiles/${stream}/` layout:

```yaml
source_config:
  url: https://github.com/coreos/rhel-coreos-config
  ref: main
  lockfiles_subdir: true

streams:
  rhel-10.2:
    type: development
    variant: rhcos-10.2
```

The `utils.groovy` function `get_source_config_for_stream()` resolves
repo/branch overrides at runtime. The `lockfiles_subdir` flag is read from
`pipecfg.source_config.lockfiles_subdir` (repo-level, not per-stream).

## Key files

| File | Location | Role |
|---|---|---|
| `bump-lockfile.Jenkinsfile` | `jobs/` in fedora-coreos-pipeline | Per-stream lockfile bump job |
| `bump-lockfiles.Jenkinsfile` | `jobs/` in fedora-coreos-pipeline | Orchestrator: fans out to per-stream jobs |
| `utils.groovy` | fedora-coreos-pipeline root | Shared helpers including `get_source_config_for_stream()` |
| `konflux-rpm-lockfile` | `src/` in coreos-assembler | Converts RPM lockfiles to Konflux/hermeto format |
| `build-rootfs` | fedora-coreos-config (symlink) | Build script that reads lockfiles for hermetic builds |
| `config.yaml` | fedora-coreos-pipeline root | Stream definitions, source config, build parameters |

## Concurrency and retry

The job acquires two Jenkins locks before doing anything:

- `bump-${stream}`: prevents the build job from starting while lockfiles are
  being updated
- `bump-lockfile`: serializes all lockfile bumps (only one stream bumps at a
  time)

If the push fails because someone else committed to the branch since the job
started, the job re-triggers itself rather than failing.

## Public references

- [coreos/fedora-coreos-pipeline](https://github.com/coreos/fedora-coreos-pipeline)
- [coreos/fedora-coreos-config](https://github.com/coreos/fedora-coreos-config)
- [coreos/rhel-coreos-config](https://github.com/coreos/rhel-coreos-config)
