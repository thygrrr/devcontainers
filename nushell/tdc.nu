# tdc — tiger's dev containers.
# Runs coding agents (claude code, opencode) or a plain nushell inside a dev container for the
# current directory. Uses the project's own .devcontainer if present, otherwise the global
# fallback config installed at ~/.config/tdc/.

# Shared: compute devcontainer CLI flags for the current directory.
def tdc-flags [] {
    let ws = (pwd)
    let has_own_config = (
        ($ws | path join ".devcontainer" "devcontainer.json" | path exists)
        or ($ws | path join ".devcontainer.json" | path exists)
    )
    {
        ws: $ws
        own: $has_own_config
        override: (if $has_own_config { [] } else {
            [--override-config ($nu.home-dir | path join ".config" "tdc" "devcontainer.json")]
        })
        up_flags: (if $has_own_config { [] } else { [--no-lockfile] })
    }
}

# Install the tool if missing (project-owned configs may not ship it), then update it to latest.
def tdc-refresh [f, tool: string] {
    let script = match $tool {
        "claude" => 'command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash; claude update'
        "opencode" => 'command -v opencode >/dev/null 2>&1 || curl -fsSL https://opencode.ai/install | bash; opencode upgrade'
    }
    devcontainer exec --workspace-folder $f.ws ...$f.override bash -lc $script
}

# Claude Code in the dev container, updated to latest on every invocation.
def --wrapped cc [...args] {
    let f = (tdc-flags)
    devcontainer up --workspace-folder $f.ws ...$f.override ...$f.up_flags
    tdc-refresh $f claude
    devcontainer exec --workspace-folder $f.ws ...$f.override claude ...$args
}

# opencode in the dev container, updated to latest on every invocation.
def --wrapped oc [...args] {
    let f = (tdc-flags)
    devcontainer up --workspace-folder $f.ws ...$f.override ...$f.up_flags
    tdc-refresh $f opencode
    devcontainer exec --workspace-folder $f.ws ...$f.override opencode ...$args
}

# Drop straight into a clean nushell prompt inside the dev container (bash if nu is unavailable).
def dc [] {
    let f = (tdc-flags)
    devcontainer up --workspace-folder $f.ws ...$f.override ...$f.up_flags
    devcontainer exec --workspace-folder $f.ws ...$f.override bash -lc 'command -v nu >/dev/null 2>&1 && exec nu; exec bash -l'
}

# Recreate the container (picks up config changes, keeps cached image layers).
def dc-rebuild [] {
    let f = (tdc-flags)
    devcontainer up --workspace-folder $f.ws ...$f.override ...$f.up_flags --remove-existing-container
}

# Full rebuild from scratch: recreate the container and rebuild the image without cache.
def dc-update [] {
    let f = (tdc-flags)
    devcontainer up --workspace-folder $f.ws ...$f.override ...$f.up_flags --remove-existing-container --build-no-cache
}
