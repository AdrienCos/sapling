"""Console script for adriencos_sapling."""

# Standard lib imports
import sys

# Third-party lib imports
import click
from loguru import logger

# Local package imports
from adriencos_sapling.example_module import ExampleClass


# Define this function as a the main command entrypoint
@click.command()
# Create an argument that expects an integer, and has a default value
@click.option(
    "-n",
    "--iterations",
    help="Number of times to display the sample text",
    type=int,
    default=1,
)
@click.option(
    "-v",
    "--verbose",
    help="Verbose mode",
    count=True,
)
# Get the version of the package
@click.version_option()
# Display some help
@click.help_option("-h", "--help")
def main(
    iterations: int,
    verbose: int,
) -> None:
    """Console script for adriencos_sapling."""
    # Set the log level if required
    if verbose == 0:
        logger.remove()
        logger.add(sys.stderr, level="INFO")

    instance = ExampleClass()
    for i in range(iterations):
        logger.info(f"Iteration number {i}: {instance.add(i, i)}")


if __name__ == "__main__":
    sys.exit(main())
