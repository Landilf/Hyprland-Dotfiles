#!/usr/bin/env bash

# Prevent multiple instances of slurp
if pgrep -x "slurp" > /dev/null; then
    exit 0
fi

# Create temporary image file
temp_img="/tmp/ocr_capture.png"

# Select region and capture screen
if ! grim -g "$(slurp)" "$temp_img"; then
    notify-send "OCR" "Screen capture cancelled"
    exit 1
fi

# Check available languages
available_langs=$(tesseract --list-langs)
langs="eng"

if echo "$available_langs" | grep -q "rus"; then
    langs="rus+eng"
fi

# Perform OCR
if tesseract "$temp_img" stdout -l "$langs" | wl-copy; then
    text=$(wl-paste)
    if [ -n "$text" ]; then
        notify-send "OCR" "Text copied to clipboard" -i chat-history-symbolic
    else
        notify-send "OCR" "No text found in the image" -u critical
    fi
else
    notify-send "OCR" "Error during text recognition" -u critical
fi

# Cleanup
rm "$temp_img"
