FROM ghcr.io/envwizard/python310-base:latest@sha256:df62016190ed8b9655a9da4cc253e729f2117cffe9fef5cba8c1dfd0ff74149a

# Environment variables

# Switch to root to install system dependencies
USER root

WORKDIR /workspace

# Install system dependencies for Python development
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Clone repository
RUN git clone https://github.com/pypa/twine /workspace/repo

WORKDIR /workspace/repo

# Create script to copy repository content to workspace
RUN echo '#!/bin/bash' > /usr/local/bin/copy-repo.sh && \
    echo 'echo "Copying repository content to workspace..."' >> /usr/local/bin/copy-repo.sh && \
    echo 'if [ -d "/workspace/repo" ] && [ -d "/workspaces" ]; then' >> /usr/local/bin/copy-repo.sh && \
    echo '  # Find the workspace directory' >> /usr/local/bin/copy-repo.sh && \
    echo '  WORKSPACE_DIR=$(find /workspaces -maxdepth 1 -type d ! -path /workspaces | head -1)' >> /usr/local/bin/copy-repo.sh && \
    echo '  if [ -n "$WORKSPACE_DIR" ] && [ -d "$WORKSPACE_DIR" ]; then' >> /usr/local/bin/copy-repo.sh && \
    echo '    echo "Found workspace directory: $WORKSPACE_DIR"' >> /usr/local/bin/copy-repo.sh && \
    echo '    # Copy repository files to workspace directory' >> /usr/local/bin/copy-repo.sh && \
    echo '    cp -r /workspace/repo/. "$WORKSPACE_DIR/" 2>/dev/null || true' >> /usr/local/bin/copy-repo.sh && \
    echo '    echo "Repository files copied to workspace"' >> /usr/local/bin/copy-repo.sh && \
    echo '  else' >> /usr/local/bin/copy-repo.sh && \
    echo '    echo "No workspace directory found"' >> /usr/local/bin/copy-repo.sh && \
    echo '  fi' >> /usr/local/bin/copy-repo.sh && \
    echo 'else' >> /usr/local/bin/copy-repo.sh && \
    echo '  echo "Source or target directory not found"' >> /usr/local/bin/copy-repo.sh && \
    echo 'fi' >> /usr/local/bin/copy-repo.sh && \
    chmod +x /usr/local/bin/copy-repo.sh

# Setup script
RUN echo '#!/bin/bash' > /tmp/setup.sh && \
    echo 'set -e' >> /tmp/setup.sh && \
    echo "ls -l" >> /tmp/setup.sh && \
    echo "cat README.rst" >> /tmp/setup.sh && \
    echo "cat pytest.ini" >> /tmp/setup.sh && \
    echo "cat mypy.ini" >> /tmp/setup.sh && \
    echo "cat pyproject.toml" >> /tmp/setup.sh && \
    echo "cat tox.ini" >> /tmp/setup.sh && \
    echo "ls -l docs/requirements.txt" >> /tmp/setup.sh && \
    echo "cat docs/requirements.txt" >> /tmp/setup.sh && \
    echo "pip install setuptools-scm" >> /tmp/setup.sh && \
    echo "SETUPTOOLS_SCM_PRETEND_VERSION_FOR_TWINE=999 pip install -e .[keyring]" >> /tmp/setup.sh && \
    echo "pip install -r docs/requirements.txt" >> /tmp/setup.sh && \
    echo "pip install pretend pytest pytest-socket coverage pytest-rerunfailures pytest-services devpi-server devpi pypiserver isort black flake8 flake8-docstrings mypy lxml==5.2.0 types-requests towncrier build" >> /tmp/setup.sh && \
    echo "source \$(python -c 'import sys; print(sys.prefix)')/bin/activate" >> /tmp/setup.sh && \
    echo "python -c 'import twine; import keyring; import requests; import requests_toolbelt; import rfc3986; import rich; import packaging; import id; import readme_renderer; import pytest; import sphinx; import doc8; import black; import isort; import mypy; import lxml; import towncrier; import devpi_server; import pypiserver; print(\"All imports successful.\")'" >> /tmp/setup.sh && \
    chmod +x /tmp/setup.sh && \
    /tmp/setup.sh

# Switch back to vscode user for development
USER vscode