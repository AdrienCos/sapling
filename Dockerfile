ARG PYTHON_VERSION=3.12.4-slim
ARG PDM_VERSION=2.16.1

FROM python:${PYTHON_VERSION}@sha256:44fa7d815050f3dc43b1d5d50c3f4d19870a83c96301c9653e8cf908ccd7892b as base
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
