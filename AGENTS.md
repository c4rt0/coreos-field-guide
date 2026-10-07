# Using This Guide for CoreOS Issues

This repository is a selective context source, not the code repository being
changed and not a replacement for upstream documentation.

1. Establish the target repository, issue, branch or release, architecture,
   failing stage, and observed symptom. Ask for missing details when needed.
2. Find the target repository in the table below. If the issue is described by
   symptom rather than repository, use the issue map in `README.md`. Look up
   unfamiliar terms in `knowledge/glossary.md`, which links each term to its
   page.
3. Read that project's `eli15.md` for quick orientation, then its `README.md`
   for technical context. Open a focused supporting note only when it matches
   the failure. Do not read the entire guide by default.
   For a cross-repository failure, consult `knowledge/issue-investigation.md`;
   for dependency automation or CI artifact questions, use the matching
   cross-project guide linked from `knowledge/index.md`.
4. Verify implementation details in the target repository at the requested
   branch or commit. Version-sensitive guide text is a lead to check, not proof
   of current behavior.
5. Explain which facts came from this guide and which were verified in the
   target source. Keep proposed commands and tests scoped to the reported issue.

Historical notes and examples may not describe the current pipeline. Prefer the
owning project's source, tests, and documentation whenever they disagree with
this guide.

## Repository to Guide

| Target repository | Start with |
|---|---|
| `coreos/coreos-assembler` (COSA) | `projects/coreos-assembler/` |
| `coreos/coreos-assembler` - `mantle/kola`, or any `tests/kola/` directory | `projects/kola/` |
| `coreos/fedora-coreos-config` | `projects/fedora-coreos-config/` |
| `coreos/rhel-coreos-config` | `projects/rhel-coreos-config/` |
| `openshift/os` | `projects/openshift-os/` |
| `openshift/release` | `projects/openshift-release/` |
| `coreos/fedora-coreos-pipeline` | `projects/fedora-coreos-pipeline/` |
| `coreos/fedora-coreos-streams` | `projects/fedora-coreos-streams/` |
| `coreos/fedora-coreos-browser` | `projects/fedora-coreos-browser/` |
| `coreos/coreos-ci`, `coreos/coreos-ci-lib` | `projects/coreos-ci/` |
| `coreos/custom-coreos-disk-images` | `projects/custom-coreos-disk-images/` |
| `coreos/ignition` | `projects/ignition/` |
| `coreos/butane` | `projects/butane/` |
| `coreos/bootupd` | `projects/bootupd/` |
| `coreos/console-login-helper-messages` | `projects/console-login-helper-messages/` |
| `konflux-ci/update-artifacts-lockfile` | `projects/update-artifacts-lockfile/` |
| `konflux-ci/mintmaker`, `konflux-ci/mintmaker-renovate-image`, any `renovate.json` | `knowledge/renovate-and-mintmaker.md` |
| `konflux-ci/*` build, test, and release services | `projects/konflux/` |
| `fedora/infrastructure/konflux/tenants-config` (GitLab) | `projects/tenants-config/` |
| Fedora package repositories (`src.fedoraproject.org/rpms/*`) | `projects/fedora-packaging/` |
| CentOS Stream and RHEL package repositories (`gitlab.com/redhat/*/rpms/*`) | `projects/dist-git/` |
| Any repository with `.fmf/`, `plans/`, or `.packit.yaml` | `projects/tmt-testing/` and `knowledge/tmt/packit.md` |

## Diagrams and Local Processing

All guide content, including diagram sources, is processed locally.

- Never send diagram sources or page text to an online rendering or
  conversion service. That includes kroki.io, mermaid.ink, mermaid.live, and the
  diagrams.net web app. These services receive the full source of whatever
  they render.
- Render diagrams with `scripts/render-diagrams.sh`, which uses the local
  draw.io desktop CLI. If draw.io is not installed or cannot start, stop and
  report it; do not fall back to a web service.
- Keep each source next to its PNG with the same base name
  (`flow.drawio` -> `flow.png`) and run
  `scripts/render-diagrams.sh --check` after adding or removing a diagram.
- Follow the page and diagram conventions in `CONTRIBUTING.md` when editing.
