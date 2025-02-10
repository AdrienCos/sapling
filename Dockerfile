ARG PYTHON_VERSION=3.13.2-slim
ARG PDM_VERSION=2.22.3

FROM python:${PYTHON_VERSION}@sha256:ae9f9ac89467077ed1efefb6d9042132d28134ba201b2820227d46c9effd3174 as base
RUN addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --disabled-password \
    abc
USER abc
ENV PATH="/home/abc/.local/bin:${PATH}"
WORKDIR /app


FROM base as base-pdm
ARG PDM_VERSION
RUN pip install --user --no-cache-dir pdm==${PDM_VERSION}
COPY --chown=abc:abc ./pyproject.toml /app/
COPY --chown=abc:abc ./pdm.lock /app/



FROM base-pdm as package-builder
COPY --chown=abc:abc ./src /app/src
RUN pdm build --no-sdist



FROM base-pdm as dependencies-installer
RUN pdm sync --production --no-self



FROM base as final
ENV PATH="/app/.venv/bin:${PATH}"
COPY --from=dependencies-installer /app/.venv/ /app/.venv/
COPY --from=package-builder /app/dist/adriencos_sapling*.whl /app/
RUN pip --python "$(which python)" install --no-cache-dir --no-deps ./adriencos_sapling*.whl

ENTRYPOINT [ "adriencos_sapling" ]
