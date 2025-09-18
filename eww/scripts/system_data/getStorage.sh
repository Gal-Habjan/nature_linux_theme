#!/bin/bash

# Start JSON array
jq -n '[]' > /tmp/disks.json

mounts="/ /mnt/shared /mnt/sata"

images=("$HOME/.config/eww/images/tree1.png" "$HOME/.config/eww/images/tree2.png" "$HOME/.config/eww/images/tree3.png" "$HOME/.config/eww/images/tree4.png")


df -B1 --output=source,size,used,avail,target | tail -n +2 | while read fs size used avail mount; do
    for m in $mounts; do
        if [ "$mount" = "$m" ]; then
            usage=$(( avail * 100 / size ))
            
            # Pick image index (0..3)
            imgIndex=$(( usage * 4 / 100 ))
            
            if [ $imgIndex -ge ${#images[@]} ]; then
                imgIndex=$((${#images[@]} - 1))
            fi
            image="${images[$imgIndex]}"

            available_gb=$(($avail/1024/1024/1024))
            total_gb=$(($size/1024/1024/1024))
            used_gb=$(($used/1024/1024/1024))
            jq --arg fs "$fs" \
               --arg mount "$mount" \
               --arg image "$image" \
               --argjson size "$total_gb" \
               --argjson used "$used_gb" \
               --argjson avail "$available_gb" \
               '. += [{filesystem: $fs, mountpoint: $mount, size: $size, used: $used, available: $avail, image_path: $image}]' \
               /tmp/disks.json > /tmp/disks.tmp && mv /tmp/disks.tmp /tmp/disks.json
        fi
    done
done
# Output final JSON
cat /tmp/disks.json
rm /tmp/disks.json
