# ELI15: Ignition, the First-Boot Provisioner

[Technical guide: Ignition](README.md)

Ignition is the early-boot setup stage that prepares a CoreOS machine before its normal operating system takes over. Imagine a crew that opens the building once, arranges its rooms and labels, then leaves the regular occupants to run things. Its input is provisioning data supplied through an image or platform-specific path. In the initramfs, Ignition can prepare storage, write files, configure accounts and SSH keys, and place systemd units. When provisioning succeeds, boot continues and the regular system starts services.

The result is machine state created for that first boot, not a continuing management loop. Ignition does not compose an OS from packages, run arbitrary scripts, or automatically replay the same setup on later boots. Later supported changes belong to management systems such as MCO on managed OpenShift nodes, or to standalone host management. Some inputs need networking before normal boot, so delivery timing matters.

This distinction helps with CoreOS issue triage: a missing file on a new node points toward config delivery or first-boot provisioning; a later fleet-wide change points toward management or update flows. A successful schema check alone does not prove the machine booted correctly.

![How Ignition prepares a machine before normal services start](eli15-flow.png)

- [Diagram source](eli15-flow.drawio)
