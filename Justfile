# Justfile for adriencos_sapling

# Format the codebase
format:
    uv run ruff format ./src tests/

# Run all linters
lint:
    uv run ruff format --check ./src tests/
    uv run ruff check ./src tests/
    uv run ty check src tests
    uv lock --check

# Run the test suite
test:
    uv run pytest

# Run tests and generate coverage reports
coverage:
    uv run coverage run -m pytest
    uv run coverage combine
    uv run coverage report
    uv run coverage xml
    uv run coverage html

# Print the list of existing commands
[default]
help:
    just --list

# Install and configure the development environment
setup:
    uv sync
    uv run pre-commit install

# Update pre-commit hooks and uv lock
dev-update:
    uv run pre-commit autoupdate
    uv lock --upgrade

# Remove build artifacts, caches, and other debris
clean:
    uv run pyclean --debris all -- .

# Build a Docker image of the application
docker-build:
    docker build -t adriencos_sapling:dev -t adriencos_sapling:$(uv run python -c "import toml; print(toml.load('pyproject.toml')['project']['version'])") .

# Update the project to the latest version of the template
template-update:
    uv run copier update --skip-answered

# Build distribution packages
build:
    uv build
