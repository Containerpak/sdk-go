FROM ubuntu:26.04 AS fetch

ARG TARGETARCH
ARG GO_VERSION=1.27.0
ARG GO_SHA256_AMD64=675c26c449cbb18fc24b74650de1eabbae6e16f64326fd85a283fb3b58280685
ARG GO_SHA256_ARM64=51798d2c42d0e1c6ed7fd9f48728b4193abac9e8aad6dbac2fe96a81f5909bda

COPY cpak-apt.conf /etc/apt/apt.conf.d/90cpak
COPY --chmod=0755 cpak-clean-junk /usr/bin/cpak-clean-junk

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    case "$TARGETARCH" in \
        amd64) goarch=amd64; checksum="$GO_SHA256_AMD64" ;; \
        arm64) goarch=arm64; checksum="$GO_SHA256_ARM64" ;; \
        *) echo "unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${goarch}.tar.gz" && \
    echo "${checksum}  /tmp/go.tar.gz" | sha256sum -c - && \
    mkdir -p /opt && \
    tar -C /opt -xzf /tmp/go.tar.gz && \
    cpak-clean-junk

FROM ghcr.io/containerpak/base:main

COPY --from=fetch /opt/go/ /usr/local/

RUN ln -s /usr/local/bin/go /usr/bin/go && \
    ln -s /usr/local/bin/gofmt /usr/bin/gofmt

ENV GOROOT=/usr/local
ENV PATH=/usr/local/bin:${PATH}
