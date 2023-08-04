"""Tests for `sapling` package."""

import pytest

from sapling.example_module import ExampleClass


@pytest.fixture
def class_instance() -> ExampleClass:
    """Sample pytest fixture.

    See more at: http://doc.pytest.org/en/latest/fixture.html
    """
    return ExampleClass()


def test_content(class_instance: ExampleClass) -> None:
    """Sample pytest test function with the pytest fixture as an argument."""
    assert class_instance.add(3, 2) == 5
