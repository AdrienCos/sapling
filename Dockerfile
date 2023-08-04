ARG PYTHON_VERSION=3.9.17
FROM python:${PYTHON_VERSION}-slim

# Create the user/group that will run the app, to avoid running as root
RUN addgroup --system app_group && \
    adduser \
    --shell /bin/sh \
    --ingroup app_group \
    --disabled-password \
    app_user

# Copy the built Python archive
COPY ./dist/sapling*.whl /app/
# Copy the pinned requirements
COPY ./requirements.txt /app/

# Switch to the created user
USER app_user
ENV PATH="${PATH}:/home/app_user/.local/bin"

# Install the Python package and its runtime dependencies
WORKDIR /app
RUN pip install --user --no-cache-dir --requirement ./requirements.txt
# We cannot run both installs on a single `pip install` call, as the `requirements.txt`
# file contains package hashes, and the .whl does not
# See: https://github.com/pypa/pip/issues/4344
# hadolint ignore=DL3059
RUN pip install --user --no-cache-dir ./sapling*.whl

# Set the entrypoint as the package
ENTRYPOINT [ "sapling" ]
