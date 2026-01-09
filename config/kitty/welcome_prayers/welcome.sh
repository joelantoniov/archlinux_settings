#!/bin/zsh
BASE_DIR="$HOME/.config/kitty/welcome_prayers"
selected=$(ls $BASE_DIR/texts | shuf -n 1 | sed 's/\.txt$//')

# 1. Display the Sacred Image first
if [ -f "$BASE_DIR/images/$selected.png" ]; then
    # --align left and --scale-up ensure it fits the width without overlapping
    kitty +kitten icat --align left --scale-up "$BASE_DIR/images/$selected.png"
fi

# 2. Add a visual separator (a thin line)
echo -e "\e[1;30m──────────────────────────────────────────────────────────\e[0m"

# 3. Display the Sacred Text with "Liturgical" styling
# We use Bold (1) and White (37) for a clean, high-contrast look
echo -e "\e[1;37m"
cat "$BASE_DIR/texts/$selected.txt"
echo -e "\e[0m"
echo ""
