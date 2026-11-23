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
    && for trie_version in $(awk '/^name = "trie-db"$/ {getline; gsub(/"/, "", $3); print $3}' /code/polkadot-sdk/Cargo.lock); do \
         case "$trie_version" in \
           0.29.1) trie_patch=0.29.2 ;; \
           0.30.0) trie_patch=0.30.1 ;; \
           *) continue ;; \
         esac; \
         cargo update --package "trie-db@${trie_version}" --precise "$trie_patch" || exit "$?"; \
       done \
    && cargo build --release --locked

FROM debian:bookworm-slim AS subkey
COPY --from=rustbuilder /code/polkadot-sdk/target/release/subkey /bin/
ENTRYPOINT ["/bin/subkey"]
