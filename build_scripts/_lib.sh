# --best causes dnf to fail if it can't install the latest version of everything. This
# prevents downgrading if rpmfusion is not up to date.
autodnf() {
    dnf --quiet --assumeyes --best "$@"
}

from_file() {
    grep -Ev '^#|^$' "$1"
}

# shellcheck disable=SC2034
kernel_ver="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)"
