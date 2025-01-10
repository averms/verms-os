# verms OS

My custom build of Fedora Silverblue.

## Installation

Install Fedora Silverblue first. Then upgrade and reboot. Then run

```
rpm-ostree rebase ostree-unverified-registry:ghcr.io/averms/verms-os:latest
```

## References

I learned a lot from reading the code of the following projects:

- https://github.com/ublue-os/main
- https://github.com/travier/fedora-sysexts
- https://github.com/centos-workstation/achillobator
- https://gitlab.com/fedora/bootc/examples
