#!/bin/bash
# =============================================================================
# GitHub Repo Rename Skript
# =============================================================================
# Dieses Skript benennt deine problematischen Repos auf GitHub um.
#
# BENÖTIGT: GitHub Personal Access Token (Classic) mit "repo" Scope
# Erstelle einen Token unter: https://github.com/settings/tokens
#
# Usage:
#   export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
#   ./rename-repos.sh
# =============================================================================

set -e

GITHUB_USER="danialahmed2207"
API_BASE="https://api.github.com"

# Prüfe ob Token gesetzt ist
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Fehler: GITHUB_TOKEN ist nicht gesetzt."
    echo ""
    echo "So erstellst du einen Token:"
    echo "  1. Gehe zu https://github.com/settings/tokens"
    echo "  2. Klicke auf 'Generate new token (classic)'"
    echo "  3. Gib einen Namen ein (z.B. 'Repo Rename')"
    echo "  4. Aktiviere den 'repo' Scope (Häkchen setzen)"
    echo "  5. Klicke auf 'Generate token'"
    echo "  6. Kopiere den Token (wird nur einmal angezeigt!)"
    echo ""
    echo "Dann führe aus:"
    echo "  export GITHUB_TOKEN='ghp_xxxxxxxxxxxxxxxxxxxx'"
    echo "  ./rename-repos.sh"
    exit 1
fi

echo "🚀 GitHub Repo Rename Tool"
echo "========================="
echo ""

# Funktion zum Umbenennen eines Repos
rename_repo() {
    local old_name="$1"
    local new_name="$2"
    local action="$3"  # "rename" oder "private"

    echo ""
    echo "📦 Repo: $old_name"

    # Prüfe ob Repo existiert
    status=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$API_BASE/repos/$GITHUB_USER/$old_name")

    if [ "$status" != "200" ]; then
        echo "   ⚠️  Repo nicht gefunden oder kein Zugriff (HTTP $status)"
        return
    fi

    if [ "$action" == "private" ]; then
        echo "   🔒 Mache Repo privat..."
        response=$(curl -s -X PATCH \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d '{"private":true}' \
            "$API_BASE/repos/$GITHUB_USER/$old_name")

        if echo "$response" | grep -q '"private":true'; then
            echo "   ✅ Repo ist jetzt privat!"
        else
            echo "   ❌ Fehler beim Ändern der Sichtbarkeit"
            echo "$response" | grep -o '"message":"[^"]*"' || true
        fi

    elif [ "$action" == "rename" ]; then
        echo "   ✏️  Benenne um zu: $new_name"
        response=$(curl -s -X PATCH \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "{\"name\":\"$new_name\"}" \
            "$API_BASE/repos/$GITHUB_USER/$old_name")

        if echo "$response" | grep -q "\"name\":\"$new_name\""; then
            echo "   ✅ Erfolgreich umbenannt!"
            echo "   🔗 Neue URL: https://github.com/$GITHUB_USER/$new_name"
        else
            echo "   ❌ Fehler beim Umbenennen"
            echo "$response" | grep -o '"message":"[^"]*"' || true
        fi
    fi
}

echo "Wähle eine Aktion für jedes Repo:"
echo ""

# Repo 1: Gruppe
echo "1️⃣  'Gruppe'"
echo "   Option A: Umbenennen zu 'teamprojekt-webentwicklung'"
echo "   Option B: Auf privat stellen"
echo "   Option S: Überspringen"
read -p "   Deine Wahl (A/B/S): " choice1
case "$choice1" in
    [Aa]) rename_repo "Gruppe" "teamprojekt-webentwicklung" "rename" ;;
    [Bb]) rename_repo "Gruppe" "" "private" ;;
    *) echo "   ⏭️  Übersprungen" ;;
esac

# Repo 2: mein-digitales-notizbuch
echo ""
echo "2️⃣  'mein-digitales-notizbuch'"
echo "   Option A: Umbenennen zu 'notes-app-python'"
echo "   Option B: Auf privat stellen"
echo "   Option S: Überspringen"
read -p "   Deine Wahl (A/B/S): " choice2
case "$choice2" in
    [Aa]) rename_repo "mein-digitales-notizbuch" "notes-app-python" "rename" ;;
    [Bb]) rename_repo "mein-digitales-notizbuch" "" "private" ;;
    *) echo "   ⏭️  Übersprungen" ;;
esac

# Repo 3: charakter-captain-blaub-r
echo ""
echo "3️⃣  'charakter-captain-blaub-r'"
echo "   Option A: Umbenennen zu 'charakter-generator-python'"
echo "   Option B: Auf privat stellen"
echo "   Option S: Überspringen"
read -p "   Deine Wahl (A/B/S): " choice3
case "$choice3" in
    [Aa]) rename_repo "charakter-captain-blaub-r" "charakter-generator-python" "rename" ;;
    [Bb]) rename_repo "charakter-captain-blaub-r" "" "private" ;;
    *) echo "   ⏭️  Übersprungen" ;;
esac

echo ""
echo "========================="
echo "✅ Fertig!"
echo ""
echo "Prüfe dein Profil: https://github.com/$GITHUB_USER"
