#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST="$DIR/dist"
STAGE="$DIST/stage"
SDK_LOCAL="$(cd "$DIR/../hero-armory-sdk" 2>/dev/null && pwd || true)"

rm -rf "$STAGE"
mkdir -p "$DIST" "$STAGE"

WORK_ENV=()
TMP_WORK=""
cleanup() {
  if [[ -n "$TMP_WORK" && -f "$TMP_WORK" ]]; then
    rm -f "$TMP_WORK"
  fi
}
trap cleanup EXIT

if [[ -n "$SDK_LOCAL" && -f "$SDK_LOCAL/go.mod" ]]; then
  TMP_WORK="$(mktemp /tmp/hero-armory-example-XXXXXX.work)"
  printf 'go 1.24\n\nuse (\n\t%s\n\t%s\n)\n' "$DIR" "$SDK_LOCAL" > "$TMP_WORK"
  WORK_ENV=("GOWORK=$TMP_WORK")
fi

echo "[plugin-example] Building server_plugin.wasm..."
(
  cd "$DIR"
  env "${WORK_ENV[@]}" GOOS=wasip1 GOARCH=wasm CGO_ENABLED=0 \
    go build -buildmode=c-shared -trimpath -ldflags="-s -w" -o "$DIST/server_plugin.wasm" ./server
)

echo "[plugin-example] Building client.wasm..."
(
  cd "$DIR"
  env "${WORK_ENV[@]}" GOOS=wasip1 GOARCH=wasm CGO_ENABLED=0 \
    go build -buildmode=c-shared -trimpath -ldflags="-s -w" -o "$STAGE/client.wasm" ./client
)
cp "$DIR/manifest.json" "$STAGE/manifest.json"
if [[ -f "$DIR/icon.png" ]]; then
  cp "$DIR/icon.png" "$STAGE/icon.png"
fi
if [[ -d "$DIR/assets" ]]; then
  cp -r "$DIR/assets" "$STAGE/assets"
fi

echo "[plugin-example] Packing client_plugin.gtpack..."
if [[ -n "$SDK_LOCAL" && -f "$SDK_LOCAL/go.mod" ]]; then
  (
    cd "$SDK_LOCAL"
    GOWORK=off go run ./cmd/pack -dir "$STAGE" -out "$DIST/client_plugin.gtpack"
  )
else
  go run github.com/mmoboy/hero-armory-sdk/cmd/pack@v1.1.0 -dir "$STAGE" -out "$DIST/client_plugin.gtpack"
fi

rm -rf "$STAGE"
echo "[plugin-example] Done:"
ls -lh "$DIST/server_plugin.wasm" "$DIST/client_plugin.gtpack"
