FROM elixir:1.12
ENV DEBIAN_FRONTEND=noninteractive

RUN mix local.hex --force
RUN mix local.rebar --force

RUN apt-get update && apt-get install -y -q inotify-tools curl software-properties-common && curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt install -y nodejs && node -v && npm -v

RUN mkdir -p /usr/local/runhyve/webapp
WORKDIR /usr/local/runhyve/webapp
