FROM elixir:latest
ENV DEBIAN_FRONTEND=noninteractive
ENV MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

RUN apt-get update && apt-get install -y -q inotify-tools curl software-properties-common && curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt install -y nodejs && node -v && npm -v

RUN mkdir -p /usr/local/runhyve/webapp
ADD . /usr/local/runhyve/webapp
WORKDIR /usr/local/runhyve/webapp/assets
RUN npm install && node_modules/webpack/bin/webpack.js --mode production
WORKDIR /usr/local/runhyve/webapp
RUN mix deps.get --only prod && mix compile && mix phx.digest