# python-junit-xml - historical improvement proposal

**Historical, superseded for COSA.** These suggestions accompanied the May 2026
package-takeover proposal; they are not current work needed for COSA's rebase.
On 2026-06-12, upstream [commit `44fc9934d5ed`](https://github.com/coreos/coreos-assembler/commit/44fc9934d5ed8815f49a8080d121e27bfaf9541b)
replaced `python-junit-xml` with `junitparser`. The [current `src/kola-junit`](https://github.com/coreos/coreos-assembler/blob/main/src/kola-junit)
imports `TestSuite`, `TestCase`, `JUnitXml`, `Failure`, and `Skipped` from
`junitparser`.

The legacy observations below remain useful when reading old code or evaluating
other consumers. They do not assert that [BZ#2483182](https://bugzilla.redhat.com/show_bug.cgi?id=2483182)
is still awaiting approval, or that unretiring the old package is still needed.
See the [package lifecycle guide](orphan-retire-unorphan.md) and
[current COSA guide](../coreos-assembler/README.md).

## Drop Python 2 support

The [legacy upstream implementation](https://github.com/kyrus/python-junit-xml/blob/master/junit_xml/__init__.py)
contains Python 2 compatibility that a Python-3-only fork could remove:

- **`six` dependency** - only used for `u()` (unicode literals),
  `iteritems()` (dict iteration), and `PY2` (version check). All
  unnecessary on Python 3.
- `u("string")` can become `"string"` (Python 3 strings are Unicode).
- `iteritems(d)` can become `d.items()`; remove obsolete `PY2` branches.
- **`decode()` function** - the old implementation's Python 3 branch uses
  `str(x)`. Do not generalize that to bytes decoding: `str(bytes_value)` produces
  a bytes representation, whereas decoding bytes requires an explicit encoding.
- **`unichr` fallback** - `unichr` only exists in Python 2.
  Replace with `chr` directly.

This would remove the `six` runtime dependency entirely.

## Simplify the API

The library has deprecated methods that still exist:
- `TestSuite.to_file()` and `TestSuite.to_xml_string()` are deprecated
  wrappers around `to_xml_report_file()` and `to_xml_report_string()`.
  COSA's [pre-migration `kola-junit`](https://github.com/coreos/coreos-assembler/blob/30993582da0b96f3ca06f6ff72d0a1f7858ffc99/src/kola-junit)
  used the deprecated `TestSuite.to_file()`. This observation no longer applies
  to current COSA, which writes reports with `JUnitXml.write()`.

## What the old kola-junit used

Before the migration, COSA used only a small surface of `junit_xml`:

| Class | Methods used |
|---|---|
| `TestCase` | `__init__(name, classname, elapsed_sec, stdout, stderr)` |
| `TestCase` | `add_failure_info(message, output)` |
| `TestCase` | `add_skipped_info(message, output)` |
| `TestSuite` | `__init__(name, test_cases)` |
| `TestSuite` | `to_file(file_descriptor, [suites])` |

Other API features (errors, properties, assertions, multiple subelements,
hostname, package, url, etc.) were not used by that version of COSA. This is not
a reason to delete APIs needed by other external consumers.

## Historical references

- GitHub: https://github.com/kyrus/python-junit-xml
- The original proposal referenced release 1.9 (Feb 2020); live issue counts and
  maintainer activity are not asserted here.
- Fedora dist-git: https://src.fedoraproject.org/rpms/python-junit_xml
- [COSA migration commit](https://github.com/coreos/coreos-assembler/commit/44fc9934d5ed8815f49a8080d121e27bfaf9541b)
- [Current report generator](https://github.com/coreos/coreos-assembler/blob/main/src/kola-junit)
