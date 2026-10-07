# Contributing

This repository is an independent learning guide, not official product
documentation. Keep contributions focused on CoreOS-related projects and the
issues or workflows they explain.

## How Pages Are Organized

Each project under `projects/<name>/` follows the same pattern:

| File | Purpose |
|---|---|
| `eli15.md` | Plain-language orientation: what the project is for and where it sits in the CoreOS flow. Include a simple explanation chart with reader-friendly labels. |
| `README.md` | Technical guide: inputs, outputs, how it is built or tested, common failure points, and public references. |
| `<topic>.md` | Optional focused note for one workflow or failure mode, linked from the project `README.md`. |
| `<diagram>.drawio` + `<diagram>.png` | Diagram source and its rendered image, side by side. |

Cross-project material goes in `knowledge/`, and beginner material goes in
`getting-started/`. When you add a project, link it from the matching table in
the top-level `README.md`.

## Documentation

- Prefer topic-based filenames; put issue or pull-request identifiers inside
  the document when useful, not in place of a meaningful filename.
- Distinguish current behavior from historical issue notes, and state which
  project branch or source revision supports implementation-specific claims.
- Link authoritative public documentation or source. Do not present a local
  observation as a universal product guarantee.
- Include only material you are authorized to share. Do not add work logs,
  internal discussions, customer or infrastructure details, private tracker
  links, credentials, or files from a private archive.
- Do not rely on `.gitignore` as a security boundary. Review every proposed
  file before sharing it.
- Use a plain hyphen (`-`) rather than em or en dashes.

### Version-specific content

When behavior varies by product version, release, architecture, or branch:

- State the relevant version or condition next to the claim.
- Link an authoritative public source close to the claim.
- Do not add author-side freshness banners, checked-on dates, or source commit
  hashes just to record when or where the page was reviewed. Include an exact
  revision only when readers need it to reproduce or understand specific
  behavior.

Explain changes in user-facing terms, such as which release supports a feature,
rather than recording the author's verification process.

## Diagrams

Diagrams are rendered **locally only**. Never paste diagram sources into an
online renderer or converter (kroki.io, mermaid.ink, mermaid.live, the
diagrams.net web app, and similar): the service receives the full source.

1. Write the source next to the page it illustrates as a `.drawio` file. Do not
   use a top-level `diagrams/` directory.
2. Render it with the [draw.io desktop](https://github.com/jgraph/drawio-desktop/releases)
   CLI through the helper script, which handles both formats:

   ```bash
   scripts/render-diagrams.sh path/to/flow.drawio   # one diagram
   scripts/render-diagrams.sh                       # anything new or changed
   ```

3. Commit the source and the PNG together. They share a base name:
   `flow.drawio` produces `flow.png`.
4. Embed the PNG with a relative path and descriptive alt text, and link the
   source below it so readers can edit it:

   ```markdown
   ![What the diagram shows](flow.png)

   - [Diagram source](flow.drawio)
   ```

5. Run `scripts/render-diagrams.sh --check` to confirm every source has a PNG
   and every PNG has a source. CI runs the same check.

Avoid embedding environment-specific endpoints, hostnames, or live system
details in diagrams, and use plain hyphens in labels.

## Checks

Pull requests run two checks:

- **Links:** [lychee](https://lychee.cli.rs/) checks internal and external
  links. A weekly scheduled run catches links that break after merge.
- **Diagrams:** `scripts/render-diagrams.sh --check` verifies source and PNG
  pairs.

## Ownership and licensing

By contributing, you agree that your contributions are licensed under the
same terms as the rest of the repository: [CC BY-SA 4.0](LICENSE) for guide
content and diagrams, and the [MIT License](LICENSE-CODE) for scripts and CI
configuration.

Contribute only material whose ownership and permission to distribute are
clear. Explain upstream projects in your own words and link to their sources.
Do not copy text or images from sources whose license does not allow
redistribution; link to them instead.
