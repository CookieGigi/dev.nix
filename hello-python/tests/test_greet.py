"""Tests for the greeting helpers.

`greet.broken` and `greet.unused_helpers` are intentionally faulty fixtures for
basedpyright and ruff, so nothing here exercises them.
"""

from __future__ import annotations

import pytest

from hello.greet import GREETINGS, greet, shout


def test_greet_includes_name() -> None:
    assert greet("world") == "hello world"


@pytest.mark.parametrize("name", ["world", "Ada Lovelace", "x", ""])
def test_greet_never_fails(name: str) -> None:
    assert greet(name) == f"hello {name}"


def test_greet_preserves_name_case() -> None:
    assert greet("Ada") == "hello Ada"


def test_shout_is_upper_case() -> None:
    assert shout("world") == "HELLO WORLD"


def test_shout_matches_uppercased_greet() -> None:
    assert shout("world") == greet("world").upper()


def test_greetings_are_lowercase_and_non_empty() -> None:
    assert GREETINGS == ("hello", "hi", "hey")
