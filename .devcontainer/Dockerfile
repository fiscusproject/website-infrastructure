FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

COPY --from=jdxcode/mise:2026.7.5 /usr/local/bin/mise /usr/local/bin/

# make sure mise is activated in both zsh and bash. Might be overriden by user's dotfiles.
RUN echo 'eval "$(mise activate bash)"' >> /home/vscode/.bashrc && \
    echo 'eval "$(mise activate zsh)"' >> /home/vscode/.zshrc
