#! /usr/bin/env bash

# For debugging
# set -x

KEYS_DIR="/etc/dnscrypt-wrapper/keys"
STKEYS_DIR="${KEYS_DIR}/short-term"

prune_keys() {
    /usr/bin/find "$STKEYS_DIR" -type f -cmin +1440 -exec rm -f {} \;
}

new_key() {
    # /usr/bin/find "$STKEYS_DIR" -type f -exec rm -f {} \;

    ts=$(date '+%s')
    /usr/bin/dnscrypt-wrapper --gen-crypt-keypair \
        --crypt-secretkey-file="${STKEYS_DIR}/${ts}.key" &&
    /usr/bin/dnscrypt-wrapper --gen-cert-file \
        --provider-publickey-file="${KEYS_DIR}/public.key" \
        --provider-secretkey-file="${KEYS_DIR}/secret.key" \
        --crypt-secretkey-file="${STKEYS_DIR}/${ts}.key" \
        --provider-cert-file="${STKEYS_DIR}/${ts}.cert" \
        --cert-file-expire-days=1 && \
    mv -f "${STKEYS_DIR}/${ts}.cert" "${STKEYS_DIR}/${ts}-dnscrypt.cert" && \
    /usr/bin/dnscrypt-wrapper --gen-cert-file \
        --xchacha20 \
        --provider-publickey-file="${KEYS_DIR}/public.key" \
        --provider-secretkey-file="${KEYS_DIR}/secret.key" \
        --crypt-secretkey-file="${STKEYS_DIR}/${ts}.key" \
        --provider-cert-file="${STKEYS_DIR}/${ts}-xchacha20.cert" \
        --cert-file-expire-days=1 && \
    mv -f "${STKEYS_DIR}/${ts}-xchacha20.cert" "${STKEYS_DIR}/${ts}-dnscrypt-xchacha20.cert"
}

stkeys_files() {
     shopt -s nullglob
     files=($STKEYS_DIR/[0-9]*.key)
     file_list=$(printf ",%s" "${files[@]}")
     file_list=${file_list:1}
     echo "$file_list"
}

stcerts_files() {
     shopt -s nullglob
     files=($STKEYS_DIR/[0-9]*.cert)
     file_list=$(printf ",%s" "${files[@]}")
     file_list=${file_list:1}
     echo "$file_list"
}


if [ ! -f "$KEYS_DIR/provider_name" ]; then
    exit 1
fi
provider_name=$(cat "$KEYS_DIR/provider_name")

mkdir -p "$STKEYS_DIR"

# Remove any keys older than 1 day
prune_keys

# Generate a new set of keys
new_key

exec /usr/bin/dnscrypt-wrapper \
    --user=dnscrypt-wrapper \
    --listen-address=${LISTEN_ADDR} \
    --resolver-address=${RESOLVER_ADDR} \
    --provider-name="$provider_name" \
    --provider-cert-file="$(stcerts_files)" \
    --crypt-secretkey-file=$(stkeys_files) -V
