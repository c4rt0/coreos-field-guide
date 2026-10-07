# Fedora Package Maintenance: ELI15

[Technical README: Fedora Package Maintenance](README.md)

Fedora package maintenance connects package source to a built package and, for stable updates, to a Fedora repository. Dist-git holds the RPM spec and package-maintained source metadata. A maintainer retrieves declared source files and can check a local build; submitted builds are handled by Koji. Bodhi coordinates a stable update through `updates-testing` and its validation before promotion to the stable updates repository.

A useful analogy is a recipe, a bakery, and a store: package metadata says how to build, Koji produces the package, and the update process decides when it reaches users. On a CoreOS issue that depends on a Fedora package, this helps identify whether the evidence or fix belongs to package source, the build, or update validation instead of treating those as one event. The guide describes a common stable-update route, not every Fedora branch. Rawhide and branch policies may differ, while orphaning or retirement describes package ownership and lifecycle rather than a required build step. Check current branch policy before drawing conclusions.

![How Fedora package source becomes a tested stable update](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
