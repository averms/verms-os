# verms OS

## Installation

Install Fedora Silverblue 42 first. Then upgrade and reboot. Then run

```
bootc switch ghcr.io/averms/verms-os:latest
```

Another way --- actually the one I used --- is to build an ISO for interactive
installation on bare-metal by doing `./go.sh build-iso`. Then flash it onto a USB drive
and you're off to the races.

If you would like to build a qcow2 image for running under qemu, type `./go.sh
build-qcow2`.

## References

I learned a lot from reading the code of the following projects:

- https://github.com/travier/fedora-sysexts
- https://github.com/ublue-os/bluefin-lts
- https://github.com/ublue-os/main
- https://gitlab.com/fedora/bootc/examples
