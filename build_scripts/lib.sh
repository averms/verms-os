# --best causes dnf to fail if it can't install the latest version of everything. This
# prevents downgrading if rpmfusion is not up to date.
autodnf() {
    dnf --assumeyes --best "$@"
}

from_file() {
    grep -Ev '^#|^$' "$1"
}

kernel_ver="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)"
