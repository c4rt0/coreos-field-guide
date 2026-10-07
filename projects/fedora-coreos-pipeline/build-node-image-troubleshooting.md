# Investigating Node-Image Build Failures

File naming and extraction logic can change with either repository, so check
the target branches when tracing a failure.

Use this checklist for a failed node-image or extensions-image pipeline. It is
general guidance, not a substitute for the target branch's configuration or
release procedure.

## Capture the failing context

- Record the pipeline revision, release, architecture, failing stage, and exact
  error from the same job run.
- Keep the candidate image digest and relevant build artifacts with the log.
- Identify whether the failure is in configuration selection, image build,
  metadata extraction, testing, or later publication.

## Check inputs before changing code

1. **Stream configuration:** confirm the selected entry enables the inputs and
   stages the job expects. Optional build arguments may be controlled by an
   explicit configuration flag.
2. **Build-argument file:** compare the filename constructed by the job with
   files present on the matching `openshift/os` branch. Check the naming
   convention across nearby release branches before changing shared code.
3. **Image contents:** when metadata extraction fails, inspect the candidate
   image manifest, layers, and actual file paths. Avoid assuming a fixed layer
   index still points to the desired files after a Containerfile change.
4. **Working comparison:** compare a passing and failing run only after aligning
   their pipeline revisions, stream configuration, architecture, and image
   inputs.

## Examples from public history

**Brew upload: `FileNotFoundError: ./meta.json`.** In July 2026,
[openshift/os#1946](https://github.com/openshift/os/pull/1946) added a second
`COPY --from=metadata /usr/share/buildinfo` layer to the node-image
Containerfile. The pipeline's `brew_upload()` extracted build metadata with
`oc image extract` using a `[-1]` layer index, which now pointed at a layer
without `meta.json`, so every node-image run failed at Brew upload.
[fedora-coreos-pipeline#1374](https://github.com/coreos/fedora-coreos-pipeline/pull/1374)
dropped the layer index, so `oc image extract` searches the full merged image
filesystem regardless of layer order. Lesson: a
Containerfile change in `openshift/os` can break the pipeline without any
pipeline change, and layer indexes are fragile.

**Build-argument file not found.** The job derives the file name from its
`RELEASE` parameter: `build-args-${RELEASE}.conf`, for example
`build-args-4.22-9.8.conf` for `RELEASE=4.22-9.8`. `openshift/os` release
branches name their files the same way (`build-args-4.22-9.8.conf`,
`build-args-4.22-10.2.conf`, `build-args-4.22-c10s.conf`). Before June 2026 the
job used `build-args-<rhel>-<ocp>.conf` (for example `build-args-9.8-4.22.conf`);
it switched to match the stream name together with
[openshift/os#1941](https://github.com/openshift/os/pull/1941). Older notes and
branches can still show the old order, so compare the constructed name with the
files on the exact `openshift/os` branch.

After isolating the difference, reproduce it on the affected branch and run the
relevant build and test stages. A passing neighboring release is useful
evidence, not proof that the affected branch uses identical inputs.

See the [node-image build flow](build-node-image.md), the public
[`openshift/os` sources](https://github.com/openshift/os), and the
[`fedora-coreos-pipeline` sources](https://github.com/coreos/fedora-coreos-pipeline).
