# Webapp

# Development

## Using Docker
1. Run `docker-compose up -d` to run the containers
2. Setup the database: `docker-compose run webapp mix ecto.setup`
3. Visit http://localhost:4000 to see webapp running.

You can also run `docker-compose logs -f webapp` to see the server logs.<br>
To open Interactive Elixir Shell run `docker-compose run webapp iex -S mix`<br>
To open PostgreSQL interactive terminal run `docker-compose exec -u postgres  postgres psql -U postgres webapp_dev`


## Using local environment

##### Dependencies

- Elixir 1.5 or later
- PostgreSQL
- Node.js

1. Install dependencies with `mix deps.get`
2. Create and migrate your database with `mix ecto.setup`
3. Install Node.js dependencies with `cd assets && npm install`
4. Start Phoenix server `mix phx.server`

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
