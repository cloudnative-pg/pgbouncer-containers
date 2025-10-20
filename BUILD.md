# Building PgBouncer Container Images for CloudNativePG

This guide explains how to build PgBouncer operand images for
[CloudNativePG](https://cloudnative-pg.io) using
[Docker Bake](https://docs.docker.com/build/bake/) together with a
[GitHub Actions workflow](.github/workflows/bake.yml).

## Prerequisites

Before you begin, ensure that you have met the following prerequisites and requirements:

- [Prerequisites](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#prerequisites)
- [Verifying requirements](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#verifying-requirements)

## Building images

To build a PgBouncer image, run:

```bash
docker buildx bake --push
```
