FROM hexpm/elixir:1.16.1-erlang-26.2.3-debian-buster-20240130 AS elixir-builder

RUN apt update && apt install -y git build-essential

# If you're using a hex mirror:
# ENV HEX_MIRROR=https://my_hex_mirror

RUN mix local.hex --force
RUN mix local.rebar --force

# -----------------------------------
# Base Image #2: Elixir Runner
# - Elixir Application Runner
#   This is used as a simple operating
#   system image to host your
#   application
# -----------------------------------
FROM debian:buster as elixir-runner

# You can add any libraries required by your application
# here:

RUN apt-get update && \
  apt-get install -y \
  # If you're using `:crypto`, you'll need openssl installed \
  libssl-dev \
  locales \
  curl \
  openssh-client

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# -----------------------------------
# - stage: install
# - job: dependencies
# -----------------------------------
FROM elixir-builder AS deps

ENV MIX_ENV=prod

# If you're using a hex mirror:
# ENV HEX_MIRROR=https://my_hex_mirror

WORKDIR /src

COPY config /src/config
COPY mix.exs mix.lock /src/
COPY apps/core/mix.exs /src/apps/core/mix.exs
COPY apps/web/mix.exs /src/apps/web/mix.exs

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# If inside an umbrella project, you also need to add all `mix.exs`
# e.g
# COPY apps/my_app_1/mix.exs /src/apps/my_app_1/mix.exs
# COPY apps/my_app_2/mix.exs /src/apps/my_app_2/mix.exs

RUN --mount=type=ssh mix deps.get --only $MIX_ENV

# -----------------------------------
# - stage: build
# - job: compile_deps
# -----------------------------------
FROM deps AS compile_deps
WORKDIR /src

ENV MIX_ENV=prod
RUN mix deps.compile

# -----------------------------------
# - stage: build
# - job: compile_app
# -----------------------------------
FROM compile_deps AS compile_app
WORKDIR /src

ENV MIX_ENV=prod

COPY . .

RUN mix compile --warnings-as-errors
# RUN cd apps/web && mix phx.digest

# -----------------------------------
# - stage: release
# - job: mix_release
# -----------------------------------
FROM compile_app AS mix_release

WORKDIR /src

ENV MIX_ENV=prod

RUN mix release --path /app --quiet

# -----------------------------------
# - stage: release
# - job: release_image
# -----------------------------------
FROM elixir-runner AS release_image

# If you need to inject the app revision into the container,
# uncomment below:
ARG APP_REVISION=latest
ENV APP_REVISION=$APP_REVISION

ENV MIX_ENV=prod

USER nobody

COPY --from=mix_release --chown=nobody:nogroup /app /app
COPY --from=mix_release /src/liveness.sh /app/
WORKDIR /app

ENTRYPOINT ["/app/bin/api"]
CMD ["start"]