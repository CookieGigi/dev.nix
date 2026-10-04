"""Greeting helpers used to exercise the editor profile."""

from __future__ import annotations

GREETINGS = ("hello", "hi", "hey")


def greet(name: str) -> str:
    """Return a greeting for `name`."""
    return f"hello {name}"


def shout(name: str) -> str:
    """Return a greeting in upper case."""
    return greet(name).upper()


def broken(name: str) -> str:
    """Intentionally wrong: `name` is not a str here, so basedpyright flags it."""
    return greet(42)


def unused_helpers() -> None:
    """Contains dead code so `ruff check` has something to report."""
    unused_value = 3
    if GREETINGS:
        return