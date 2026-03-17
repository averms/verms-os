# --best causes dnf to fail if it can't install the latest version of everything. This
# prevents downgrading if rpmfusion is not up to date.
autodnf() {
    FORCE_COLUMNS=120 dnf --quiet --assumeyes --best "$@"
}

from_file() {
    grep -Ev '^#|^$' "$1"
}

# sed -i that fails if no substitution was made.
strict_sed() {
    sed -i.bak "$1" "$2"
    if cmp -s "$2" "$2.bak"; then
        echo "error: sed expression had no effect on $2" >&2
        rm "$2.bak"
        return 1
    fi
    rm "$2.bak"
}

# shellcheck disable=SC2034
kernel_ver="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)"
