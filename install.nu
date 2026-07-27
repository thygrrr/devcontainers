#!/usr/bin/env nu
# Installs tdc onto this machine:
#   devcontainer config + Dockerfile -> ~/.config/tdc/
#   nushell aliases                  -> <nushell config dir>/autoload/tdc.nu
# Autoload files are sourced on interactive/login shell startup only, not by `nu -c` or scripts.

def main [] {
    let repo = $env.FILE_PWD

    let cfg_dir = ($nu.home-dir | path join ".config" "tdc")
    mkdir $cfg_dir
    cp ($repo | path join "devcontainer" "Dockerfile") $cfg_dir

    # The CLI resolves a relative dockerfile against the workspace, not the override config,
    # so bake in the absolute installed path.
    let dockerfile = ($cfg_dir | path join "Dockerfile" | str replace -a '\' '/')
    open --raw ($repo | path join "devcontainer" "devcontainer.json")
    | str replace '"dockerfile": "Dockerfile"' $'"dockerfile": "($dockerfile)"'
    | save -f ($cfg_dir | path join "devcontainer.json")

    let autoload = ($nu.default-config-dir | path join "autoload")
    mkdir $autoload
    cp ($repo | path join "nushell" "tdc.nu") $autoload

    print $"installed devcontainer config -> ($cfg_dir)"
    print $"installed nushell aliases     -> ($autoload | path join tdc.nu)"
    print "restart nushell to pick up the aliases"
}
