#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  Script de build White-Label
#  Usage :
#    ./scripts/build.sh smr          → APK release Android
#    ./scripts/build.sh smr apk      → APK release Android
#    ./scripts/build.sh smr aab      → AAB release Android (Play Store)
#    ./scripts/build.sh smr ios      → IPA release iOS
#    ./scripts/build.sh smr all      → APK + AAB + IPA
# ═══════════════════════════════════════════════════════════════════

set -e

CLIENT="${1:-smr}"
TARGET="${2:-apk}"
ENV_FILE="envs/client_${CLIENT}.env"

# ── Vérification du fichier de config ───────────────────────────
if [ ! -f "$ENV_FILE" ]; then
  echo "❌  Fichier de config introuvable : $ENV_FILE"
  echo "    Crée envs/client_<NOM>.env depuis envs/client_smr.env"
  exit 1
fi

echo "✅  Config : $ENV_FILE"

# ── Lecture des variables ────────────────────────────────────────
declare -A VARS
while IFS='=' read -r key value; do
  # Ignorer commentaires et lignes vides
  [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
  VARS["$key"]="$value"
done < "$ENV_FILE"

# ── Construction des --dart-define ──────────────────────────────
DEFINES=""
for key in "${!VARS[@]}"; do
  DEFINES="$DEFINES --dart-define=${key}=${VARS[$key]}"
done

APP_NAME="${VARS[APP_NAME]:-Event App}"
APP_PACKAGE="${VARS[APP_PACKAGE]:-com.example.app}"
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  App     : $APP_NAME"
echo "  Package : $APP_PACKAGE"
echo "  Version : $VERSION"
echo "  Target  : $TARGET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

build_apk() {
  echo ""
  echo "🔨  Build APK release..."
  flutter build apk --release $DEFINES
  APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
  APK_DST="build/releases/${CLIENT}_$(echo "$VERSION" | tr '+' '_').apk"
  mkdir -p build/releases
  cp "$APK_SRC" "$APK_DST"
  echo "✅  APK → $APK_DST"
}

build_aab() {
  echo ""
  echo "🔨  Build AAB release (Play Store)..."
  flutter build appbundle --release $DEFINES
  AAB_SRC="build/app/outputs/bundle/release/app-release.aab"
  AAB_DST="build/releases/${CLIENT}_$(echo "$VERSION" | tr '+' '_').aab"
  mkdir -p build/releases
  cp "$AAB_SRC" "$AAB_DST"
  echo "✅  AAB → $AAB_DST"
}

build_ios() {
  echo ""
  echo "🔨  Build iOS release..."
  flutter build ios --release --no-codesign $DEFINES
  echo "✅  iOS build terminé — ouvre Xcode pour archiver et exporter l'IPA"
}

case "$TARGET" in
  apk)  build_apk ;;
  aab)  build_aab ;;
  ios)  build_ios ;;
  all)  build_apk; build_aab; build_ios ;;
  *)
    echo "❌  Cible inconnue : $TARGET  (valeurs : apk | aab | ios | all)"
    exit 1
    ;;
esac

echo ""
echo "🎉  Build terminé !"
