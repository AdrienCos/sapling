ARG PYTHON_VERSION=3.12.1
ARG PDM_VERSION=2.11.2

FROM python:${PYTHON_VERSION} as builder

# Expose the PDM version to this stage
ARG PDM_VERSION

# Install PDM
RUN pip install --no-cache-dir pdm==$PDM_VERSION

# Copy the project in the builder layer
WORKDIR /build
COPY . /build

# Generate the Python package and its requirements
RUN pdm ci-prebuild

FROM python:${PYTHON_VERSION}-slim as runtime

# Create the user/group that will run the app, to avoid running as root
RUN addgroup --system abc && \
    adduser \
    --shell /bin/sh \
    --ingroup abc \
    --disabled-password \
    abc

# Copy the built Python archive
COPY --from=builder --chown=abc:abc /build/dist/adriencos_sapling*.whl /app/
# Copy the pinned requirements
COPY --from=builder --chown=abc:abc /build/requirements.txt /app/

# Switch to the created user
USER abc
ENV PATH="${PATH}:/home/abc/.local/bin"

# Install the Python package and its runtime dependencies
WORKDIR /app
RUN pip install --user --no-cache-dir --requirement ./requirements.txt
# We cannot run both installs on a single `pip install` call, as the `requirements.txt`
# file contains package hashes, and the .whl does not
# See: https://github.com/pypa/pip/issues/4344
# hadolint ignore=DL3059
RUN pip install --user --no-cache-dir ./adriencos_sapling*.whl

# Set the entrypoint as the package
ENTRYPOINT [ "adriencos_sapling" ]
