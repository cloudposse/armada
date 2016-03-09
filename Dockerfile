FROM ubuntu:14.04

MAINTAINER Erik Osterman "e@osterman.com"

ENV PATH $PATH:/opt/bin

ADD bin/ /opt/bin

MAINTAINER Erik Osterman "e@osterman.com"

# System ENV
ENV TIMEZONE Etc/UTC
ENV DEBIAN_FRONTEND noninteractive
ENV PATH "$PATH:/opt/bin:/usr/local/bin"
ENV TERM xterm

# Locale specific
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Git 
ENV GIT_USERS=
ENV GITHUB_USERS= 
ENV USE_DIND false

USER root

# FIXME I should really make a more minimal vps instance and inherit from it =)

RUN apt-get update && \
    apt-get install -y \
                    locales \
                    realpath \
                    openssh-server \
                    curl \
                    git \
                    vim && \
    (curl -sSL https://get.docker.com/ | sh) && \ 
    mkdir -p /var/run/sshd && \
    sed -i 's:session\s*required\s*pam_loginuid.so:session optional pam_loginuid.so:g' /etc/pam.d/sshd && \
    ([ -f /etc/ssh/ssh_host_rsa_key ] || ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key)  && \
    mkdir -p /root/.ssh/ -m 0700 && \
    echo '\nHost github.com\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null' >> /root/.ssh/config && \
    echo '\nHost gitlab.com\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null' >> /root/.ssh/config  && \
    locale-gen $LANGUAGE && \
    dpkg-reconfigure locales && \
    echo "$TIMEZONE" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    ln -s /home/docker /var/lib/docker

ADD bin /opt/bin
ADD start /start

EXPOSE 22

ENTRYPOINT ["/start"]


