# Glossary

Short definitions of terms used across the guide, each linked to the page that
explains it. Definitions describe how the terms are used in CoreOS work; the
linked upstream documentation is the authority.

| Term | Meaning | Read more |
|---|---|---|
| **Afterburn** | Service that reads cloud-provider metadata at boot (for example SSH keys and hostnames) and applies it to the node. | [dist-git](../projects/dist-git/README.md) |
| **bootc** | Tool that installs and updates a host from a bootable OCI container image. | [`rpm-ostree` and `bootc`](../getting-started/rpm-ostree-vs-bootc.md) |
| **bootupd** | Userspace tool that installs and updates bootloader data, which OSTree updates do not change on their own. | [bootupd](../projects/bootupd/README.md) |
| **Beaker** | Red Hat's internal hardware lab management system for tracking, provisioning, and power-controlling bare-metal machines. Used for some multi-arch builders (e.g. s390x). | [Multi-arch builders](../projects/fedora-coreos-pipeline/multi-arch-builders.md) |
| **BMC** (Baseboard Management Controller) | Embedded controller on a server that provides remote power control, console access, and virtual media mounting, independent of the host OS. | [Multi-arch builders](../projects/fedora-coreos-pipeline/multi-arch-builders.md) |
| **Bodhi** | Fedora's update system: it groups built packages into updates, collects feedback, and pushes them to stable repositories. | [Fedora packaging](../projects/fedora-packaging/README.md) |
| **Brew** | Red Hat's package build system for RHEL content, the counterpart of Fedora's Koji. | [dist-git](../projects/dist-git/README.md) |
| **Butane** | Human-friendly YAML format that is transpiled into an Ignition config. Runs on a workstation or in CI, not on the node. | [Butane](../projects/butane/README.md) |
| **build ID** | Version string COSA gives a build, for example `44.20260913.3.2` for FCOS. Pipelines use it to fetch and test the matching artifacts. | [COSA](../projects/coreos-assembler/README.md) |
| **buildfetch** | `cosa buildfetch` downloads metadata and selected artifacts of an existing build (for example the QEMU image) into a local COSA workspace, so it can be tested without rebuilding. Non-FCOS builds need `--url`. | [kola](../projects/kola/README.md) |
| **bump-lockfile** | Daily Jenkins job that regenerates RPM lockfiles for CoreOS streams by building the OS with latest packages, testing, and pushing the updated lockfiles. | [bump-lockfile](../projects/fedora-coreos-pipeline/bump-lockfile.md) |
| **ci-operator** | OpenShift CI tool that turns a repository's YAML configuration in `openshift/release` into build and test steps; Prow runs the generated jobs. | [openshift/release](../projects/openshift-release/README.md) |
| **Cincinnati** | Update-graph service. It tells Zincati which FCOS releases a node may update to. | [FCOS streams](../projects/fedora-coreos-streams/README.md) |
| **COPR** | Fedora's community build service; Packit uses it to build test RPMs from a pull request. | [Packit](tmt/packit.md) |
| **COSA** (CoreOS Assembler) | Container that builds CoreOS OS images and artifacts and bundles the test tools, including kola. | [COSA](../projects/coreos-assembler/README.md) |
| **denylist** | `kola-denylist.yaml` in a config repository: tests that are skipped, optionally only for some streams or architectures, often with an expiry date ("snooze"). | [kola](../projects/kola/README.md) |
| **dist-git** | Git repository that holds an RPM's spec file and source references, used to build the package. | [dist-git](../projects/dist-git/README.md) |
| **ELI15** | "Explain like I'm 15": the plain-language page each project has beside its technical guide. | [Contributing](../CONTRIBUTING.md) |
| **extensions** | Extra RPMs shipped alongside the OS image, such as the OpenShift extensions container, that can be layered onto a node. | [Node-image build](../projects/fedora-coreos-pipeline/build-node-image.md) |
| **external tests** | kola tests that live in a config repository (`tests/kola/`) rather than inside kola itself. Config-repo tests run in COSA are named `ext.config.<path>`. | [kola](../projects/kola/README.md) |
| **FCOS** | Fedora CoreOS: the community, auto-updating, Fedora-based CoreOS. | [Ecosystem guide](../getting-started/02-coreos-ecosystem.md) |
| **hermetic build** | A container build that uses only pre-downloaded packages (listed in a lockfile) instead of fetching from live repositories at build time. Ensures reproducibility and auditability. | [bump-lockfile](../projects/fedora-coreos-pipeline/bump-lockfile.md) |
| **FMF** | Flexible Metadata Format: the YAML-like metadata tmt reads to find tests and plans. | [TMT course](tmt/README.md) |
| **Ignition** | First-boot provisioning tool that runs in the initramfs and applies storage, files, users, and systemd units once. | [Ignition](../projects/ignition/README.md) |
| **initramfs** | Temporary early-boot environment loaded before the real root filesystem; Ignition runs here. | [Ignition](../projects/ignition/README.md) |
| **kola** | CoreOS integration test framework. It boots real OS images (QEMU or cloud) and runs tests against the running machine. | [kola](../projects/kola/README.md) |
| **Konflux** | Kubernetes-based build, test, and release platform used for some CoreOS images and tools. | [Konflux](../projects/konflux/README.md) |
| **Koji** | Fedora's package build system. | [Fedora packaging](../projects/fedora-packaging/README.md) |
| **lockfile** | File pinning exact package or artifact versions (for example `manifest-lock.*.json`, `artifacts.lock.yaml`) so builds are reproducible. | [Lockfile updates](../projects/coreos-assembler/auto-lockfile-updates/README.md) |
| **MachineConfig / MCO** | OpenShift objects (MachineConfig) and the operator (Machine Config Operator) that roll configuration and OS updates out to cluster nodes. | [openshift/os](../projects/openshift-os/README.md) |
| **MintMaker** | Konflux service that runs Renovate on registered repositories to propose dependency updates. | [Renovate and MintMaker](renovate-and-mintmaker.md) |
| **node image** | The OpenShift node OS container image: an RHCOS base plus OpenShift-specific content, built from `openshift/os`. | [openshift/os](../projects/openshift-os/README.md) |
| **nudge** | Konflux mechanism where a successful build updates a reference (for example an image digest) in a downstream repository, opening a pull request. | [tenants-config](../projects/tenants-config/README.md) |
| **NVR** | Name-Version-Release of an RPM, for example `afterburn-5.9.0-1.el9_6`. | [Getting started](../getting-started/README.md) |
| **OCI archive** | Container image saved as a single file (`.ociarchive`), used to move an OS image between build and test steps. | [kola](../projects/kola/README.md) |
| **OKD** | Community distribution of OpenShift; its nodes run SCOS. | [OCP, RHEL, and RHCOS](../getting-started/03-ocp-rhel-rhcos.md) |
| **oscontainer** | An OS image delivered as a container image. `kola run --oscontainer` boots a base image, runs `rpm-ostree rebase` onto the container image, and reboots before testing. | [kola](../projects/kola/README.md) |
| **OSBuild** | Image-building tool COSA uses to turn an OS tree into disk images (QEMU, metal, cloud, live ISO). | [COSA](../projects/coreos-assembler/README.md) |
| **OSTree** | Content-addressed system for versioned, bootable filesystem trees; the base of image-managed CoreOS updates. | [Ecosystem guide](../getting-started/02-coreos-ecosystem.md) |
| **Quadlet** | Systemd feature that generates a systemd service from a `.container` definition file, used to run podman containers as managed services. | [Multi-arch builders](../projects/fedora-coreos-pipeline/multi-arch-builders.md) |
| **overrides** | `manifest-lock.overrides.yaml`: package versions that differ from the stable Fedora repos, either `fast-track` (pull a fix early; removed automatically once it graduates) or `pin` (hold a version back; requires a `reason`). | [fedora-coreos-config](../projects/fedora-coreos-config/README.md) |
| **Packit** | Service that builds and tests pull requests (via COPR and Testing Farm) and automates downstream package updates. | [Packit](tmt/packit.md) |
| **payload** (release payload) | OpenShift release image listing every component image of a release, including the node OS images. | [OCP, RHEL, and RHCOS](../getting-started/03-ocp-rhel-rhcos.md) |
| **Petitboot** | Bootloader used on IBM POWER servers. Discovers boot entries from attached disks and network; replaces GRUB on ppc64le. | [Multi-arch builders](../projects/fedora-coreos-pipeline/multi-arch-builders.md) |
| **Prow** | Kubernetes-based CI system that runs OpenShift and many other jobs triggered from GitHub. | [openshift/release](../projects/openshift-release/README.md) |
| **Renovate** | Bot that detects outdated dependencies and opens update pull requests according to repository configuration. | [Renovate and MintMaker](renovate-and-mintmaker.md) |
| **RHCOS** | RHEL CoreOS: the RHEL-based CoreOS used for OpenShift nodes. | [OCP, RHEL, and RHCOS](../getting-started/03-ocp-rhel-rhcos.md) |
| **rpm-ostree** | Hybrid image and package system that manages OSTree deployments and can layer RPMs. | [`rpm-ostree` and `bootc`](../getting-started/rpm-ostree-vs-bootc.md) |
| **SCOS** | CentOS Stream CoreOS: the CentOS Stream-based CoreOS used by OKD. | [rhel-coreos-config](../projects/rhel-coreos-config/README.md) |
| **snooze** | A denylist entry with a `snooze` date: the test is skipped until that date, then runs again automatically. | [kola](../projects/kola/README.md) |
| **stream** | FCOS release channel: `stable`, `testing`, or `next` (plus development streams). | [FCOS streams](../projects/fedora-coreos-streams/README.md) |
| **stream metadata** | Published JSON describing the current artifacts for each stream, consumed by the download page and `coreos-installer`. | [FCOS streams](../projects/fedora-coreos-streams/README.md) |
| **Tekton** | Kubernetes-native pipeline engine used inside Konflux to run build, test, and release tasks. | [Konflux](../projects/konflux/README.md) |
| **Testing Farm** | Service that provisions test machines and runs tmt plans for Packit and other CI. | [Packit](tmt/packit.md) |
| **tmt** | Test Management Tool: runs tests and plans described with FMF, locally or in CI. | [TMT testing](../projects/tmt-testing/README.md) |
| **variant** | Configuration flag that tells COSA which flavor of the OS to build (e.g. `rhcos-9.8` vs `fedora-coreos`). Set per stream in `config.yaml`. | [bump-lockfile](../projects/fedora-coreos-pipeline/bump-lockfile.md) |
| **Zincati** | FCOS auto-update agent: asks Cincinnati for updates and tells rpm-ostree to stage them. | [FCOS streams](../projects/fedora-coreos-streams/README.md) |
