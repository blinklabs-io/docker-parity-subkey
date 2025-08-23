FROM rust:bookworm AS rustbuilder
ARG POLKADOT_SDK_VERSION=polkadot-stable2506-1
ENV POLKADOT_SDK_VERSION=${POLKADOT_SDK_VERSION}
WORKDIR /code
RUN echo "Building subkey..." \
    && git clone https://github.com/paritytech/polkadot-sdk.git \
    && cd polkadot-sdk \
    && git fetch --all --recurse-submodules --tags \
    && git tag \
    && git checkout tags/${POLKADOT_SDK_VERSION} \
    && apt-get update -y \
    && apt-get install -y \
       clang \
       protobuf-compiler \
    && cd substrate/bin/utils/subkey \
    && cargo build --release

FROM debian:bookworm-slim AS subkey
COPY --from=rustbuilder /code/polkadot-sdk/target/release/subkey /bin/
ENTRYPOINT ["/bin/subkey"]
