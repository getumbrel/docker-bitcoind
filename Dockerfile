# Bitcoin Core Release Keys as of 4/Sep/2024
# - https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
# - https://api.github.com/repos/bitcoin-core/guix.sigs/contents/builder-keys
ARG KEYS="\
    # 0xb10c:
    982A193E3CE0EED535E09023188CBB2648416AD5 \
    # CoinForensics:
    101598DC823C1B5F9A6624ABA5E0907A0380E6C3 \
    # Emzy:
    9EDAFF80E080659604F4A76B2EBB056FD847F8A7 \
    # Sjors:
    ED9BDF7AD6A55E232E84524257FF9BDBCC301009 \
    # TheCharlatan:
    A8FC55F3B04BA3146F3492E79303B33A305224CB \
    # achow101:
    152812300785C96444D3334D17565732E08E5E41 \
    # benthecarman:
    0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 \
    # cfields:
    C060A6635913D98A3587D7DB1C2491FFEB0EF770 \
    # darosior:
    590B7292695AFFA5B672CBB2E13FC145CD3F4304 \
    # davidgumberg:
    41E442A14C342C877AE4DC8F3B6305FA06DE51D5 \
    # dunxen:
    948444FCE03B05BA5AB0591EC37B1C1D44C786EE \
    # fanquake:
    E777299FC265DD04793070EB944D35F9AC3DB76A \
    # glozow:
    6B002C6EA3F91B1B0DF0C9BC8F617F1200A6D25C \
    # guggero:
    F4FC70F07310028424EFC20A8E4256593F177720 \
    # hebasto:
    D1DBF2C4B96F2DEBF4C16654410108112E7EA81F \
    # jackielove4u:
    287AE4CA1187C68C08B49CB2D11BD4F33F1DB499 \
    # josibake:
    616516B8EB6ED02882FC4A7A8ADCB558C4F33D65 \
    # kvaciral:
    C388F6961FB972A95678E327F62711DBDCA8AE56 \
    # laanwj:
    71A3B16735405025D447E8F274810B012346C9A6 \
    # luke-jr:
    1A3E761F19D2CC7785C5502EA291A2C45D0C504A \
    # m3dwards:
    E86AE73439625BBEE306AAE6B66D427F873CB1A3 \
    # pinheadmz:
    E61773CD6E01040E2F1BD78CE7E2984B6289C93A \
    # satsie:
    2F78ACF677029767C8736F13747A7AE2FB0FD25B \
    # sipa:
    133EAC179436F14A5CF1B794860FEB804E669320 \
    # svanstaa:
    9ED99C7A355AE46098103E74476E74C8529A9006 \
    # theStack:
    6A8F9C266528E25AEB1D7731C2371D91CB716EA7 \
    # vertiond:
    28E72909F1717FE9607754F8A7BEB2621678D37D \
    # willcl-ark:
    67AA5B46E7AF78053167FE343B8F814A784218F8 \
    # willyko:
    79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF \
"

# Build stage
FROM --platform=$BUILDPLATFORM debian:stable-slim AS builder
LABEL org.opencontainers.image.authors="Umbrel, Inc. <https://umbrel.com>"

ARG VERSION
ARG TARGETPLATFORM
# re-declared from above
ARG KEYS

WORKDIR /build

RUN echo "Installing build deps"
RUN apt-get update
RUN apt-get install -y wget pgp

RUN echo "Deriving tarball name from \$TARGETPLATFORM" && \
    case "${TARGETPLATFORM}" in \
      "linux/amd64")  echo "bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz"    > /tarball-name ;; \
      "linux/arm64")  echo "bitcoin-${VERSION}-aarch64-linux-gnu.tar.gz"   > /tarball-name ;; \
      *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Tarball name: $(cat /tarball-name)"

RUN echo "Downloading release assets"
RUN wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/$(cat /tarball-name)
RUN wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc
RUN wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS
RUN echo "Downloaded release assets:" && ls

RUN echo "Verifying PGP signatures"
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys $KEYS
RUN gpg --verify SHA256SUMS.asc 2>&1 >/dev/null | grep "^gpg: Good signature from" || { echo "No valid signature"; exit 1; }
RUN echo "PGP signature verification passed"

RUN echo "Verifying checksums"
RUN [ -f SHA256SUMS ] && cp SHA256SUMS /sha256sums || cp SHA256SUMS.asc /sha256sums
RUN grep $(cat /tarball-name) /sha256sums | sha256sum -c
RUN echo "Checksums verified ok"

RUN echo "Extracting release assets"
RUN tar -zxvf $(cat /tarball-name) --strip-components=1

# Final image
FROM debian:stable-slim

COPY --from=builder /build/bin/bitcoind /bin
COPY --from=builder /build/bin/bitcoin-cli /bin

ENV HOME=/data
VOLUME /data/.bitcoin

EXPOSE 8332 8333 18332 18333 18443 18444

ENTRYPOINT ["bitcoind", "-reindex"]
