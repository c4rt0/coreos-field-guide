# Fedora Package Ownership and Retirement

Orphaning and retiring are different package states. An orphaned package has no
current maintainer; a retired package has been removed from the applicable
development branches. The status can differ by branch, and retirement does not
by itself describe whether already-published stable updates remain available.

Before taking ownership or requesting an unretirement:

1. Check the package status and the branches involved.
2. Confirm that you meet the current Fedora packager and package-access
   requirements.
3. Follow the current Fedora policy and release-engineering procedure for the
   package state and branches. Review, source restoration, ownership, and build
   system unblocking may be separate steps.
4. Verify the package and build-system state after the request is completed.

Do not rely on a fixed orphaning or unretirement waiting period from an old
write-up. Thresholds, exceptions, and branch procedures can change; use the
linked policy and SOP for the current rule.

## References

- [Fedora policy for orphaned and retired packages](https://docs.fedoraproject.org/en-US/fesco/Policy_for_orphan_and_retired_packages/)
- [Package retirement process](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Retirement_Process/)
- [Package orphaning process](https://docs.fedoraproject.org/en-US/package-maintainers/Package_Orphaning_Process/)
- [Package maintainer sponsorship](https://docs.fedoraproject.org/en-US/package-maintainers/How_to_Get_Sponsored_into_the_Packager_Group/)
- [RelEng unretirement SOP](https://docs.fedoraproject.org/en-US/infra/releng_misc_guide/sop_unretire/)
- [Fedora package-maintenance guide](README.md)
