# Contribution Guide

Please follow this guide when
creating issues or pull requests.

## Reporting a Bug

When reporting a bug,
please provide a minimal test case.
This can be a gist,
inline in the description,
or in the form of a pull request
that includes a failing test.

If you are contributing a bug fix,
make sure it has a passing test
in your pull request.

## Adding a Feature

`img-diff` currently only supports a naive
pixel-by-pixel image diffing algorithm.
If you would like to add more advanced algorithms,
feel free!
The only requirements are that
they are executed synchronously.

All features should have tests.

