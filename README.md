# verms OS

My custom build of Fedora Silverblue.

## Installation

Install Fedora Silverblue 41 first. Then upgrade and reboot. Then run

```
bootc switch ghcr.io/averms/verms-os:latest
```

If you would like to build a qcow2 image for running under qemu, use
`./go.sh build-qcow2`. If you would like to build an ISO for interactive installation
on bare-metal, use `./go.sh build-iso`. These rely on the currently unstable
bootc-image-builder, so your mileage may vary.

## References

I learned a lot from reading the code of the following projects:

- https://github.com/ublue-os/main
- https://github.com/travier/fedora-sysexts
- https://github.com/centos-workstation/achillobator
- https://gitlab.com/fedora/bootc/examples
