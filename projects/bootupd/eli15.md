# ELI15: What bootupd Does for CoreOS

`bootupd` is a system tool that maintains supported bootloader files on a machine's boot disk. Think of OS and bootloader updates as two maintenance jobs: refreshing the rooms does not replace the entrance hardware that firmware uses before the OS starts.

The operating system image supplies bootloader files and metadata. `bootupd` compares that available payload with the component state recorded for the disk; when an update is applied, it writes the applicable files to the EFI System Partition or boot disk and records the new state. The next boot can then use those files. Delivering a new OS deployment alone does not show that the boot disk changed.

This distinction helps with CoreOS issue reports: an OS update or rollback is not the same as changing or rolling back the bootloader. `bootupd` does not update firmware or the kernel, and an update does not guarantee the machine will boot successfully. Whether updates run automatically depends on the image's integration, so one distribution's service behavior should not be assumed for another.

**Technical guide:** [README.md](README.md)

![How bootupd updates boot files used on the next start](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
