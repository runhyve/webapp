FROM elixir:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

RUN apt-get update && apt-get install -y -q nodejs inotify-tools

RUN mkdir -p /usr/locla/runhyve/webapp
ADD . /usr/locla/runhyve/webapp
WORKDIR /usr/locla/runhyve/webapp