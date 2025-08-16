#!/bin/bash

# --- Find Steam installation ---
# Add potential Steam library locations here.
# Default native path:
NATIVE_PATH="$HOME/.steam/steam"
# Default Flatpak path:
FLATPAK_PATH="$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"

# Use the one that exists
if [ -d "$NATIVE_PATH" ]; then
    STEAM_DIR="$NATIVE_PATH"
elif [ -d "$FLATPAK_PATH" ]; then
    STEAM_DIR="$FLATPAK_PATH"
else
    # Exit if no common steam path is found. Eww will show an empty list.
    exit 1
fi

# --- Find all library folders ---
library_vdf="$STEAM_DIR/steamapps/libraryfolders.vdf"
temp_libs="/tmp/steam_libraries.txt"

# Start with the main library path
echo "$STEAM_DIR" > "$temp_libs"
# Add other library paths from the vdf file, if it exists
if [ -f "$library_vdf" ]; then
    grep -Po '"path"\s+"\K[^"]+' "$library_vdf" >> "$temp_libs"
fi

# --- Process games and output ---
while read -r lib; do
    # Skip if the library path doesn't exist
    [ ! -d "$lib/steamapps" ] && continue

    for file in "$lib/steamapps"/appmanifest_*.acf; do
        [ -f "$file" ] || continue
        appid=$(basename "$file" | sed 's/appmanifest_\(.*\)\.acf/\1/')
        # Skip Steamworks Common Redistributables etc.
        case "$appid" in
            228980|1070560|1391110) continue ;;
        esac
        name=$(grep '"name"' "$file" | sed -E 's/.*"name"\s+"(.*)"/\1/')
        last_played=$(grep '"LastPlayed"' "$file" | sed -E 's/.*"LastPlayed"\s+"([0-9]+)"/\1/')
        # Default to 0 if never played
        [ -z "$last_played" ] && last_played=0

        # Output data for sorting: last_played|appid|name
        icon_path=$(find "$STEAM_DIR/appcache/librarycache/${appid}" -maxdepth 1 -type f -regextype posix-extended -regex ".*/[0-9a-f]{40}\.jpg")
        if [ -z "$icon_path" ]; then
            icon_path=""
        fi


        echo "$last_played|$appid|$name|$icon_path"
    done
done < "$temp_libs" | sort -rn | cut -d'|' -f2,3,4 | jq -Rn '
  [inputs | select(length > 0)] 
  | map(split("|")) 
  | map({id: .[0], name: .[1], icon: .[2]})'