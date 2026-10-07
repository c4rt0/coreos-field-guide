# Fedora CoreOS Builds Browser - ELI15

**Technical guide:** [README.md](README.md)

The Builds Browser is a catalog for looking up Fedora CoreOS builds that have
already been published. It does not build, repair, or release an image. Think
of it like a library catalogue: it helps you find which build and architecture
are available and points to information about that build.

When a machine or image issue is reported, the browser can help answer basic
questions such as whether a particular build appears in the published list and
where its artifacts are linked. It only shows the information exposed by the
published metadata; it cannot explain every reason an artifact is missing or
why a build failed.

This boundary is useful during troubleshooting. If the browser page or one of
its images is broken, that does not by itself mean the CoreOS build pipeline
failed. Investigate the browser's own data loading separately from the system
that produced and published the build.

![How published build metadata becomes a browsable list of builds and artifacts](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
