ARG PYTHON_VERSION=3.12.2
ARG PDM_VERSION=2.11.2

FROM python:${PYTHON_VERSION}-slim as base
RUN addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --disabled-password \
    abc
USER abc
ENV PATH="${PATH}:/home/abc/.local/bin"
WORKDIR /app



FROM base as builder
ARG PDM_VERSION
RUN pip install --user --no-cache-dir pdm==${PDM_VERSION}
COPY --chown=abc:abc ./pyproject.toml /app/
COPY --chown=abc:abc ./pdm.lock /app/
COPY --chown=abc:abc ./src /app/src
RUN pdm build --no-sdist



FROM base as dependencies-installer
ARG PDM_VERSION
RUN pip install --user --no-cache-dir pdm==${PDM_VERSION}
COPY --chown=abc:abc ./pyproject.toml /app/
COPY --chown=abc:abc ./pdm.lock /app/
RUN pdm sync --production --no-self



FROM base as final
ENV PATH="${PATH}:/app/.venv/bin"
COPY --from=dependencies-installer /app/.venv/ /app/.venv/
COPY --from=builder /app/dist/adriencos_sapling*.whl /app/
RUN pip install --user --no-cache-dir ./adriencos_sapling*.whl

ENTRYPOINT [ "adriencos_sapling" ]
