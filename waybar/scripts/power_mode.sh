#!/usr/bin/env bash
gov_file=$(ls /sys/devices/system/cpu/cpufreq/policy*/scaling_governor 2>/dev/null | head -n1)
gov=$(cat "$gov_file" 2>/dev/null)
# Map governor → mode
case "$gov" in
  performance) mode="performance" ;;
  powersave)   mode="power-saver" ;;
  schedutil|ondemand|conservative) mode="balanced" ;;
  *) mode="$gov" ;;
esac
# Detect power source for tooltip (optional)
if grep -q 1 /sys/class/power_supply/AC*/online 2>/dev/null || grep -q 1 /sys/class/power_supply/ACAD/online 2>/dev/null; then
  source="AC"
else
  source="Battery"
fi
# Icons (Nerd Font friendly but still fine as text)
case "$mode" in
  performance) icon="" ;;   
  balanced)    icon="" ;;   
  power-saver) icon="" ;;   
  *)           icon="󰘚" ;;   
esac
printf '{"text":"%s","alt":"%s","class":"%s","tooltip":"auto-cpufreq · gov: %s · source: %s"}\n' \
  "$icon" "$mode" "$mode" "$gov" "$source" 