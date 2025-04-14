FROM rockylinux/rockylinux:8

ARG RUBY_VERSION=ruby:3.1
ARG NODE_VERSION=nodejs:18

RUN dnf update -y && \
    dnf install -y dnf-utils && \
    dnf config-manager --set-enabled powertools && \
    dnf -y module enable ${RUBY_VERSION} ${NODE_VERSION} && \
    dnf install -y \
        ruby \
        ruby-devel \
        nodejs \
        make \
        gcc \
        gcc-c++ \
        git \
        libyaml-devel \
        zlib-devel \
        libxml2-devel \
        libxslt-devel \
        xz \
        nc
RUN dnf clean all && rm -rf /var/cache/dnf/*
RUN gem install rake