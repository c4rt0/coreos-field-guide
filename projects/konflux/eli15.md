# ELI15: Konflux Artifact Build and Release Orchestration

[Technical guide: Konflux](README.md)

Konflux coordinates building, testing, and releasing software artifacts using Kubernetes resources. A useful analogy is a production line with a tracked batch: source and build definitions go in; configured pipelines can produce OCI images and evidence, and later checks decide what can move forward. For CoreOS-related work, it can orchestrate OS-container or related artifact builds. Tekton executes pipelines; integrations can group exact component image digests into a Snapshot and run configured tests against that fixed set.

A successful build is only a candidate, not proof that the artifact passed required integration tests and policy checks, was published, or reached machines. Konflux does not replace COSA, OSBuild, or product-specific tools that compose OS artifacts, define release streams, or manage node updates. Build, test, release, stream publication, and rollout are separate milestones.

For an issue, follow the artifact identity and status across those boundaries. A green build can coexist with an incomplete or untested Snapshot, a failed delivery run, or no node rollout. Checking the specific Snapshot and Release helps distinguish a build defect from test, policy, publishing, or update trouble.

![How Konflux builds an artifact and checks it before release](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
