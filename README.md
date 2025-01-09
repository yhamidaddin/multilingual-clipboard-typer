# Multilingual Clipboard Typer

A shell script designed to automate typing clipboard content in the appropriate keyboard layout (Arabic or English) based on the language detected in the clipboard. The script uses Wayland and GNOME-based tools like `wl-paste`, `ydotool`, and `gsettings` to interact with the clipboard and switch between Arabic and English layouts seamlessly.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Features](#features)
- [License](#license)
- [Contact](#contact)

## Overview

The `multilingual-clipboard-typer.sh` script helps automate the process of typing content from the clipboard while handling language-specific input requirements. The script detects the language of the clipboard content (Arabic or English) and automatically switches the keyboard layout to match the detected language. This is particularly useful for users who frequently work in both Arabic and English.

## Installation

To use this script, you need to have the following tools installed:

- `wl-paste`: A tool for accessing clipboard content on Wayland-based systems.
- `ydotool`: A utility for simulating keyboard presses to type text and switch layouts.
- `gsettings`: To get the current input layout on GNOME-based systems.

### Install Dependencies

Ensure that `wl-paste`, `ydotool`, and `gsettings` are installed on your system. You can install them as follows:

- **Install `wl-paste`**:
    - For Wayland-based systems, use:
    ```bash
    sudo apt install wl-clipboard
    ```

- **Install `ydotool`**:
    - Follow installation instructions from the [ydotool GitHub repository](https://github.com/wwmm/ydotool).

- **Install `gsettings`**:
    - This is typically available by default on GNOME-based systems.

### Clone the Repository

Clone the repository containing the script:
```bash
git clone https://github.com/yourusername/multilingual-clipboard-typer.git
```
Make the Script Executable

After cloning, navigate to the directory and make the script executable:

cd multilingual-clipboard-typer
chmod +x multilingual-clipboard-typer.sh

## Usage

To use the script, simply run it in your terminal. The script will automatically detect the language of the text in your clipboard and type it using the appropriate keyboard layout (Arabic or English).
```bash
./multilingual-clipboard-typer.sh
```

The script does not require any command-line arguments and will type the clipboard content accordingly.
## Dependencies

This script relies on the following tools:

    wl-paste: To fetch clipboard content from Wayland-based systems.
    ydotool: To simulate key presses and type content into active windows.
    gsettings: To retrieve the current input source layout in GNOME environments.

Additionally, the script assumes that you have:

    Multiple keyboard layouts configured (Arabic and English).
    UTF-8 locale support (e.g., en_US.UTF-8).
    The "Alt+Shift" keybinding configured for switching keyboard layouts.

## Features

    Automatic Layout Switching: The script detects whether the clipboard content is in Arabic or English and automatically switches the keyboard layout.
    Clipboard Content Handling: The script processes the clipboard content and types it in the correct language layout.
    Supports Arabic and English: It supports both Arabic and English layouts, converting Arabic characters into their corresponding English (QWERTY) equivalents.
    Newline Handling: The script processes newlines and types them correctly as Enter key presses.

## License

This script is licensed under the GNU General Public License v3.0. You can freely modify and redistribute it under the terms of the license.
## Contact

For questions, feedback, or suggestions, feel free to reach out:

    Author: Yahya Hamidaddin
    Email: yhamidaddin@open-alt.com
