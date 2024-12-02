# advent-of-code-2024

David's Advent of Code for 2024.

## Requirements

You'll need:

1. Python 3.11 or newer, with `poetry` installed.
2. Docker

## Article fetcher

This project uses a mini Python script for downloading the content of a puzzle article as Markdown. To set up this script, run:

```bash
poetry install
```

This will install the dependencies in a Poetry virtual environment. To run the script to download a specific day's puzzle article, run:

```bash
poetry run download <day>
# e.g., poetry run download 1
```

This will produce an output located at `articles/day-<day>/article.md`.

## SQL Solutions

All of the solutions for this advent of code are written in Postgres SQL and managed using Docker.

The input documents for each Advent of Code question are located in the `inputs/` directory. The input documents are named `day-<day>.txt`. They are meant to be loaded as tables of raw text lines in the Postgres database.

The SQL solutions use a _setup_ script to load the original input text as a table in the Postgres database. These setup scripts are designed to run independently of one another and are executed during the startup of the container. The setup scripts are located in `setups/` directory. They each presuppose the existence of corresponding input text files in `inputs/`.

The solution SQL scripts, located at `solutions/day-<day>/solution-<id>.sql`, presuppose the existence of the _setup_ tables. Using a single query, they each construct the solution to the corresponding question.

To run through the SQL solutions, run the following command:

```bash
bash docker-build.sh --all
```

This will build the Docker image (mounting the inputs and setup scripts) and start a container for the Postgres instance. Upon startup, the setup scripts will be run to construct the input tables. Finally, the solution scripts are run in order, and the output is printed to stdout.

To run a specific day's solution, run:

```bash
bash docker-build.sh --day <day>
```

To skip rebuilding the docker image, you can supply the `--no-build` flag:

```bash
bash docker-build.sh --no-build --day 1
```

## Interactive SQL

To run an interactive `psql` session in the Docker container after running the setup scripts, run:

```bash
bash docker-interactive.sh
```

This script also supports the "--no-build" flag to skip rebuilding the Docker image.

## Acknowledgements

Author:

- David Sillman <dsillman2000@gmail.com>
- Advent of Code 2024: https://adventofcode.com/2024
