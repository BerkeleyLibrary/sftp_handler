# =============================================================================
# Target: base
#
# The base stage scaffolds elements which are common to building and running
# the application, such as installing ca-certificates, creating the app user,
# and installing runtime system dependencies.
FROM ruby:3.0.3-slim AS base

# ------------------------------------------------------------
# Create the application user/group and installation directory

# UCBEARS uses the "altmedia" user and group because (historical/permissions) reasons
ENV APP_USER=alma
ENV APP_UID=40054

RUN groupadd --system --gid $APP_UID $APP_USER \
    && useradd --home-dir /opt/app --system --uid $APP_UID --gid $APP_USER $APP_USER

RUN mkdir -p /opt/app \
    && chown -R $APP_USER:$APP_USER /opt/app /usr/local/bundle

# ------------------------------------------------------------
# Install packages common to dev and prod.

# Install standard packages from the Debian repository
RUN apt-get update -qq

# ------------------------------------------------------------
# Run configuration

# All subsequent commands are executed relative to this directory.
WORKDIR /opt/app

# Run as the application user to minimize risk to the host.
USER $APP_USER

# Uses the get_gobi script as the entrypoint, so any arguments passed to `docker run`
# at invocation are passed directly to this script.
ENTRYPOINT ["/opt/app/bin/berkeley_library-sftp_handler.rb"]

# =============================================================================
# Target: development
#
# The development stage installs build dependencies (system packages needed to
# install all your gems) along with your bundle. It's "heavier" than the
# production target.
FROM base AS development

# ------------------------------------------------------------
# Install build packages

# Temporarily switch back to root
USER root

# Install system packages needed to build gems with C extensions.
RUN apt-get install -y --no-install-recommends \
    g++ \
    git \
    make

# ------------------------------------------------------------
# Install Ruby gems

# Drop back to $APP_USER.
USER $APP_USER

# Base image ships with an older version of bundler
RUN gem install bundler --version 2.2.33

# Install gems. We don't enforce the validity of the Gemfile.lock until the
# final (production) stage.
COPY --chown=$APP_USER:$APP_USER Gemfile* .ruby-version ./
RUN bundle install

# Copy the rest of the codebase. We do this after bundle-install so that
# changes unrelated to the gemset don't invalidate the cache and force a slow
# re-install.
COPY --chown=$APP_USER:$APP_USER . .

# =============================================================================
# Target: production
#
# The production stage extends the base image with the application and gemset
# built in the development stage. It includes runtime dependencies (including
# test dependencies, due to quirks of our Jenkins build) but tries to minimize
# heavyweight build dependencies.
FROM base AS production

# Copy the built codebase from the dev stage
COPY --from=development --chown=$APP_USER /opt/app /opt/app
COPY --from=development --chown=$APP_USER /usr/local/bundle /usr/local/bundle

# Ensure the bundle is installed and the Gemfile.lock is synced.
RUN bundle config set frozen 'true'
RUN bundle install --local
