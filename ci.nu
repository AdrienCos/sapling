#!/usr/bin/env nu
# ci.nu - Nushell CI module for Sapling
# Replaces the Dagger Python SDK with native Nushell + Docker

const CI_IMAGE = "sapling-ci:latest"
const WORKDIR = "/workdir"

# Build the CI image (uses Docker layer caching for efficiency)
def build-ci-image [source: path = "."]: nothing -> string {
    let source_path = ($source | path expand)
    let python_version = (open $"($source_path)/mise.toml" | get tools.python | str trim)
    docker build -q -t $CI_IMAGE --build-arg $"PYTHON_VERSION=($python_version)" -f $"($source_path)/ci.Dockerfile" $source_path | str trim
}

# Run a command in the CI container
def run-in-ci [source: path, ...cmd: string] {
    let image = build-ci-image $source
    docker run --rm $image ...$cmd
}

# Run a command in the CI container and extract artifacts
def run-in-ci-with-artifacts [
    source: path,
    output: path,
    artifact_path: string,
    ...cmd: string
] {
    let image = build-ci-image $source
    let output_path = ($output | path expand)
    let container_name = $"ci-artifacts-(random uuid)"

    try {
        docker run --name $container_name $image ...$cmd
    } catch {
        docker rm -f $container_name | ignore
        error make { msg: "Command failed" }
    }

    mkdir $output_path
    docker cp $"($container_name):($artifact_path)/." $output_path
    docker rm -f $container_name | ignore
}

# Run linting checks
export def lint [source: path = "."] {
    print $"(ansi cyan)Running lint...(ansi reset)"
    run-in-ci $source uvx pdm lint
    print $"(ansi green)Lint passed(ansi reset)"
}

# Run tests
export def test [source: path = "."] {
    print $"(ansi cyan)Running tests...(ansi reset)"
    run-in-ci $source uvx pdm test
    print $"(ansi green)Tests passed(ansi reset)"
}

# Build Python distribution (wheel + sdist)
export def dist [source: path = ".", output: path = "./dist"] {
    print $"(ansi cyan)Building dist...(ansi reset)"
    run-in-ci-with-artifacts $source $output $"($WORKDIR)/dist" uvx pdm build
    print $"(ansi green)Dist artifacts saved to ($output)(ansi reset)"
}

# Build PEX executable
export def pex [source: path = ".", output: path = "./dist"] {
    print $"(ansi cyan)Building PEX...(ansi reset)"
    run-in-ci-with-artifacts $source $output $"($WORKDIR)/dist" uvx pdm pex-build
    print $"(ansi green)PEX artifacts saved to ($output)(ansi reset)"
}

# Build all artifacts (dist + pex)
export def build [source: path = ".", output: path = "./dist"] {
    print $"(ansi cyan)Building all artifacts...(ansi reset)"
    dist $source $output
    pex $source $output
    print $"(ansi green)All artifacts built(ansi reset)"
}

# Build Docker image
export def docker-build [source: path = ".", tag: string = "sapling:latest"] {
    print $"(ansi cyan)Building Docker image ($tag)...(ansi reset)"
    docker build -t $tag -f $"($source)/Dockerfile" $source
    print $"(ansi green)Docker image ($tag) built(ansi reset)"
    $tag
}

# Run all checks (lint + test)
export def check [source: path = "."] {
    print $"(ansi cyan)Running all checks...(ansi reset)"
    lint $source
    test $source
    print $"(ansi green)All checks passed(ansi reset)"
}

# Main entry point - run a specific task or show help
def main [
    task?: string  # Task to run: lint, test, dist, pex, build, docker-build, check
    --source: path = "."  # Source directory
    --output: path = "./dist"  # Output directory for artifacts
    --tag: string = "sapling:latest"  # Docker image tag
] {
    match $task {
        "lint" => { lint $source }
        "test" => { test $source }
        "dist" => { dist $source $output }
        "pex" => { pex $source $output }
        "build" => { build $source $output }
        "docker-build" => { docker-build $source $tag }
        "check" => { check $source }
        null => {
            print "Sapling CI - Nushell Edition"
            print ""
            print "Usage: nu ci.nu <task> [options]"
            print ""
            print "Tasks:"
            print "  lint         Run linting checks"
            print "  test         Run tests"
            print "  dist         Build wheel and sdist"
            print "  pex          Build PEX executable"
            print "  build        Build all artifacts (dist + pex)"
            print "  docker-build Build Docker image"
            print "  check        Run all checks (lint + test)"
            print ""
            print "Options:"
            print "  --source     Source directory (default: .)"
            print "  --output     Output directory (default: ./dist)"
            print "  --tag        Docker image tag (default: sapling:latest)"
        }
        _ => {
            print $"Unknown task: ($task)"
            exit 1
        }
    }
}
