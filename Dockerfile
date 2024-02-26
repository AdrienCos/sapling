ARG PYTHON_VERSION=3.13.2-slim
ARG PDM_VERSION=2.22.4
ARG UV_VERSION=0.1.10
ARG USER_ID=1000
ARG APP_VERSION

FROM python:${PYTHON_VERSION}@sha256:8f3aba466a471c0ab903dbd7cb979abd4bda370b04789d25440cc90372b50e04 AS base
ARG USER_ID
RUN addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --disabled-password \
    --uid ${USER_ID} \
    abc
USER abc
ENV PATH="/home/abc/.local/bin:${PATH}"
WORKDIR /app


FROM base AS base-pdm
ARG PDM_VERSION
ARG UV_VERSION
ARG USER_ID
ADD --chown=abc:abc https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz /tmp/
RUN --mount=type=cache,target=/home/abc/.cache/uv,uid=${USER_ID} \
    mkdir -p /home/abc/.local/bin/ && \
    tar --strip-components 1 -xf /tmp/uv-x86_64-unknown-linux-gnu.tar.gz -C /home/abc/.local/bin/ && \
    uv venv /home/abc/.pdm_venv && \
    VIRTUAL_ENV="/home/abc/.pdm_venv" uv pip install pdm==${PDM_VERSION} &&\
    uv venv
COPY --chown=abc:abc ./pyproject.toml /app/
COPY --chown=abc:abc ./pdm.lock /app/



FROM base-pdm AS package-builder
ARG APP_VERSION
COPY --chown=abc:abc ./src /app/src
COPY --chown=abc:abc ./README.md /app/
RUN PDM_BUILD_SCM_VERSION=${APP_VERSION} /home/abc/.pdm_venv/bin/pdm build --no-isolation --no-sdist -v



FROM base-pdm AS dependencies-installer
ARG USER_ID
ARG APP_VERSION
RUN --mount=type=cache,target=/home/abc/.cache/uv,uid=${USER_ID} \
    /home/abc/.pdm_venv/bin/pdm export --prod --output requirements.txt && \
    uv venv && \
    uv pip sync requirements.txt
COPY --from=package-builder /app/dist/adriencos_sapling-${APP_VERSION}-py3-none-any.whl /app/dist/
RUN uv pip install --no-deps "adriencos_sapling @ file:///app/dist/adriencos_sapling-${APP_VERSION}-py3-none-any.whl"



FROM base AS final
ENV PATH="/app/.venv/bin:${PATH}"
COPY --from=dependencies-installer /app/.venv/ /app/.venv/

ENTRYPOINT [ "adriencos_sapling" ]
