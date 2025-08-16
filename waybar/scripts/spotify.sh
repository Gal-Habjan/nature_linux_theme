#!/bin/bash

if playerctl --list-all | grep -q spotify; then
    status=$(playerctl -p spotify status 2>/dev/null)
    if [ "$status" != "Stopped" ]; then
        title=$(playerctl -p spotify metadata title)
        artist=$(playerctl -p spotify metadata artist)
        pos=$(playerctl -p spotify position)   # seconds
        dur=$(playerctl -p spotify metadata mpris:length) # microseconds
        dur=$((dur / 1000000))
        #remove decimal points
        pos=${pos%.*}
        dur=${dur%.*}
        # progress bar
        bar_length=5
        filled=$((pos * bar_length))
        filled=$((filled / dur ))
        #echo $filled
        empty=$((bar_length - filled - 1))
        
        #echo $filled
        if [ "$filled" -gt 0 ]; then
            
            filledBar=$(printf '█%.0s' $(seq 1 $filled))
        fi

        partial=$(( (pos * bar_length * 7 / dur) % 7 ))
        
# Map partial to character
        blocks=(  "▏" "▎" "▍" "▌" "▋" "▊" "▉" "█" )

        partial_char=${blocks[$partial]}
        filledBar+=$partial_char
        
        if [ "$empty" -gt 0 ]; then
            emptyBar+=$(printf '░%.0s' $(seq 1 $empty))
        fi
        # time format
        min_pos=$((pos / 60))
        sec_pos=$((pos % 60))
        min_dur=$((dur / 60))
        sec_dur=$((dur % 60))

        max_length=30
        full_text="$title - $artist"
        if [ ${#full_text} -gt $max_length ]; then
            cut_length=$((max_length - 2))
            full_text="${full_text:0:$cut_length}.."
        fi

        bar_html="<span color='#265336'>$filledBar</span><span foreground='#111B27'>$emptyBar</span>"
        echo "{\"text\": \"$full_text |$bar_html| \", \"class\": \"spotify\"}"
        exit 0
    fi
fi

echo "{\"text\": \"\", \"class\": \"spotify\"}"
