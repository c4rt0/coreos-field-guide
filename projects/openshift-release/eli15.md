# OpenShift Release CI: ELI15

[Technical README: OpenShift Release CI](README.md)

openshift/release stores shared CI configuration for OpenShift component repositories: build and test definitions, generated Prow jobs, and reusable or shared configuration. For component CI, maintainers usually describe what to build and test in `ci-operator` configuration. That source configuration is translated into Prow job definitions. Prow runs those jobs, while `ci-operator` performs the configured builds and tests.

Think of the repository as a set of assembly instructions for CI, not the component's source code. When a CoreOS-related issue is about how a component is built, tested, or promoted in OpenShift CI, this distinction helps locate the right configuration and review the generated job changes without confusing a CI adjustment with a code fix. The primary configuration is generally the place to edit; generated job YAML should not usually be changed by hand. Reusable workflows live in the step registry, while promotion and mirroring are separate concerns: promotion may be described in a component config, but mirroring destinations are managed separately. Ownership rules also differ across parts of the repository.

![How OpenShift CI settings become jobs that build and test components](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
