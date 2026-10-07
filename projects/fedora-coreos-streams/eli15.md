# ELI15: Fedora CoreOS Release Streams

`fedora-coreos-streams` is a reviewed record of Fedora CoreOS releases: it tracks release issues plus metadata for downloadable artifacts, allowed updates, and release notes. A useful analogy is a catalogue beside a route map. The stream metadata catalogue tells installers what release artifact exists for a platform; update metadata describes which release transitions an existing system may take.

The repository does not build the OS or update machines. The pipeline prepares candidate artifacts, while stream metadata is generated and reviewed, then release automation publishes merged data for clients. Download information is not the same as an update offer: Zincati follows the update graph for a machine's architecture and stream, and rollout state or transition rules can affect what it is offered.

That distinction matters in CoreOS issue work. If an image can be downloaded but a host is not offered an upgrade, check the update path and the host's selected stream rather than assuming the catalogue is broken. Likewise, a release issue or metadata change is part of coordinating publication, not proof that all clients already see it. Keep architecture, platform, stream, and release context attached to the report.

**Technical guide:** [README.md](README.md)

![How a Fedora CoreOS release is published and offered to eligible machines](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
