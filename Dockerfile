FROM ubuntu:16.04
MAINTAINER Jimmy Carter <jcarter@marchex.com>
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get install -y wget && \
    apt-get install -y build-essential && \
    apt-get install -y libpq-dev postgresql-server-dev-9.5 && \
    apt-get install -y git && \
    apt-get install -y lsof && \
    apt-get install -y ruby && \
    apt-get install -y ruby-dev && \
    apt-get install -y openvpn && \
    gem install bundler && \
    rm -rf /var/lib/apt/lists/*
RUN cd /usr/share/nginx/html && \
    git clone https://github.marchex.com/marchex/mchx-vmlist.git && \
    bundle install && \
    bin/make_vmlist.rb
