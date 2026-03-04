# ci.Dockerfile - CI environment with dependencies and source
# Layer 1: deps only (cached when lockfile unchanged)
# Layer 2: source + project install (cached when source unchanged)

ARG PYTHON_VERSION=3.14
FROM astral/uv:python${PYTHON_VERSION}-trixie

WORKDIR /workdir

# Copy dependency files first (for layer caching)
COPY pyproject.toml pdm.lock ./

# Install dependencies only (not the project itself yet)
RUN uvx pdm sync --no-self

# Copy full source (respects .dockerignore)
COPY . .

# Install the project itself (fast, deps already cached)
RUN uvx pdm sync
