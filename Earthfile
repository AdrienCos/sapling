VERSION 0.8
ARG PYTHON_VERSION=3.12.7
FROM python:${PYTHON_VERSION}
WORKDIR /workspace

deps:
    RUN pip install pdm==2.20.1
    COPY pdm.lock ./
    COPY pdm.toml ./
    COPY pyproject.toml ./
    COPY setup.py ./
    RUN pdm sync
    COPY ./src ./src
    COPY ./tests ./tests
    COPY ./readme ./readme
    COPY ./README.md ./
    COPY ./LICENSE ./

lint:
    FROM +deps
    RUN pdm lint

test:
    FROM +deps
    RUN pdm install
    RUN pdm test

pex:
    FROM +deps
    COPY .git .git
    RUN pdm pex-build
    SAVE ARTIFACT ./dist/* AS LOCAL ./dist/

package:
    FROM +deps
    COPY .git .git
    RUN pdm build
    SAVE ARTIFACT ./dist/* AS LOCAL ./dist/

docker:
    FROM python:${PYTHON_VERSION}-slim
    COPY +package/*.whl .
    RUN pip install *.whl
    ENTRYPOINT ["adriencos_sapling"]
    ARG EARTHLY_GIT_SHORT_HASH
    ARG tag=${EARTHLY_GIT_SHORT_HASH}
    ARG registry_prefix
    SAVE IMAGE --push ${registry_prefix}adriencos/sapling:${tag}

all:
    BUILD +lint
    BUILD +test
    BUILD +pex
    BUILD +package
    BUILD +docker

gh:
    FROM debian:bookworm
    RUN apt update && apt install -y --no-install-recommends wget ca-certificates
    RUN wget https://github.com/cli/cli/releases/download/v2.49.2/gh_2.49.2_linux_amd64.tar.gz
    RUN tar xf gh_2.49.2_linux_amd64.tar.gz
    RUN mv ./gh_2.49.2_linux_amd64/bin/gh /bin/

create-gh-release:
    FROM +gh
    ARG --required tag
    BUILD +package
    BUILD +pex
    COPY +package/* dist/
    COPY +pex/* dist/
    RUN --push \
        --secret GH_TOKEN \
        gh release create \
            --repo AdrienCos/sapling \
            --draft \
            --verify-tag \
            --title $tag \
            $tag ./dist/*
