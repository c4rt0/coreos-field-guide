# Linux Fundamentals for CoreOS Engineers

Command output is illustrative; installed tools and services vary by
distribution and release.

*A guide for people who want to understand WHY things work, not just memorize commands.*

---

## 1. Process Model: systemd, PID 1, and How Linux Boots

### What is this and why should I care?

When your Linux machine turns on, the kernel has one job after initializing hardware: start a single program. That program gets Process ID 1 (PID 1), and it's responsible for starting *everything else* - your network, your SSH server, your container runtime, all of it. On modern Linux (and every CoreOS system you'll touch), PID 1 is **systemd**. Think of systemd as a project manager at a construction site: it knows what needs to be built, in what order, and it keeps checking that nothing has fallen over. If you understand systemd, you understand how a CoreOS node comes to life and how to troubleshoot it when it doesn't.

### Key concepts

**PID 1 (systemd):** The first process. Every other process on the system is its child or grandchild. If PID 1 dies, the kernel panics - game over. This is why systemd is designed to be extremely robust.

**Unit files:** These are systemd's instruction cards. Each one describes a single thing to manage - a service, a mount point, a timer, a socket. They're plain text files that live in `/usr/lib/systemd/system/` (shipped by the OS) or `/etc/systemd/system/` (your local overrides). A unit file for, say, the SSH server tells systemd: "here's how to start sshd, here's when to start it, and here's what to do if it crashes."

**Targets:** Targets group units for a purpose. `multi-user.target` brings in services for a non-graphical multi-user system; `graphical.target` adds a GUI. Reaching a target does not prove every service is healthy or the network is reachable. CoreOS normally configures `multi-user.target` as its default boot target.

### Key commands

```bash
# What is PID 1?
$ ps -p 1 -o comm=
systemd

# List all running services
$ systemctl list-units --type=service --state=running
UNIT                     LOAD   ACTIVE SUB     DESCRIPTION
chronyd.service          loaded active running NTP client/server
crio.service             loaded active running Open Container Initiative Daemon
kubelet.service          loaded active running Kubernetes Kubelet
sshd.service             loaded active running OpenSSH server daemon

# Check the status of a specific service
$ systemctl status sshd.service
  sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled)
      Active: active (running) since Tue 2026-06-02 09:12:33 UTC; 3h ago
   Main PID: 1042 (sshd)

# Look at a unit file to see how a service is configured
$ systemctl cat sshd.service
[Unit]
Description=OpenSSH server daemon
After=network.target

[Service]
ExecStart=/usr/sbin/sshd -D
Restart=on-failure

[Install]
WantedBy=multi-user.target

# What target is configured as the default for boot?
$ systemctl get-default
multi-user.target

# Which targets are active now? More than one can be active.
$ systemctl list-units --type=target --state=active

# What is the current overall system state?
$ systemctl is-system-running
running
```

### Try this

Run `systemctl list-dependencies multi-user.target` and trace its required and wanted units. Wanted units can fail without preventing the target from becoming active. Compare the configured default with the active targets, then inspect a familiar service with `systemctl cat sshd.service` and `systemctl status sshd.service`.

---

## 2. Filesystem Hierarchy: Where Things Live (and Why CoreOS Is Different)

### What is this and why should I care?

On Linux, everything is organized into a directory tree starting at `/`. Unlike Windows, there are no drive letters - every disk, device, and config file hangs off that single root. Each top-level directory has a specific purpose, and understanding that purpose tells you where to look when troubleshooting. On CoreOS, much of the OS payload is **read-only during normal operation**, while configuration and state remain writable. The exact mount layout varies by release and storage backend. Read-only is an operating model, not a guarantee that privileged changes or tampering are impossible.

### The key directories

| Directory | Purpose | CoreOS behavior |
|-----------|---------|-----------------|
| `/usr` | The operating system itself - binaries, libraries, systemd units. | Normally read-only and supplied by the selected OS deployment. Some paths such as `/usr/local` may be redirected to writable state. |
| `/etc` | System configuration - hostname, network, SSH keys, firewall. | **Writable.** OSTree retains locally modified files across updates; unmodified files follow new OS defaults. |
| `/var` | Persistent mutable data - logs, container storage, databases. | **Writable and persistent** across deployment switches; services and migrations can still change its contents. |
| `/run` | Temporary runtime data - PID files, sockets. | **Writable but ephemeral** - lives in RAM, gone on reboot. |
| `/tmp` | Temporary scratch space. | Also tmpfs. Gone on reboot. |
| `/home` | User home directories. | Symlinked to `/var/home` on CoreOS. |
| `/boot` | Kernel/initramfs or UKI files and bootloader data. | Layout and retained boot entries vary; deployments are not necessarily separate A/B partitions. |
| `/dev` | Device files - represents hardware. | Managed by the kernel and udev. |
| `/proc`, `/sys` | Virtual filesystems exposing kernel internals. | Not real files. Kernel generates contents on the fly. |

### Why CoreOS splits the filesystem this way

Traditional Linux lets an administrator modify many system paths in place. That's flexible, but can make machines drift or leave a partially changed system. CoreOS takes a different approach:

- **The deployed OS tree is normally read-only** so ordinary runtime changes do not rewrite its system files. This alone is not tamper-proof; stronger integrity requires appropriate verified-boot and filesystem-integrity configuration.
- **Updates are staged** as a new deployment and selected at reboot; the previous deployment may remain available for a manual rollback.
- **`/etc` merges configuration at the file level.** Local edits win even if the new OS changes the same default file; this is not a Git-style textual conflict merge. Review new defaults when needed.

An OSTree deployment is a filesystem tree plus boot configuration, not a promise of two disk partitions. A failed update does not universally trigger an automatic rollback; recovery normally means explicitly selecting the previous boot entry or requesting a rollback.

`/var` is shared mutable state, not an OS-version snapshot. Services, tmpfiles
rules, and data-format migrations may modify it after an update. Rolling back
the OS does not undo those data changes or replace the need for backups.

### Key commands

```bash
# Inspect the root, OS, and state mount points. The exact layout varies.
$ findmnt -T /
$ findmnt -T /usr
$ findmnt -T /var

# On a normally booted CoreOS deployment, a write under /usr should fail.
$ touch /usr/coreos-field-guide-test
touch: cannot touch '/usr/coreos-field-guide-test': Read-only file system

# See what OSTree commit you're running
$ rpm-ostree status
```

This check demonstrates the current mount policy, not a security boundary. Privileged debugging or image-management mechanisms can make changes, and integrity protection depends on the image, boot chain, and configuration.

### Try this

On an OSTree deployment, run `ostree admin config-diff` to identify additions,
deletions, and changes in `/etc` relative to `/usr/etc`. These differences can
come from provisioning or services as well as your own edits.

---

## 3. RPM Basics: What Packages Are and How to Query Them

### What is this and why should I care?

An RPM package bundles binaries, config files, documentation, and metadata into a single `.rpm` file. CoreOS base packages are composed into the OS image, but `rpm-ostree` also supports layering RPMs on a running host. A normal `rpm-ostree install` stages a new deployment instead of modifying the booted `/usr` in place. Cluster-managed RHCOS nodes should be changed through the Machine Config Operator's supported interfaces, not by independently layering packages.

### The naming convention

An RPM name like `cri-o-1.32.0-3.el10.x86_64` breaks down as:

```
cri-o       - package name
1.32.0      - version (upstream)
3           - release (packaging revision)
el10        - distribution (Enterprise Linux 10 = RHEL 10)
x86_64      - architecture
```

### Key commands

```bash
# List ALL installed packages (pipe to grep to search)
$ rpm -qa | grep '^cri-o-'
cri-o-1.32.0-3.el10.x86_64

# Get detailed info about a package
$ rpm -qi cri-o
Name        : cri-o
Version     : 1.32.0
Release     : 3.el10
Summary     : OCI-based implementation of Kubernetes CRI

# List every file a package installed
$ rpm -ql cri-o
/etc/crio/crio.conf
/usr/bin/crio
/usr/lib/systemd/system/crio.service

# Reverse lookup: "who owns this file?"
$ rpm -qf /usr/bin/bash
bash-5.2.37-1.el10.x86_64

# On an unmanaged rpm-ostree host, inspect or request a package layer
$ rpm-ostree status
$ sudo rpm-ostree install htop
# The new deployment normally takes effect after reboot.
```

### Try this

Pick a binary you use daily, like `/usr/bin/ssh`. Run `rpm -qf /usr/bin/ssh` to find which package owns it. Then run `rpm -ql` on that package to see everything it installed.

---

## 4. Networking Basics: IPs, Ports, Firewalls, and DNS

### What is this and why should I care?

When something goes wrong - "the node can't reach the API server," "I can't SSH in" - start with addresses, routes, listening sockets, filtering, and name resolution. Minimal CoreOS images do not necessarily include every troubleshooting tool.

### IP addresses: `ip addr`

```bash
$ ip addr
1: lo: <LOOPBACK,UP>
    inet 127.0.0.1/8 scope host lo          # localhost, always there
2: ens3: <BROADCAST,MULTICAST,UP>
    inet 192.0.2.45/24 scope global ens3     # documentation-only example
3: cni0: <BROADCAST,MULTICAST,UP>
    inet 198.51.100.1/24 scope global cni0  # documentation-only example

# Just IPv4, more compact
$ ip -4 addr show
```

### Open ports: `ss`

Think of a port like a door number on a building - the IP address gets you to the building, the port tells you which door.

```bash
# Show all listening TCP ports and which process owns them
$ ss -ltnp
State  Local Address:Port  Process
LISTEN 0.0.0.0:22          users:(("sshd",pid=1042))
LISTEN *:6443              users:(("kube-apiserver",...))
LISTEN *:10250             users:(("kubelet",pid=2001))
```

### Firewall: inspect the installed stack

Even if a service is listening, packet filtering might block it. `firewalld`
and `firewall-cmd` are not universally installed or active on CoreOS. Inspect
the backend actually used by the host; these are read-only examples, not
instructions to change cluster-managed networking.

```bash
# Check which inspection tools are available
$ command -v nft iptables-save firewall-cmd

# If nftables is the relevant backend and nft is installed
$ sudo nft list ruleset

# If firewalld is installed and running
$ firewall-cmd --state
$ firewall-cmd --list-all
public (active)
  services: ssh
  ports: 6443/tcp 10250/tcp
```

Host rules alone do not prove external reachability. Routes, cloud security
groups, upstream firewalls, and cluster network policy may also matter.

### DNS: how name resolution works

```bash
# What nameserver am I using?
$ cat /etc/resolv.conf
nameserver 192.0.2.1

# Resolve a hostname through the host's configured NSS lookup path
$ getent ahosts api.example.com
203.0.113.50    STREAM api.example.com

# DNS-only query, if dig is installed
$ dig api.example.com +short
203.0.113.50
```

`getent` can use `/etc/hosts` and other configured name services, not just
DNS. `dig` is optional and is not present in every CoreOS image. Use a suitable
Toolbx/debug container or another machine when it is unavailable, remembering
that the container's resolver and network context may differ from the host's.

### Try this

Run `ss -ltnp` on a CoreOS node and identify each listening service. Inspect the available filtering backend, resolve a hostname with `getent ahosts`, and test reachability from the intended client network rather than inferring it from listening sockets alone.

---

## 5. SELinux: The Security Guard

### What is this and why should I care?

SELinux adds a second permission check on top of regular Linux permissions. Normal permissions ask "does this user have access?" SELinux asks "is this *type of process* allowed to touch this *type of file*?" Think of a building with two security checks - badge at the front desk (Unix perms), then a second guard checking if your role allows access to that specific room (SELinux).

This matters on CoreOS because it runs containers. In enforcing mode, SELinux
policy restricts what confined processes can access and can reduce the impact
of an exploit. It is defense in depth, not guaranteed container-escape
prevention: protection depends on policy, labels, privileges, and the kernel
and runtime remaining trustworthy.

### Key concepts

- **Labels:** Every file and process has one. Format: `user:role:type:level`. The **type** matters most (e.g., `sshd_t`, `container_t`, `etc_t`).
- **Enforcing:** SELinux blocks violations. CoreOS ships in enforcing mode. Leave it that way.
- **AVC denials:** When SELinux blocks something, it logs it. These logs are your debugging tool.

### Key commands

```bash
# Check current mode
$ getenforce
Enforcing

# See labels on files
$ ls -Z /etc/hostname
system_u:object_r:hostname_etc_t:s0 /etc/hostname

# See labels on processes
$ ps -eZ | grep sshd
system_u:system_r:sshd_t:s0  1042 ?  00:00:00 sshd

# Fix a file's label (if it got moved/copied wrong)
$ sudo restorecon -v /etc/some-config-file

# Check for recent denials
$ sudo ausearch -m AVC -ts recent
```

### Reading an AVC denial

```
avc: denied { read } for pid=5432 comm="nginx"
  scontext=system_u:system_r:httpd_t:s0
  tcontext=system_u:object_r:user_home_t:s0
```

Translation: process `nginx` (labeled `httpd_t`) tried to `read` a file labeled `user_home_t`. SELinux said no. Fix: either the file has the wrong label (`restorecon`), or it's in the wrong place.

### Try this

Run `ps -eZ | head -20` to see process labels. Notice how `sshd` runs as `sshd_t` and containers as `container_t`. Then run `sudo ausearch -m AVC -ts today` to see if any denials happened.

---

## 6. Logs: journalctl

### What is this and why should I care?

On CoreOS, everything logs through **journald**. Unlike scattered log files in `/var/log/`, journald stores logs in a structured binary format you query with `journalctl`. When a service won't start or something happened at 3 AM, this is your first stop.

### Key commands

```bash
# Logs for a specific service
$ journalctl -u kubelet

# Only this boot (ignore previous boots)
$ journalctl -b

# Previous boot (what happened before it crashed?)
$ journalctl -b -1

# Logs since a time
$ journalctl --since "1 hour ago"
$ journalctl --since "2026-06-02 14:00:00"

# Follow in real time (like tail -f)
$ journalctl -u crio -f

# Only errors and worse
$ journalctl -p err

# Combine: kubelet errors from the last 30 minutes
$ journalctl -u kubelet -p err --since "30 min ago"

# How many boots are recorded?
$ journalctl --list-boots

# Kernel messages (like dmesg but filterable)
$ journalctl -k
```

### Priority levels

| Level | Name | Meaning |
|-------|------|---------|
| 0 | emerg | System is unusable |
| 3 | err | Error conditions |
| 4 | warning | Warning conditions |
| 6 | info | Informational |
| 7 | debug | Debug-level |

`-p err` shows levels 0 through 3 - the "show me only the bad stuff" filter.

### Practical patterns

```bash
# "The node rebooted. What happened?"
journalctl -b -1 -p err

# "CRI-O is acting weird right now"
journalctl -u crio -f

# "Something broke between 2 and 3 PM"
journalctl --since "14:00" --until "15:00" -p warning
```

### Try this

Run `journalctl -b -p err` to see all errors from the current boot. Pick the most interesting one. Run `journalctl -u <that-service>` to see the full context. The lines just before the error usually tell you the real story.

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Check service status | `systemctl status <service>` |
| See what's mounted | `findmnt --real` |
| List all packages | `rpm -qa \| grep <name>` |
| Who owns this file? | `rpm -qf /path/to/file` |
| Show my IP addresses | `ip -4 addr show` |
| What's listening? | `ss -ltnp` |
| Firewall rules | `sudo nft list ruleset` if available and relevant; `firewall-cmd --list-all` only with active firewalld |
| Host name resolution | `getent ahosts <hostname>` |
| DNS-only lookup (optional tool) | `dig <hostname> +short` |
| SELinux mode | `getenforce` |
| SELinux denials | `ausearch -m AVC -ts recent` |
| Fix file labels | `restorecon -Rv /path` |
| Service logs | `journalctl -u <service>` |
| Errors this boot | `journalctl -b -p err` |
| Follow logs live | `journalctl -u <service> -f` |
| Previous boot logs | `journalctl -b -1` |
| OS version (CoreOS) | `rpm-ostree status` |

## Public references

- [`systemctl` configured defaults and runtime state](https://man7.org/linux/man-pages/man1/systemctl.1.html)
- [OSTree configuration merge semantics](https://ostreedev.github.io/ostree/atomic-upgrades/#assembling-a-new-deployment-directory) and [persistent `/var` handling](https://ostreedev.github.io/ostree/var/)
- [Fedora CoreOS documentation](https://docs.fedoraproject.org/en-US/fedora-coreos/)
- [Fedora CoreOS minimal-image troubleshooting with Toolbx (upstream source)](https://github.com/coreos/fedora-coreos-docs/blob/1fec1acb5437220c559b8833e0ef1d643edd918b/modules/ROOT/pages/debugging-with-toolbox.adoc)
- [Fedora CoreOS SELinux guidance (upstream source)](https://github.com/coreos/fedora-coreos-docs/blob/1fec1acb5437220c559b8833e0ef1d643edd918b/modules/ROOT/pages/selinux.adoc) and [container SELinux policy](https://github.com/containers/container-selinux/blob/main/container_selinux.8)
- [`rpm-ostree` client administration and package layering](https://coreos.github.io/rpm-ostree/administrator-handbook/)
- [Fedora CoreOS composefs and filesystem integrity](https://docs.fedoraproject.org/en-US/fedora-coreos/composefs/)
- [OSTree native-container transport](https://coreos.github.io/rpm-ostree/container/)
