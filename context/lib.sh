# Don't prompt and fail if it can't install the latest version of everything.
# This prevents downgrading if rpmfusion is not up to date.
autodnf() {
    command dnf --assumeyes --best "$@"
}
