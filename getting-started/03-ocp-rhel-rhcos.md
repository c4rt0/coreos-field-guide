# How OpenShift, RHEL, and RHCOS Fit Together

Image contents, product release availability, and supported node variants are
different questions; inspect the exact architecture and release payload.

*You know what Linux is and what containers are, but you don't understand
how these three things relate. This guide clears that up.*

---

## 1. What is RHEL?

**Red Hat Enterprise Linux (RHEL)** is an operating system: kernel, package
manager, system libraries, and user space. RHEL has its own version numbers,
such as **9.6** or **10.2**, and its release schedule is independent of
OpenShift's.

Think of RHEL as the foundation - the concrete slab your house is built on.

RHEL is a general-purpose OS. People run databases on it, web servers, SAP.
It has no opinion about containers or Kubernetes by itself.

---

## 2. What is OpenShift (OCP)?

**OpenShift Container Platform (OCP)** is Red Hat's Kubernetes distribution.
If you know Kubernetes - a system for running containers across many
machines - then OpenShift is that, plus extra features: a web console,
built-in CI/CD, an image registry, operator management.

Think of it as "managed Kubernetes with batteries included."

OCP has its own version numbers: **4.21**, **4.22**, etc. OpenShift minor
releases generally arrive on a separate cadence from RHEL; each minor can have
multiple patch releases (for example, `4.22.0`, `4.22.1`).

An OpenShift cluster is a group of machines (nodes). Control plane nodes
run the Kubernetes API and scheduler. Worker nodes run your containers.
Every node needs an operating system.

That's where RHCOS comes in.

---

## 3. What is RHCOS?

**RHEL CoreOS (RHCOS)** is the purpose-built host OS delivered with
OpenShift. It is used for control-plane nodes and commonly for worker nodes;
some supported configurations also allow RHEL worker nodes. RHCOS is not a
general-purpose, independently selected substitute for any host OS in a
cluster.

RHCOS is built in layers:

```
Layer 3:  OpenShift node software and cluster-managed operators
Layer 2:  CoreOS boot/provisioning and OS-management components
Layer 1:  RHEL-based kernel and user space
```

This is a conceptual stack, not a literal package or image layering recipe.
Exact components and OS-management implementation vary by release.

**Layer 1 - RHEL-based base.** Kernel, system libraries, and SELinux policy.
When describing a specific RHCOS image, identify its RHEL version from that
image rather than inferring it from the OpenShift minor alone.

**Layer 2 - CoreOS boot and OS management.** Includes first-boot provisioning
with Ignition and, where used, platform-specific Afterburn integrations.
OSTree/`rpm-ostree` and `pivot` are used in OSTree-backed MCO update flows;
exact image and update internals are release-specific.

**Layer 3 - OpenShift node and cluster software.** `kubelet` and CRI-O provide
node functionality. The Machine Config Operator (MCO) is a cluster operator
that coordinates machine configuration and node OS rollouts; it is not simply
another RPM installed as an RHCOS OS layer.

Some current RHCOS payload images also carry the OCI label
`containers.bootc=1`. That denotes bootc-compatible image metadata; it does
not make the OpenShift update path equivalent to a standalone bootc host.
OpenShift still coordinates managed-node rollouts through its cluster
operators.

---

## 4. How They Relate - The Nesting

```
+--------------------------------------------------+
|  OpenShift (OCP)                                  |
|  "The car"                                        |
|                                                   |
|  +--------------------------------------------+  |
|  |  RHCOS                                      |  |
|  |  "The engine"                               |  |
|  |                                             |  |
|  |  +--------------------------------------+   |  |
|  |  |  RHEL                                |   |  |
|  |  |  "The engine block"                  |   |  |
|  |  +--------------------------------------+   |  |
|  +--------------------------------------------+  |
+--------------------------------------------------+
```

You do not choose an arbitrary RHEL image for a node: OpenShift publishes
node OS images inside its release payload, and the cluster update
path selects and rolls them out. However, an OCP minor can publish multiple
RHCOS/RHEL variants. Do not assume one RHEL minor per OCP version; inspect the
actual payload and supported cluster configuration.

---

## 5. RHEL Variants by Release Payload

These public x86_64 payloads illustrate why a one-to-one version table is
misleading. The values below describe **image contents**, not the support
status or default selection of every variant. Each row links to an immutable
public release payload; inspect the target payload directly when investigating
a later patch release.

| Public OCP release payload | `rhel-coreos` image | `rhel-coreos-10` image |
|---|---|---|
| [`4.21.0-x86_64`](https://amd64.ocp.releases.ci.openshift.org/releasestream/4-stable/release/4.21.0#node-image-info) | RHCOS based on RHEL 9.6 | RHCOS based on RHEL 10.1 |
| [`4.22.0-x86_64`](https://amd64.ocp.releases.ci.openshift.org/releasestream/4-stable/release/4.22.0#node-image-info) | RHCOS based on RHEL 9.8 | RHCOS based on RHEL 10.2 |

The payload may contain more than one RHCOS image; that does not mean each
node runs both, or that both are supported in every configuration.

Product release availability is established separately by Red Hat's public
advisories: [RHBA-2026:1481](https://access.redhat.com/errata/RHBA-2026:1481)
announces `4.21.0` on 2026-02-03, and
[RHEA-2026:0449](https://access.redhat.com/errata/RHEA-2026:0449) announces
`4.22.0` on 2026-06-09. These are vendor release sources, not an inference
from a `4-stable` browser label or green CI jobs.

**Node-variant support must still be checked separately.** Consult the
[architecture-specific tested integrations](https://access.redhat.com/articles/4128421)
and the target release's vendor release notes for the supported default,
optional/preview variants, and migration paths. The
[x86_64 matrix](https://access.redhat.com/articles/4763741) is dated
2026-05-12 and covers through 4.21; it lists RHCOS 9.6 there. It does not
establish 4.22 variant support. This guide does not assert that the RHEL 10
variants above are supported choices merely because they exist in the payload.

---

## 6. Release Payloads

An OCP release is not a single binary. It is a **release payload** containing
many images that together make up the platform. The payload can contain
multiple RHCOS variants, for example the RHEL 9 and RHEL 10 images listed
above.

```bash
# Inspect public 4.22 payload contents, not a node-variant support matrix
$ oc adm release info quay.io/openshift-release-dev/ocp-release:4.22.0-x86_64

Images:
  NAME                           DIGEST
  aws-cloud-controller-manager   sha256:...
  cluster-autoscaler             sha256:...
  rhel-coreos                    sha256:...
  rhel-coreos-10                 sha256:...
  ...
```

Both `rhel-coreos` and `rhel-coreos-10` can appear in one release payload.

To pull out just the RHCOS image:

```bash
$ oc adm release info quay.io/openshift-release-dev/ocp-release:4.22.0-x86_64 \
    --image-for=rhel-coreos
quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:<payload-image-digest>
```

To inspect the other current RHEL major variant, request it separately:

```bash
$ oc adm release info quay.io/openshift-release-dev/ocp-release:4.22.0-x86_64 \
    --image-for=rhel-coreos-10
```

### The `--image-for` name gotcha

These names are payload-specific. In the examples above:

| Image variant | `--image-for=` |
|---|---|
| RHEL 9-based image | `rhel-coreos` |
| RHEL 10-based image | `rhel-coreos-10` |

Do not extrapolate this mapping to every historical release. List the actual
payload images first, then inspect the requested image's metadata or
`/etc/os-release` to confirm the exact RHEL minor version.

---

## 7. Release Streams

**GA/product releases** - Establish release availability and support using
Red Hat's advisories, release notes, and published life cycle. The release
browser's `stable` grouping is not itself an official GA or support declaration.

**Release candidates** - Pre-GA candidates may use `-rc.N` tags. They are not
the same as GA payloads; follow the product's release notes and support policy.

**CI/nightly** - Continuously built test payloads. They may be incomplete or
broken and are for engineering and CI, not production.

Browse all releases at:
- x86_64: https://amd64.ocp.releases.ci.openshift.org/
- aarch64: https://arm64.ocp.releases.ci.openshift.org/

Browser colors and test results describe CI status. A green job, an accepted
candidate, or a `stable` stream entry does not alone prove official GA,
recommended update availability for your cluster, or support for each node OS
variant. Confirm those with vendor documentation and the cluster's update
recommendations.

---

## 8. Common Beginner Mistakes

### Mistake 1: Using RHEL version in oc commands

```bash
# WRONG - 10.2 is a RHEL version, not an OCP release
$ oc adm release info quay.io/openshift-release-dev/ocp-release:10.2-x86_64
error: manifest unknown

# RIGHT - use an OCP version
$ oc adm release info quay.io/openshift-release-dev/ocp-release:4.22.0-x86_64
```

### Mistake 2: Confusing FCOS and RHCOS

FCOS = Fedora-based upstream distribution with its own Zincati update flow.
RHCOS = RHEL-based node OS published and managed with OpenShift.
They share some projects, such as Ignition and Afterburn, but product
configuration, supported features, and update controllers differ.

### Mistake 3: Thinking RHCOS can be installed standalone

RHCOS is delivered and supported as the OpenShift node OS, rather than as a
general-purpose standalone CoreOS distribution. For a standalone CoreOS host,
use Fedora CoreOS and its own installation/update documentation.

### Mistake 4: Wrong `--image-for` name

For a RHEL 10 image, request `--image-for=rhel-coreos-10`; the unsuffixed
`rhel-coreos` name refers to the RHEL 9 variant in the payloads shown here.

---

## 9. Practical Workflow

The most common task: find an OCP release and check what's inside RHCOS.

```bash
# 1. Get the RHCOS image from the release
IMAGE=$(oc adm release info \
  quay.io/openshift-release-dev/ocp-release:4.22.0-x86_64 \
  --image-for=rhel-coreos-10)

# 2. Check for a specific package
podman run --rm --entrypoint /usr/bin/rpm "$IMAGE" -qa | grep afterburn

# 3. Check the base OS version from this image
podman run --rm --entrypoint /usr/bin/cat "$IMAGE" /etc/os-release
```

Repeat with `--image-for=rhel-coreos` to inspect the RHEL 9.8 variant in this
payload. This identifies the contents of each published image; the cluster's
supported node configuration determines which image is used.

---

## Quick Reference

```
OCP   = OpenShift Container Platform  (the Kubernetes distribution)
RHEL  = Red Hat Enterprise Linux      (the base operating system)
RHCOS = RHEL CoreOS                   (RHEL-based OS + CoreOS/node components)
FCOS  = Fedora CoreOS                 (upstream community, no OCP)

OCP bundles RHCOS, which is built on RHEL.
The release payload can contain multiple RHCOS/RHEL variants; inspect it.

oc adm release info <release>                -- see all images
oc adm release info <release> --image-for=X  -- get one image
podman run --rm --entrypoint /usr/bin/rpm <image> -qa -- inspect image packages
```

## Public references

- [Red Hat 4.21.0 release advisory, issued 2026-02-03](https://access.redhat.com/errata/RHBA-2026:1481) and [4.22.0 release advisory, issued 2026-06-09](https://access.redhat.com/errata/RHEA-2026:0449)
- [OpenShift life cycle and RHCOS support relationship](https://access.redhat.com/support/policy/updates/openshift)
- [Architecture-specific tested integrations](https://access.redhat.com/articles/4128421) and [x86_64 matrix (dated 2026-05-12)](https://access.redhat.com/articles/4763741)
- [Vendor 4.22 release notes](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html/release_notes/) for feature and variant support
- [MachineConfigDaemon OS update design for OpenShift 4.22](https://github.com/openshift/machine-config-operator/blob/release-4.22/docs/MachineConfigDaemon.md)
- [Public OpenShift release payload tags on Quay](https://quay.io/repository/openshift-release-dev/ocp-release?tab=tags)
- [OpenShift release dashboards](https://amd64.ocp.releases.ci.openshift.org/) and [RHCOS image build source](https://github.com/openshift/os)
