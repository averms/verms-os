# verms OS

My very own Linux "distro". Based on Fedora Silverblue but featuring:

- hardware acceleration for AMD and NVIDIA (on the `nvidia` branch) from RPMFusion
- Flathub instead of Fedora Flatpaks
- patent-encumbered codecs
- my system configuration and favorite packages (virt-manager, kitty, etc.)
- bug fixes that are still pending upstream

## Installation

This is probably only useful if you're me.

### By rebasing

Install Fedora Silverblue 44 first. Then run

```
bootc switch ghcr.io/averms/verms-os:latest
```

Then reboot.

### Ab initio

Build an ISO for interactive installation on bare metal by doing `./go.sh build-iso`.
Then flash it onto a USB drive and you're off to the races. This is my preferred method
of installation.

If you would like to build a qcow2 image for running under virtualization, type `./go.sh
build-qcow2`.

## References

While the [upstream bootc documentation][] and [Fedora bootable containers docs][] were
my primary aids in building this, I also learned a lot from reading the code of the
following projects:

- https://github.com/fedora-sysexts/fedora
- https://github.com/ublue-os/bluefin-lts
- https://github.com/ublue-os/main
- https://gitlab.com/fedora/bootc/examples

[upstream bootc documentation]: https://bootc-dev.github.io/bootc
[Fedora bootable containers docs]: https://docs.fedoraproject.org/en-US/bootc
