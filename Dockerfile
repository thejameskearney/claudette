FROM ubuntu:latest

RUN userdel -r ubuntu

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    USER=claudette \
    UID=1000 \
    GID=1000 \
    HOME=/home/claudette \
    CLAUDE_CONFIG_DIR=/home/claudette/.claude \
    WORKSPACE=/home/claudette/workspace

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    ca-certificates \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Create config directory mount point
RUN mkdir -p ${CLAUDE_CONFIG_DIR} && chmod +x ${CLAUDE_CONFIG_DIR}
RUN mkdir -p ${WORKSPACE} && chmod +x ${WORKSPACE}
RUN chown -R ${UID}:${GID} ${WORKSPACE} ${CLAUDE_CONFIG_DIR}

# Switch to non-root user
USER ${USER}
WORKDIR ${HOME}

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | /bin/bash

# Add Claude Code to PATH
ENV PATH="${HOME}/.local/bin:${PATH}"

# Set Claude Code config directory to the mounted volume
ENV CLAUDE_CLI_CONFIG_DIR=${CLAUDE_CONFIG_DIR}

# Copy entrypoint script
COPY --chown=${UID}:${GID} entrypoint.sh /home/claudette/entrypoint.sh
RUN chmod +x /home/claudette/entrypoint.sh

# Set working directory for projects
WORKDIR ${HOME}/workspace

# Set entrypoint to run updates on container start
ENTRYPOINT ["/home/claudette/entrypoint.sh"]

# Default command
CMD ["/bin/bash"]
