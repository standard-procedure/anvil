FROM mcr.microsoft.com/devcontainers/ruby:0-3-bullseye

RUN gem update bundler
RUN gem install standardrb

WORKDIR /workspaces/standard-procedure-anvil

COPY . /workspaces/standard-procedure-anvil/
RUN bundle check || bundle install

