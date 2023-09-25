FROM ghcr.io/containerpak/base:main
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y wget gpg && \
    wget -O go.tar.gz https://go.dev/dl/go1.21.1.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    mv /usr/local/go/* /usr/local/ && \
    chmod +x /usr/local/bin/go /usr/local/bin/gofmt && \
    /usr/local/bin/go install -v golang.org/x/tools/gopls@latest && \
    /usr/bin/cpak-clean-junk
