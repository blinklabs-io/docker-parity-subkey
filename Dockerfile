FROM rust:bookworm AS rustbuilder
ARG POLKADOT_SDK_VERSION=master
ENV POLKADOT_SDK_VERSION=${POLKADOT_SDK_VERSION}
WORKDIR /code
RUN git clone https://github.com/paritytech/polkadot-sdk.git
RUN echo "Building subkey..." \
    && apt-get update -y \
    && apt-get install -y \
       clang \
       protobuf-compiler \
    && cd polkadot-sdk/substrate/bin/utils/subkey \
    && cargo build --release

FROM debian:bookworm-slim AS subkey
COPY --from=rustbuilder /code/polkadot-sdk/target/release/subkey /bin/
ENTRYPOINT ["/bin/subkey"]
