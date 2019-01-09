FROM elixir:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

RUN apt-get update && apt-get install -y -q inotify-tools curl software-properties-common && curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt install -y nodejs && node -v && npm -v

RUN mkdir -p /usr/locla/runhyve/webapp
ADD . /usr/locla/runhyve/webapp
WORKDIR /usr/locla/runhyve/webapp
RUN mix deps.get && cd assets && npm install && cd ..
