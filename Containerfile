FROM ubuntu:26.04 AS fetch

ARG TARGETARCH
ARG GO_VERSION=1.26.5
ARG GO_SHA256_AMD64=5c2c3b16caefa1d968a94c1daca04a7ca301a496d9b086e17ad77bb81393f053
ARG GO_SHA256_ARM64=fe4789e92b1f33358680864bbe8704289e7bb5fc207d80623c308935bd696d49

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/* && \
    case "$TARGETARCH" in \
        amd64) goarch=amd64; checksum="$GO_SHA256_AMD64" ;; \
        arm64) goarch=arm64; checksum="$GO_SHA256_ARM64" ;; \
        *) echo "unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${goarch}.tar.gz" && \
    echo "${checksum}  /tmp/go.tar.gz" | sha256sum -c - && \
    mkdir -p /opt && \
    tar -C /opt -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

FROM ubuntu:26.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=fetch /opt/go/ /usr/local/

RUN ln -s /usr/local/bin/go /usr/bin/go && \
    ln -s /usr/local/bin/gofmt /usr/bin/gofmt

ENV GOROOT=/usr/local
ENV PATH=/usr/local/bin:${PATH}
