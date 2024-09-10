# docker-bitcoind

> Run a full Bitcoin node with one command

A Docker configuration with sane defaults for running a full Bitcoin node.

## Usage

```
docker run --name bitcoind -v $HOME/.bitcoin:/data/.bitcoin -p 8333:8333 getumbrel/bitcoind:<version-tag>
```

Replace the tag `<version-tag>` with the available version that you want to run. For example, to run version 27.1, use the tag `v27.1`:

```
docker run --name bitcoind -v $HOME/.bitcoin:/data/.bitcoin -p 8333:8333 getumbrel/bitcoind:v27.1
```

### JSON-RPC

To query `bitcoind`, execute `bitcoin-cli` from within the container:

```
docker exec -it bitcoind bitcoin-cli getnetworkinfo
```

To access JSON-RPC from other services you'll also need to expose port 8332. You probably only want this available to localhost:

```
docker run --name bitcoind -v $HOME/.bitcoin:/data/.bitcoin \
  -p 8333:8333 \
  -p 127.0.0.1:8332:8332 \
  getumbrel/bitcoind:v27.1
```

You could now query JSON-RPC via cURL like so:

```
curl --data '{"jsonrpc":"1.0","id":"curltext","method":"getnetworkinfo"}' \
  http://$(cat $HOME/.bitcoin/.cookie)@127.0.0.1:8332
```

### CLI Arguments

All CLI arguments are passed directly through to bitcoind.

You can use this to configure via CLI args without a config file:

```
docker run --name bitcoind -v $HOME/.bitcoin:/data/.bitcoin \
  -p 8333:8333 \
  -p 127.0.0.1:8332:8332 \
  getumbrel/bitcoind:v27.1 -rpcuser=jonsnow -rpcpassword=ikn0wnothin
```

Or just use the container like a bitcoind binary:

```
$ docker run getumbrel/bitcoind:v27.1 -version
Bitcoin Core RPC client version v27.1.0
Copyright (C) 2009-2024 The Bitcoin Core developers

Please contribute if you find Bitcoin Core useful. Visit
<https://bitcoincore.org/> for further information about the software.
The source code is available from <https://github.com/bitcoin/bitcoin>.

This is experimental software.
Distributed under the MIT software license, see the accompanying file COPYING
or <https://opensource.org/licenses/MIT>
```

### Versions

Images for versions starting from v27.1 are available. To run a specific available version, use the appropriate tag.

```
docker run --name bitcoind -v $HOME/.bitcoin:/data/.bitcoin -p 8333:8333 getumbrel/bitcoind:v27.1
```

## Build

A multi-architecture (amd64 and arm64) image is automatically built and published to Docker Hub when new tags are pushed in the format `v*.*.*` (e.g., `v25.0.0`).

If you want to build this image yourself, check out this repo, `cd` into it, and run:

```
docker buildx build --platform linux/amd64,linux/arm64 --build-arg VERSION=<version> -t <image_name>:<tag> --push .
```

Replace `<version>` with the Bitcoin Core version you're building (without the 'v' prefix), and `<image_name>:<tag>` with your desired image name and tag.

The Dockerfile supports `linux/amd64` and `linux/arm64` architectures only.

## License

MIT © Umbrel, Inc. https://getumbrel.com/
