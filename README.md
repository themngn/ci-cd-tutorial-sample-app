# CD/CI Tutorial Sample Application ⚙

**NOTE:** This code was written for an
[article](https://medium.com/rockedscience/docker-ci-cd-pipeline-with-github-actions-6d4cd1731030)
in the **RockedScience** publication on Medium.

## Description

This sample Python REST API application was written for a tutorial on implementing Continuous Integration and Delivery pipelines.

It demonstrates how to:

 * Write a basic REST API using the [Flask](http://flask.pocoo.org) microframework
 * Basic database operations and migrations using the Flask wrappers around [Alembic](https://bitbucket.org/zzzeek/alembic) and [SQLAlchemy](https://www.sqlalchemy.org)
 * Write automated unit tests with [unittest](https://docs.python.org/2/library/unittest.html)

Also:

 * How to use [GitHub Actions](https://github.com/features/actions)

## Requirements

 * `Python 3.12`
 * `Pip`
 * `virtualenv`, or `conda`, or `miniconda`

The `psycopg2` package does require `libpq-dev` and `gcc`.
To install them (with `apt`), run:

```sh
$ sudo apt-get install libpq-dev gcc
```

## Installation

With `virtualenv`:

```sh
$ python -m venv venv
$ source venv/bin/activate
$ pip install -r requirements.txt
```

With `conda` or `miniconda`:

```sh
$ conda env create -n ci-cd-tutorial-sample-app python=3.12
$ source activate ci-cd-tutorial-sample-app
$ pip install -r requirements.txt
```

Optional: set the `DATABASE_URL` environment variable to a valid SQLAlchemy connection string. Otherwise, a local SQLite database will be created.

Initalize and seed the database:

```sh
$ flask db upgrade
$ python seed.py
```

## Running tests

Run:

```sh
$ python -m unittest discover
```

## Running the application

### Running locally

Run the application using the built-in Flask server:

```sh
$ flask run
```

### Running on a production server

Run the application using `gunicorn`:

```sh
$ pip install -r requirements-server.txt
$ gunicorn app:app
```

To set the listening address and port, run:

```
$ gunicorn app:app -b 0.0.0.0:8000
```

## Running on Docker

Run:

```
$ docker build -t ci-cd-tutorial-sample-app:latest .
$ docker run -d -p 8000:8000 ci-cd-tutorial-sample-app:latest
```

## CI/CD pipeline

Defined in `.github/workflows/docker_build_push.yml` (GitHub Actions):

```
Run code tests ──► Smoke-test Docker image ──► Build and push Docker image to Docker Hub
(every push / PR)  (every push / PR)           (only on a published release)
```

### What was added

A **Smoke-test Docker image** stage (`smoke_test` job), placed between the tests and the release push:

1. **Build the Docker image** from the `Dockerfile`.
2. **Run smoke test** - starts the container, waits up to 30s for it to come up, then checks:
   - `GET /` returns `200` with `{"status": "ok"}`
   - `GET /menu` returns `404` on an empty database (migrations ran)
   - `GET /menu` returns `200` with `today_special` after running `seed.py`
3. **Show container logs and clean up** - always runs, so failures can be debugged from the log.
4. **Upload smoke test report** - `smoke-test-report.txt` is published as the `smoke-test-report` artifact, also on failure.

### Why

Unit tests run the app with the Flask test client, so they do not catch a broken image (missing
dependency, failing migration, wrong `CMD`). Previously such an image would only be noticed after it
was pushed to Docker Hub. Now `push_to_registry` depends on `smoke_test`, so only an image that
actually starts and serves requests can be released.

### How to run

- Push to any branch (without `/` in the name) or open a pull request: tests and the smoke test run.
- Publish a GitHub Release: all of the above, then the image is pushed to Docker Hub.
  Requires repository secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD` (access token) and
  `DOCKERHUB_REPOSITORY` (e.g. `user/ci-cd-tutorial-sample-app`).
- The report is under **Actions → run → Artifacts → smoke-test-report**.

## Deploying to Heroku

Run:

```sh
$ heroku create
$ git push heroku master
$ heroku run flask db upgrade
$ heroku run python seed.py
$ heroku open
```

or use the automated deploy feature:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

For more information about using Python on Heroku, see these Dev Center articles:

 - [Python on Heroku](https://devcenter.heroku.com/categories/python)
