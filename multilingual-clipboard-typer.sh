#!/bin/bash

#######################################################################################
# Script Name : multilingual-clipboard-typer.sh
# Description : Script to type clipboard content and handle switching between
#               Arabic and English keyboard layouts.
#               This script automatically detects the language of the text in the
#               clipboard, switches between Arabic and English keyboard layouts as
#               needed, and types the text in the appropriate layout.
# Dependencies:
#               - wl-paste: To get clipboard content from Wayland-based systems.
#               - ydotool: To simulate key presses for switching keyboard layouts and
#                 typing text.
#               - gsettings: To get the current input source layout on GNOME-based
#                 systems.
# 
# Assumptions :
#               - Gnome Desktop Environment
#               - Wayland display server
#               - wl-paste utility installed for clipboard interaction
#               - ydotool installed for simulating keystrokes
#               - The script assumes UTF-8 locale support (e.g., en_US.UTF-8)
#               - The user has multiple keyboard layouts configured (Arabic and
#                 English)
#               - The script assumes the use of the "alt+shift" keybinding for 
#                 layout switching
#               - Clipboard content is a string, not binary data or images
#               - The script processes clipboard content in its raw form 
#                 (no pre-processing or sanitization)
# Args        :  none
# Author      :  Yahya Hamidaddin
# Email       :  yhamidaddin@open-alt.com
# License     :  GNU GPL-3
#######################################################################################


# Ensure the locale supports UTF-8 for proper character handling
export LANG="en_US.UTF-8"

# Get the content from the clipboard
clipboard_content=$(wl-paste)

# Global variable for the current layout of the keyboard
current_layout=""

# Function to check if a string contains Arabic characters
# It uses Unicode ranges for Arabic and special characters (×, ÷).
is_arabic() {
    clean_char=$(echo "$1" | sed "s/^[\"']*//;s/[\"']*$//")  # Remove surrounding quotes
    unicode=$(printf '%d' "'$clean_char")  # Get Unicode code point of the character

    # Arabic Unicode blocks (0x0600 - 0x06FF, 0x0750 - 0x077F) and special characters (×, ÷)
    if (( unicode >= 0x0600 && unicode <= 0x06FF )) || (( unicode >= 0x0750 && unicode <= 0x077F )) || (( unicode == 0x00D7 || unicode == 0x00F7 )); then
        return 0  # Character is Arabic or one of the special characters
    else
        return 1  # Character is not Arabic
    fi
}

# Function to check if a character is neutral (punctuation or space)
# This excludes specific punctuation marks (like semicolons, percent, and question marks)
is_neutral() {
    if [[ "$1" =~ [[:punct:][:space:]] ]] && [[ "$1" != ";" ]] && [[ "$1" != "%" ]] && [[ "$1" != "?" ]] || [[ "$1" =~ [\&\^\$\#\@\!\%\*\(\)\[\]\{\}\|\\\/] ]]; then
        return 0  # Character is neutral
    else
        return 1  # Character is not neutral
    fi
}

# Function to check if the layout is Arabic
# This checks the layout string for the presence of 'ara' or 'ar'
is_arabic_layout() {
    layout=$1
    if [[ "$layout" == *"ara"* ]] || [[ "$layout" == *"ar"* ]]; then
        return 1  # Arabic layout detected
    else
        return 0  # Non-Arabic layout detected
    fi
}

# Function to convert a string of keyboard layouts into a structured dataset
convert_layouts_string() {
    input=$1  # Input string representing the list of tuples

    # Step 1: Clean the input string (remove spaces, quotes, and brackets)
    input="${input//[[:space:]]/}"
    input="${input//\'/}"
    input="${input//[\[\]]/}"
    input="${input#\(}"
    input="${input%\)}"
    input="${input//),(/ }"  # Separate tuples by space

    declare -A dataset  # Associative array to store the dataset
    index=1
    IFS=' '  # Split input by spaces
    for tuple in $input; do
        IFS=',' read -r -a elements <<< "$tuple"
        dataset["$index,1"]="${elements[0]}"
        dataset["$index,2"]="${elements[1]}"
        ((index++))  # Increment index for the next tuple
    done

    # Output the dataset
    for key in "${!dataset[@]}"; do
        echo "$key:${dataset[$key]}"
    done
}

# Function to convert Arabic characters to their US QWERTY equivalents
convert_to_qwerty() {
    declare -A arabic_to_qwerty=(
        [ا]='h' [ب]='f' [ت]='j' [ث]='e' [ج]='[' [ح]='p' [خ]='o'
        [د]=']' [ذ]='`' [ر]='v' [ز]='.'
        [س]='s' [ش]='a' [ص]='w' [ض]='q' [ط]="'" [ظ]='/'
        [ع]='u' [غ]='y' [ف]='t' [ق]='r'
        [ك]=';' [ل]='g' [م]='l' [ن]='k' [ه]='i'
        [و]=',' [ي]='d' [ة]='m'
        [ؤ]='c' [ئ]='z' [ى]='n' [ء]='x'
        [أ]='H' [إ]='Y' [آ]='N' [لإ]='T' [لأ]='G' [لآ]='B'
        [ٌ]='R' [ُ]='E' [ً]='W' [َ]='Q' [ِ]='A' [ٍ]='S' [ْ]='X' [ّ]='~' [ـ]='J'
        [؟]='?' [،]='K' [؛]='P' [٪]='%' ['[']='F' [']']='D' ['.']='>' ["'"]='M' ['`']='U'
        ['{']='V' ['}']='C' ['<']='{' ['>']='}'
        ['/']='L' ['~']='Z' [',']='<' [×]='O' [÷]='I'
    )

    converted=""
    for (( i=0; i<${#1}; i++ )); do
        char="${1:$i:1}"
        if [[ ${arabic_to_qwerty[$char]} ]]; then
            converted="${converted}${arabic_to_qwerty[$char]}"
        else
            converted="${converted}${char}"
        fi
    done
    echo "$converted"
}

# Function to get the current keyboard layout (Arabic or English)
get_current_layout() {
    layouts_string=$(gsettings get org.gnome.desktop.input-sources mru-sources)
    layouts_array=$(convert_layouts_string "$layouts_string")
    declare -A dataset
    while IFS=":" read -r key value; do
        dataset["$key"]="$value"
    done <<< "$layouts_array"

    current_layout="${dataset[1,2]}"  # Current layout is in the second element of the first tuple
}

# Function to switch to the Arabic layout if necessary
switch_to_arabic() {
    get_current_layout
    if is_arabic_layout "$current_layout"; then
        ydotool key alt+shift  # Switch to Arabic layout
    fi
}

# Function to switch to the English layout if necessary
switch_to_english() {
    get_current_layout
    if ! is_arabic_layout "$current_layout"; then
        ydotool key alt+shift  # Switch to English layout
    fi
}

# Function to split clipboard content into segments based on language/layout
split_into_segments() {
    segments=()
    current_segment=""
    current_layout=""
    for (( i=0; i<${#clipboard_content}; i++ )); do
        char="${clipboard_content:$i:1}"

        if [[ "$char" == $'\n' ]]; then
            if [[ "$current_segment" ]]; then
                segments+=("$current_segment")
                current_segment=""
                current_layout=""
            fi
            segments+=("NEWLINE")
        elif is_arabic "$char"; then
            if [[ "$current_layout" != "arabic" && -n "$current_segment" ]]; then
                segments+=("$current_segment")
                current_segment=""
            fi
            current_segment+="$char"
            current_layout="arabic"
        elif is_neutral "$char"; then
            current_segment+="$char"
        else
            if [[ "$current_layout" != "english" && -n "$current_segment" ]]; then
                segments+=("$current_segment")
                current_segment=""
            fi
            current_segment+="$char"
            current_layout="english"
        fi
    done

    if [[ -n "$current_segment" ]]; then
        segments+=("$current_segment")
    fi

    for segment in "${segments[@]}"; do
        echo "$segment"
    done
}

# Function to process clipboard content by typing it in the appropriate layout
process_content() {
    mapfile -t segments < <(split_into_segments)

    for segment in "${segments[@]}"; do
        if [[ "$segment" == "NEWLINE" ]]; then
            ydotool key enter  # Simulate pressing RETURN for newlines
        elif is_arabic "$segment"; then
            converted_segment=$(convert_to_qwerty "$segment")
            switch_to_arabic
            ydotool type "$converted_segment"
        else
            escaped_segment=$(echo "$segment" | sed 's/-/\\-/g')
            switch_to_english
            ydotool type "$escaped_segment"
        fi
    done
}

# Process the clipboard content and type it in the appropriate layout
process_content
