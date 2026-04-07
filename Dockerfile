ARG PYTHON_VERSION=3.14.3
# renovate: datasource=pypi depName=uv
ARG UV_VERSION=0.11.2

FROM ghcr.io/astral-sh/uv:${UV_VERSION}-debian-slim AS builder
ENV UV_COMPILE_BYTECODE=1
ENV UV_NO_DEV=1
ENV UV_PYTHON_INSTALL_DIR=/python
ENV UV_PYTHON_PREFERENCE=only-managed
ARG PYTHON_VERSION
RUN uv python install ${PYTHON_VERSION}
WORKDIR /app
RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project
COPY ./src /app/src
COPY README.md /app
RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked

FROM debian:bookworm-slim AS final
RUN addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --disabled-password \
    abc
WORKDIR /app
ENV PATH="/app/.venv/bin:${PATH}"
COPY --from=builder /python /python
COPY --from=builder --chown=abc:abc /app /app
USER abc

ENTRYPOINT [ "adriencos_sapling" ]
