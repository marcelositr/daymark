#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <appimagetool-path> <runtime-path>" >&2
  exit 64
fi

APPIMAGETOOL="$1"
APPIMAGE_RUNTIME="$2"

if [ ! -x "$APPIMAGETOOL" ]; then
  echo "appimagetool is missing or not executable: $APPIMAGETOOL" >&2
  exit 69
fi
if [ ! -f "$APPIMAGE_RUNTIME" ]; then
  echo "AppImage runtime is missing: $APPIMAGE_RUNTIME" >&2
  exit 69
fi

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUNDLE_DIR="$ROOT_DIR/build/linux/x64/release/bundle"
PACKAGING_DIR="$ROOT_DIR/linux/packaging"
WORK_DIR="$ROOT_DIR/build/linux-packaging"
OUTPUT_DIR="$ROOT_DIR/build/distributables"
DESKTOP_FILE="io.github.marcelositr.daymark.desktop"
METAINFO_FILE="io.github.marcelositr.daymark.appdata.xml"
ICON_FILE="io.github.marcelositr.daymark.png"
DECLARED_VERSION=$(awk '/^version: / { print $2; exit }' "$ROOT_DIR/pubspec.yaml")
VERSION=${DECLARED_VERSION%%+*}
case "$VERSION" in
  *[!0-9A-Za-z.+-]*|'')
    echo "Invalid application version in pubspec.yaml: $DECLARED_VERSION" >&2
    exit 65
    ;;
esac

DEB_VERSION=$(printf '%s' "$VERSION" | sed 's/-/~/')
DEB_ROOT="$WORK_DIR/deb"
APP_DIR="$WORK_DIR/Daymark.AppDir"
DEB_OUTPUT="$OUTPUT_DIR/daymark_${VERSION}_amd64.deb"
APPIMAGE_OUTPUT="$OUTPUT_DIR/Daymark-${VERSION}-x86_64.AppImage"

if [ ! -x "$BUNDLE_DIR/daymark" ]; then
  echo "Missing Linux release bundle. Run flutter build linux --release first." >&2
  exit 66
fi

rm -rf "$WORK_DIR" "$OUTPUT_DIR"
mkdir -p \
  "$DEB_ROOT/DEBIAN" \
  "$DEB_ROOT/opt/daymark" \
  "$DEB_ROOT/usr/bin" \
  "$DEB_ROOT/usr/share/applications" \
  "$DEB_ROOT/usr/share/icons/hicolor/1024x1024/apps" \
  "$DEB_ROOT/usr/share/metainfo" \
  "$APP_DIR/usr/lib/daymark" \
  "$APP_DIR/usr/bin" \
  "$APP_DIR/usr/share/applications" \
  "$APP_DIR/usr/share/icons/hicolor/1024x1024/apps" \
  "$APP_DIR/usr/share/metainfo" \
  "$OUTPUT_DIR"

cp -a "$BUNDLE_DIR/." "$DEB_ROOT/opt/daymark/"
cp "$PACKAGING_DIR/$DESKTOP_FILE" \
  "$DEB_ROOT/usr/share/applications/$DESKTOP_FILE"
cp "$PACKAGING_DIR/$METAINFO_FILE" \
  "$DEB_ROOT/usr/share/metainfo/$METAINFO_FILE"
cp "$ROOT_DIR/assets/branding/daymark-icon.png" \
  "$DEB_ROOT/usr/share/icons/hicolor/1024x1024/apps/$ICON_FILE"

cat > "$DEB_ROOT/usr/bin/daymark" <<'EOF'
#!/bin/sh
exec /opt/daymark/daymark "$@"
EOF
chmod 0755 "$DEB_ROOT/usr/bin/daymark"

cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: daymark
Version: $DEB_VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Marcelo Trindade <marcelositr@users.noreply.github.com>
Depends: libgtk-3-0, libstdc++6
Homepage: https://devnux.com.br/daymark
Description: Minimal, local-first Bullet Journal
 Daymark is an encrypted, offline-first digital Bullet Journal for Linux.
EOF

chmod -R go-w "$DEB_ROOT"
dpkg-deb --build --root-owner-group "$DEB_ROOT" "$DEB_OUTPUT"

cp -a "$BUNDLE_DIR/." "$APP_DIR/usr/lib/daymark/"
cp "$PACKAGING_DIR/$DESKTOP_FILE" \
  "$APP_DIR/usr/share/applications/$DESKTOP_FILE"
cp "$PACKAGING_DIR/$METAINFO_FILE" \
  "$APP_DIR/usr/share/metainfo/$METAINFO_FILE"
cp "$PACKAGING_DIR/$DESKTOP_FILE" "$APP_DIR/$DESKTOP_FILE"
cp "$ROOT_DIR/assets/branding/daymark-icon.png" \
  "$APP_DIR/usr/share/icons/hicolor/1024x1024/apps/$ICON_FILE"
cp "$ROOT_DIR/assets/branding/daymark-icon.png" "$APP_DIR/$ICON_FILE"
ln -s ../lib/daymark/daymark "$APP_DIR/usr/bin/daymark"
ln -s "$ICON_FILE" "$APP_DIR/.DirIcon"

cat > "$APP_DIR/AppRun" <<'EOF'
#!/bin/sh
APPDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$APPDIR/usr/lib/daymark/daymark" "$@"
EOF
chmod 0755 "$APP_DIR/AppRun"
chmod -R go-w "$APP_DIR"

ARCH=x86_64 "$APPIMAGETOOL" --appimage-extract-and-run \
  --no-appstream --runtime-file "$APPIMAGE_RUNTIME" \
  "$APP_DIR" "$APPIMAGE_OUTPUT"
chmod 0755 "$APPIMAGE_OUTPUT"

desktop-file-validate "$PACKAGING_DIR/$DESKTOP_FILE"
if command -v appstreamcli >/dev/null 2>&1; then
  appstreamcli validate --no-net "$PACKAGING_DIR/$METAINFO_FILE"
fi
dpkg-deb --info "$DEB_OUTPUT" >/dev/null
dpkg-deb --contents "$DEB_OUTPUT" >/dev/null
"$APPIMAGE_OUTPUT" --appimage-extract >/dev/null
rm -rf "$ROOT_DIR/squashfs-root"

printf 'Created %s\nCreated %s\n' "$DEB_OUTPUT" "$APPIMAGE_OUTPUT"
