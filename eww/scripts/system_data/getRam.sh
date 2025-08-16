#!/bin/bash

# Read memory in kB
total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
used_kb=$((total_kb - available_kb))

# Convert kB → MB for image selection (integer math)
total_mb=$((total_kb / 1024))
used_mb=$((used_kb / 1024))
available_mb=$((available_kb / 1024))

# Select image based on usage
images=(
    "$HOME/.config/eww/images/tree4.png"
    "$HOME/.config/eww/images/tree3.png"
    "$HOME/.config/eww/images/tree2.png"
    "$HOME/.config/eww/images/tree1.png"
)

imgIndex=$((used_mb * 4 / total_mb))
if [ $imgIndex -ge ${#images[@]} ]; then
    imgIndex=$((${#images[@]} - 1))
fi
image_path="${images[$imgIndex]}"

# Convert to GB for display only
total_gb=$(echo "scale=2; $total_kb/1024/1024" | bc)
used_gb=$(echo "scale=2; $used_kb/1024/1024" | bc)
available_gb=$(echo "scale=2; $available_kb/1024/1024" | bc)

# Output JSON
jq -n --arg total "$total_gb" --arg used "$used_gb" --arg available "$available_gb" --arg image_path "$image_path" \
   '{total_gb: ($total|tonumber), used_gb: ($used|tonumber), available_gb: ($available|tonumber), image_path: $image_path}'
