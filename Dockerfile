FROM ubuntu:22.04

LABEL maintainer="JamesClonk <jamesclonk@jamesclonk.ch>"

ARG package_args='--allow-downgrades --allow-remove-essential --allow-change-held-packages --no-install-recommends'
RUN echo "debconf debconf/frontend select noninteractive" | debconf-set-selections && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get -y $package_args update && \
  apt-get -y $package_args dist-upgrade && \
  apt-get -y $package_args install curl ca-certificates tzdata bash vim && \
  apt-get clean && \
  find /usr/share/doc/*/* ! -name copyright | xargs rm -rf && \
  rm -rf \
    /usr/share/man/* /usr/share/info/* \
    /var/lib/apt/lists/* /tmp/*

RUN useradd -u 2000 -mU -s /bin/bash vcap && \
  mkdir /home/vcap/app && \
  chown vcap:vcap /home/vcap/app && \
  ln -s /home/vcap/app /app

WORKDIR /app
COPY jcio-frontend ./
COPY public ./public/
COPY templates ./templates/
RUN chown vcap:vcap -R /home/vcap/app && \
  chmod 750 -R /home/vcap/app/public && \
  chmod 750 -R /home/vcap/app/templates

USER vcap

ENV JCIO_ENV production
ENV PORT 3000
ENV JCIO_CMS_DATA https://github.com/jamesclonk-io/content/archive/master.zip

EXPOSE 3000

CMD ["./jcio-frontend"]
