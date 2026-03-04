import asyncio
from typing import Annotated

import dagger
from dagger import dag, function, object_type, check


@object_type
class DaggerCi:
    @function
    async def docker_build(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> dagger.Container:
        """Build a Docker image from the Dockerfile at the root of the workdir"""
        return await source.docker_build(dockerfile="Dockerfile")

    @function
    async def build(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> list[dagger.Directory]:
        """Build all the artifacts of the project"""
        return await asyncio.gather(*[self.dist(source), self.pex(source)])

    @function
    async def dist(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> dagger.Directory:
        """Build a dist and wheel of the Python package"""
        return (
            await self.setup_env(source)
            .with_exec(["uvx", "pdm", "build"])
            .directory("dist/")
        )

    @function
    async def pex(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> dagger.Directory:
        """Build a Pex executable of the Python package"""
        return (
            await self.setup_env(source)
            .with_exec(["uvx", "pdm", "pex-build"])
            .directory("dist/")
        )

    @check
    @function
    async def lint(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> None:
        """Runs the 'pdm lint' target"""
        await self.setup_env(source).with_exec(["uvx", "pdm", "lint"]).sync()

    @check
    @function
    async def test(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> None:
        """Runs the 'pdm test' target"""
        await self.setup_env(source).with_exec(["uvx", "pdm", "test"]).sync()

    def setup_env(
        self,
        source: Annotated[
            dagger.Directory,
            dagger.DefaultPath("/"),
            dagger.Doc("sapling source directory"),
        ],
    ) -> dagger.Container:
        return (
            dag.container()
            .from_("astral/uv:python3.14-trixie")
            .with_mounted_cache(
                path="/root/.cache/pdm", cache=dag.cache_volume("pdm_cache")
            )
            .with_directory("/workdir", source)
            .with_workdir("/workdir")
            .with_exec(["uvx", "pdm", "sync"])
        )
