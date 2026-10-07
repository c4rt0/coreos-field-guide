# Cross-project Knowledge

Use `knowledge/` for concepts and investigation patterns that apply across
multiple CoreOS projects. Repository-specific configuration and procedures stay
under [`projects/`](../projects/).

## Start here

- [Glossary](glossary.md) defines CoreOS terms and links each to the page
  that explains it.
- [Tracing a CoreOS issue across repositories](issue-investigation.md) follows
  evidence from inputs and builds through tests, publication, and runtime.
- [Renovate and MintMaker](renovate-and-mintmaker.md) explains how dependency
  update automation fits into CoreOS work.
- [Testing and gating](testing-and-gating.md) distinguishes metadata checks,
  source tests, package tests, and downstream release gates.
- [TMT and FMF course](tmt/README.md) is the hands-on guide to test metadata and
  running TMT plans.
- [Packit, TMT, and gating across CoreOS repos](tmt/packit.md) compares the
  public source-test, candidate-RPM, release-automation, and gating paths.

Read only the cross-project guide relevant to the issue, then follow its links
to the owning project's technical guide and source.
