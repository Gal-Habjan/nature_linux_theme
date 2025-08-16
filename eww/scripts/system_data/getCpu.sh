#!/bin/bash

# Read CPU stats
read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

# Calculate total and idle
idle_total=$((idle + iowait))
total=$((user + nice + system + idle + iowait + irq + softirq + steal))

# Get previous stats (to calculate usage over interval)
if [ -f /tmp/cpu_prev ]; then
    read prev_total prev_idle < /tmp/cpu_prev
else
    prev_total=$total
    prev_idle=$idle_total
fi

# Save current stats for next run
echo "$total $idle_total" > /tmp/cpu_prev

# Calculate usage percentage
diff_total=$((total - prev_total))
if [ $diff_total -eq 0 ]; then
    usage=1
    
fi
diff_idle=$((idle_total - prev_idle))
usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))


images=("$HOME/.config/eww/images/tree4.png" "$HOME/.config/eww/images/tree3.png" "$HOME/.config/eww/images/tree2.png" "$HOME/.config/eww/images/tree1.png")

imgIndex=$((usage * 4 / 100 ))

if [ $imgIndex -ge ${#images[@]} ]; then
    imgIndex=$((${#images[@]} - 1))
fi
image_path="${images[$imgIndex]}"
# Output JSON
jq -n --arg usage "$usage" --arg image_path "$image_path" \
   '{cpu_usage_percent: ($usage|tonumber), image_path: $image_path}'