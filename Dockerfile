FROM hexpm/elixir:1.15.4-erlang-26.0.2-alpine-3.18.2

RUN apk update \
    && apk add --no-cache \
    curl \
    inotify-tools \
    build-base

# Install hex and rebar
RUN mix local.rebar --force && \
    mix local.hex --force

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY . .

ADD docker-entrypoint.sh .
ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["start"]
