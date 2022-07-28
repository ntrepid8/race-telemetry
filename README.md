# RacingTelemetry

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Up & Running

This section explains how to get Up & Running for local development or integration work.

These tools are not required for everything but will help make things easier:

- [docker](https://docs.docker.com/get-docker/)
- [docker-compose](https://docs.docker.com/compose/install/)

### PostgreSQL

In order to run unit tests or run a local server in `dev` mode a PostgreSQL version 12 instance is
required. Run an instance of PostgreSQL with `docker` like this:
```
$ docker run --rm --name parrotmob-db-psql -p 127.0.0.1:5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres:12
(snip...)
2021-01-12 15:48:56.358 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2021-01-12 15:48:56.358 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2021-01-12 15:48:56.361 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2021-01-12 15:48:56.369 UTC [66] LOG:  database system was shut down at 2021-01-12 15:48:56 UTC
2021-01-12 15:48:56.373 UTC [1] LOG:  database system is ready to accept connections
```

*Note: press CTRL+c to stop the Docker container when finished.*

If an alternative method of running PostgreSQL is used be sure to configure it as follows:
```
host: localhost
port: 5432
user: postgres
password: postgres
```

## F1 22 UDP Specification

For the UDP specification for F1 2022 see:

- https://answers.ea.com/t5/General-Discussion/F1-22-UDP-Specification/td-p/11551274
