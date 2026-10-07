# ELI15: OpenShift Node Operating-System Images

[Technical guide: OpenShift node images](README.md)

The `openshift/os` repository assembles the operating-system image used by OpenShift nodes. Think of it as a downstream finishing stage: it starts with a RHEL CoreOS base and adds OpenShift-specific content. A release branch chooses the base and inputs; the branch's own build process produces node-image variants, which CI tests and makes available to the OpenShift release process. The release payload records the image references it supports.

This is not the same build as the RHCOS base. `rhel-coreos-config` supplies that base without OpenShift components; `openshift/os` adds the downstream node-image content. Build mechanics vary by release branch, so a recipe from one branch may not describe another. Nor does producing an image itself update a running cluster: the Machine Config Operator coordinates managed node updates from release payloads.

For CoreOS issue work, trace a failure through base selection, final image assembly, CI, payload reference, and MCO rollout. That makes it easier to tell a base-OS problem from a node-image or deployment problem, and avoids assuming that a built artifact is already the image running on nodes.

![How an RHCOS base becomes an OpenShift node image and reaches a cluster](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
