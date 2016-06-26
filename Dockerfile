FROM ubuntu:16.04
MAINTAINER Jimmy Carter <jcarter@marchex.com>
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get install -y ruby && \
    apt-get install -y ruby-dev && \
    rm -rf /var/lib/apt/lists/*

COPY ["lib", "/root/vmlist/lib/"]
COPY ["bin", "/root/vmlist/bin/"]
COPY ["Gemfile", "/root/vmlist/Gemfile"]
RUN cd /root/vmlist && gem install bundler && bundler install

COPY conf/jciimarchex.pem /root/vmlist/jciimarchex.pem
COPY conf/config.json.prod /root/vmlist/config.json
COPY conf/crontab /etc/cron.d/vmlist-crontab
RUN chmod 0644 /etc/cron.d/vmlist-crontab

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD cd /root/vmlist && cron && nginx -g daemon off
