# Justfile for adriencos_sapling

# Format the codebase
format:
    uv run ruff format ./src tests/

# Fix the spelling mistakes found in the project
spell:
    uv run typos --write-changes .

# Lint the codebase
lint:
    uv run ruff format --check ./src tests/
    uv run ruff check ./src tests/
    uv run ty check
    uv run typos .
    uv lock --check

# Run the test suite
test:
    uv run pytest

# Measure and report the coverage of the test suite
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

# Update the development dependencies and tools
dev-update:
    uv run pre-commit autoupdate
    uv lock --upgrade

# Remove all the build artifacts, caches, and other debris
clean:
    uv run pyclean --debris all -- .

# Build a Docker image of the application
docker-build:
    docker build -t adriencos_sapling:dev -t adriencos_sapling:$(uv run python -c "import tomllib; print(tomllib.load(open('pyproject.toml', 'rb'))['project']['version'])") .

# Update the project to the latest version of the template
template-update:
    uv run copier update --skip-answered

build:
    uv build
