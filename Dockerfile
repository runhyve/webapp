FROM elixir:1.11
ENV DEBIAN_FRONTEND=noninteractive

RUN mix local.hex --force
RUN mix local.rebar --force

RUN apt-get update && apt-get install -y -q inotify-tools curl software-properties-common && curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt install -y nodejs && node -v && npm -v

RUN mkdir -p /usr/local/runhyve/webapp
ADD . /usr/local/runhyve/webapp
WORKDIR /usr/local/runhyve/webapp
RUN mix deps.get
WORKDIR /usr/local/runhyve/webapp/assets
RUN npm install && npm rebuild node-sass && npm run deploy
WORKDIR /usr/local/runhyve/webapp
RUN mix compile && mix phx.digest
