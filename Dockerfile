FROM ubuntu:16.04
MAINTAINER Jimmy Carter <jcarter@marchex.com>
RUN apt-get update && \
    apt-get install -y ruby && \
    apt-get install -y ruby-dev && \
    rm -rf /var/lib/apt/lists/*

COPY ["lib", "/root/vmlist/lib/"]
COPY ["bin", "/root/vmlist/bin/"]
COPY ["Gemfile", "/root/vmlist/Gemfile"]

RUN cd /root/vmlist && gem install bundler && bundler install

COPY ["conf/config.json", "/root/vmlist/conf/config.json"]
COPY ["conf/readonly.pem", "/root/vmlist/conf/readonly.pem"]

# This is what is executed when the container runs
CMD cd /root/vmlist && bin/make_vmlist.rb