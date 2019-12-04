FROM debian:stable-slim
LABEL maintainer="Luke Childs <lukechilds123@gmail.com>"

COPY ./bin /usr/local/bin
COPY ./VERSION /tmp

RUN VERSION=`cat /tmp/VERSION` && \
    TARBALL="bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz" && \
    chmod a+x /usr/local/bin/* && \
    apt-get update && \
    apt-get install -y curl gpg && \
    cd /tmp && \
    curl -O https://bitcoin.org/bin/bitcoin-core-${VERSION}/${TARBALL} && \
    curl -O https://bitcoin.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc && \
    KEY=01EA5486DE18A882D4C2684590C8019E36C2E964 && \
    for keyserver in \                                                                                                         keyserver.ubuntu.com \
        pgp.mit.edu \
        keyserver.pgp.com \
        ha.pool.sks-keyservers.net \
        hkp://p80.pool.sks-keyservers.net:80; \
    do \
        timeout 5s gpg --keyserver $keyserver --recv-keys $KEY && break; \
    done && \
    gpg --verify SHA256SUMS.asc && \
    grep $TARBALL SHA256SUMS.asc | sha256sum -c && \
    tar -zxvf $TARBALL && \
    mv bitcoin-${VERSION}/bin/* /usr/local/bin/ && \
    apt-get purge -y curl gpg && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/data"]
ENV HOME /data
ENV DATA /data
WORKDIR /data

EXPOSE 8332 8333

ENTRYPOINT ["init"]
