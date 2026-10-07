# ELI15: RHEL CoreOS and CentOS Stream CoreOS Configuration

[Technical guide: RHEL CoreOS configuration](README.md)

`rhel-coreos-config` is the build recipe and supporting material for RHEL CoreOS (RHCOS) and CentOS Stream CoreOS (SCOS). COSA consumes its manifests, package selections, image settings, filesystem overlays, and test definitions. The resulting main artifact is a bootable OSTree container, along with image artifacts. Think of the repository as the plan and ingredients; COSA performs the composition.

The output is a base operating system, not a complete OpenShift node image. OpenShift-specific components are added by a separate downstream `openshift/os` build. Package inputs and supported variants depend on the checked-out branch, and an RHCOS build also needs authorized package-source configuration whose setup depends on the environment.

For CoreOS issue work, this boundary helps place a failure: package selection, overlay, or Kola test issues may belong with these inputs or their build; an OpenShift-only image issue may be farther downstream. Check the branch and variant before comparing configurations, because supported variants and inputs are branch-dependent.

![How RHCOS configuration is composed into a base image for later use](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
