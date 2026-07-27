FROM mcr.microsoft.com/devcontainers/dotnet

# Nushell from the official fury apt repo; make it the login shell of the container user.
RUN curl -fsSL https://apt.fury.io/nushell/gpg.key | gpg --dearmor -o /usr/share/keyrings/fury-nushell.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/fury-nushell.gpg] https://apt.fury.io/nushell/ /" > /etc/apt/sources.list.d/fury.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nushell \
    && rm -rf /var/lib/apt/lists/* \
    && chsh -s /usr/bin/nu vscode

USER vscode
ENV OPENCODE_INSTALL_DIR=/home/vscode/.local/bin
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && curl -fsSL https://opencode.ai/install | bash \
    && { test -x $HOME/.local/bin/opencode || ln -sf $HOME/.opencode/bin/opencode $HOME/.local/bin/opencode; } \
    && mkdir -p $HOME/.config/nushell \
    && printf '$env.config.show_banner = false\n' > $HOME/.config/nushell/config.nu \
    && touch $HOME/.config/nushell/env.nu

USER root
RUN ln -sf /home/vscode/.local/bin/claude /usr/local/bin/claude \
    && ln -sf /home/vscode/.local/bin/opencode /usr/local/bin/opencode
USER vscode
