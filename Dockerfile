FROM elixir:1.10-alpine
ENV MIX_ENV=prod
COPY lib ./lib
COPY mix.exs .
COPY mix.lock .
RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix release

RUN apk add --no-cache --update bash openssl

CMD ["_build/prod/rel/sockethost/bin/sockethost", "start"]