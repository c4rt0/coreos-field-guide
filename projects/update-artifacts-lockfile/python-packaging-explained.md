# Python packaging: from script to installable CLI tool

Examples use the public `konflux-ci/update-artifacts-lockfile` package. The small `main()` example below explains the original refactor,
not the complete current command-line parser.

## What this is called

**Packaging** - specifically, creating a Python distribution package.

The formal name is "creating a Python distribution package." The informal name is "packaging a script." The pattern used here combines a `src/` layout, `pyproject.toml`, and installation with `pipx`. PEP 517 defines the build-backend interface, PEP 518 defines build requirements, and PEP 621 defines project metadata; they do not mandate `src/` or `pipx`.

## What changes and why

| Before (loose script) | After (packaged tool) |
|---|---|
| Single file, run with `python script.py` | Installed command, run as `update_artifacts_lockfile` |
| User must manually install `ruamel.yaml`, `requests` | Dependencies installed automatically |
| Copied between repos (cosa, hermeto, image) | Single source of truth, versioned releases |
| No entry point - relies on `if __name__ == "__main__":` | Declared entry point in `pyproject.toml` |
| No version - "whatever is in main" | Tagged releases (`v0.1.0`, `v0.2.0`, ...) |

## Package pieces and the uv lockfile

### 1. `src/` layout

```
src/
└── update_artifacts_lockfile/
    └── __init__.py   ← the script logic lives here
```

Why `src/`? Convention. Keeps your package code separate from project-level files (README, pyproject.toml, tests). Without it, Python can sometimes import your local directory instead of the installed package, causing hard-to-debug issues.

Why `__init__.py`? It makes this a regular Python package and, here, contains its code. Python also supports namespace packages without this file, so its absence does not universally make a directory unimportable.

### 2. `pyproject.toml`

The modern replacement for `setup.py`. Declares:
- Package name and version
- Python version requirement
- Runtime dependencies
- The entry point (see below)
- Build system

The critical section:
```toml
[project.scripts]
update_artifacts_lockfile = "update_artifacts_lockfile:main"
```
This says: "create a CLI command called `update_artifacts_lockfile` that calls the `main()` function inside the `update_artifacts_lockfile` package." Without this, `pipx install` would install the code but create no command.

### 3. `main()` function

The original script ended with:
```python
if __name__ == "__main__":
    artifacts_lock_filename = sys.argv[1] if len(sys.argv) > 1 else "artifacts.lock.yaml"
    update_artifact_checksums(artifacts_lock_filename)
```

The `if __name__ == "__main__":` block runs when the module is executed as the main program, for example with `python script.py`. An installed console script instead imports its target and calls a function when the command is run, not during installation. So we wrap the script's entry logic in `main()`:

```python
def main() -> None:
    yaml_file_path = sys.argv[1] if len(sys.argv) > 1 else "artifacts.lock.yaml"
    update_artifact_checksums(yaml_file_path)
```

`pyproject.toml` then points to `main` as the entry point.

### 4. `uv.lock` (for uv project environments)

`uv lock` records resolved dependency versions, including transitive
dependencies and environment markers. `uv sync` and `uv run` use this lockfile
for the project environment. Different Python versions or platforms can select
different entries; the lockfile is not a promise of identical installations on
every machine.

From a checkout, these commands check the lockfile and sync without updating it:

```bash
uv lock --check
uv sync --locked
```

**Neither `pip install` nor `pipx install` consumes `uv.lock`.** They install
using distribution metadata and resolve dependencies within the declared
constraints. Even a pipx backend using `uv pip` is not a `uv sync` project
operation. Pinning the tool's Git tag pins its source, not its whole transitive
dependency environment. A lockfile must be used explicitly by a compatible
workflow, or exported into a supported dependency format for another installer.

## How `pipx install` installs the package

```bash
pipx install git+https://github.com/konflux-ci/update-artifacts-lockfile.git@v0.2.0
```

1. `pipx` creates an isolated virtual environment
2. Fetches the public source at the `v0.2.0` tag
3. Its installer invokes the backend declared in `pyproject.toml` to build a wheel
4. Installs that wheel and resolves runtime dependencies such as `requests` and `ruamel.yaml` from package metadata, not `uv.lock`
5. Exposes the console-script launcher derived from `[project.scripts]`; the command is available once pipx's bin directory is on `PATH`

## The shebang

The original script started with:
```python
#!/usr/bin/env python3
```

This is a Unix "shebang" - it tells the shell which interpreter to use when you run the file directly (`./script`). In a packaged module, it is not needed: Python (via pipx) is always the runner. It was removed.

The generated console-script launcher has its own interpreter selection, so
the installed command uses the Python in the pipx environment.

## Key standards

- **PEP 517** - defines how build backends work (`uv_build` is one such backend)
- **PEP 518** - defines `pyproject.toml` as the place to declare build requirements
- **PEP 621** - defines the `[project]` table format in `pyproject.toml`

## Public sources

- [Package metadata and entry point](https://github.com/konflux-ci/update-artifacts-lockfile/blob/main/pyproject.toml)
- [Current implementation](https://github.com/konflux-ci/update-artifacts-lockfile/blob/main/src/update_artifacts_lockfile/__init__.py)
- [PyPA packaging tutorial](https://packaging.python.org/en/latest/tutorials/packaging-projects/)
- [How pipx works](https://pipx.pypa.io/stable/explanation/how-pipx-works.html)
- [uv locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/)
