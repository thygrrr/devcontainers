# tdc — tiger's dev containers

Run coding agents in a dev container for whatever directory you're in. The current directory is
mounted as the container's workspace (via the devcontainer CLI), so the agents work on your files
while running isolated in docker. Projects with their own `.devcontainer` config use that; everything
else falls back to the global image defined here.

## Aliases (nushell)

| Alias | What it does |
| --- | --- |
| `cc [...args]` | Start the dev container, update Claude Code to latest, run `claude` |
| `oc [...args]` | Start the dev container, update opencode to latest, run `opencode` |
| `dc` | Start the dev container and drop into a clean nushell prompt |
| `dc-rebuild` | Recreate the container (picks up config changes, keeps image cache) |
| `dc-update` | Rebuild the image from scratch (`--build-no-cache`) and recreate the container |

## Layout

- `devcontainer/Dockerfile` — global fallback image: dotnet devcontainer base + nushell (login shell)
  + Claude Code + opencode
- `devcontainer/devcontainer.json` — global fallback config: persists `~/.claude` and opencode state
  in named docker volumes so logins survive rebuilds
- `nushell/tdc.nu` — the aliases above
- `install.nu` — copies the files to their live locations on this machine

## Install / update

```nu
nu install.nu
```

Copies the devcontainer config to `~/.config/tdc/` (baking in the absolute Dockerfile path, since
the devcontainer CLI resolves relative paths against the workspace, not the override config) and
`tdc.nu` into nushell's `autoload` dir, which is sourced on interactive shell startup (not by
`nu -c` or scripts). Then restart nushell. Requires docker, the `devcontainer` CLI
(`npm i -g @devcontainers/cli`), and nushell.
