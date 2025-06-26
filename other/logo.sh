#!/bin/bash

# Цвета
b=$'\033[34m' # Blue
m=$'\033[35m' # Magenta
r=$'\033[0m'  # Reset

# Функция подсветки "█" блоков
function print_colored() {
  echo "${b}$(echo "$1" | sed -E "s/(█+)/${m}\1${b}/g")${r}"
}

echo
echo
print_colored " ███████╗███████╗██████╗  ██████╗ ██╗     ██╗ █████╗     ███╗   ██╗ ██████╗ ██████╗ ███████╗"
print_colored " ██╔════╝██╔════╝██╔══██╗██╔═══██╗██║     ██║██╔══██╗    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝"
print_colored " ███████╗█████╗  ██████╔╝██║   ██║██║     ██║███████║    ██╔██╗ ██║██║   ██║██║  ██║█████╗  "
print_colored " ╚════██║██╔══╝  ██╔═══╝ ██║   ██║██║     ██║██╔══██║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝  "
print_colored " ███████║███████╗██║     ╚██████╔╝███████╗██║██║  ██║    ██║ ╚████║╚██████╔╝██████╔╝███████╗"
print_colored " ╚══════╝╚══════╝╚═╝      ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝"
echo
echo

# Информация в рамке
info_lines=(
  "✦ Made by Pittpv"
  "✦ Feedback & Support in Tg: https://t.me/+DLsyG6ol3SFjM2Vk"
  "✦ Donate"
  "  EVM: 0x4FD5eC033BA33507E2dbFE57ca3ce0A6D70b48Bf"
  "  SOL: C9TV7Q4N77LrKJx4njpdttxmgpJ9HGFmQAn7GyDebH4R"
)

# Вычисляем максимальную длину строки (учёт Unicode, без цветов)
max_len=0
for line in "${info_lines[@]}"; do
  clean_line=$(echo -e "$line" | sed -E 's/\x1B\[[0-9;]*[mK]//g')
  line_length=$(echo -n "$clean_line" | wc -m)
  [ "$line_length" -gt "$max_len" ] && max_len=$line_length
done

# Рамка
top_border="╔$(printf '═%.0s' $(seq 1 $((max_len + 2))))╗"
bottom_border="╚$(printf '═%.0s' $(seq 1 $((max_len + 2))))╝"

# Печать рамки
echo -e "${b}${top_border}${r}"
for line in "${info_lines[@]}"; do
  clean_line=$(echo -e "$line" | sed -E 's/\x1B\[[0-9;]*[mK]//g')
  line_length=$(echo -n "$clean_line" | wc -m)
  padding=$((max_len - line_length))
  printf "${b}║ ${m}%s%*s ${b}║\n" "$line" "$padding" ""
done
echo -e "${b}${bottom_border}${r}"
echo
