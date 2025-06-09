#!/bin/bash

#chmod +x reset-iptables.sh && ./reset-iptables.sh

echo -e "\n⚠️  ВНИМАНИЕ: Этот скрипт сбросит все iptables правила и перезапустит Docker."
echo -e "\n❗ Это может повлиять на безопасность и текущие соединения."
read -p "Вы уверены, что хотите продолжить? (yes/[no]): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo -e "\n❌ Отменено пользователем."
    exit 1
fi

echo -e "\n🛑 Остановка Docker..."
sudo systemctl stop docker
if [[ $? -ne 0 ]]; then
    echo -e "\n❗ Не удалось остановить Docker. Продолжение..."
else
    echo -e "\n✅ Docker остановлен."
fi

echo -e "\n🧹 Сброс iptables таблиц..."

tables=("filter" "nat" "mangle" "raw")
for table in "${tables[@]}"; do
    echo -e "\n➡️  Очистка таблицы $table..."
    sudo iptables -t $table -F
    sudo iptables -t $table -X
done

echo -e "\n✅ Все iptables таблицы очищены."

echo -e "\n🔧 Установка политик по умолчанию в ACCEPT..."
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
echo -e "\n✅ Политики по умолчанию установлены."

read -p "Запустить Docker снова? (yes/[no]): " restart
if [[ "$restart" == "yes" ]]; then
    echo -e "\n🚀 Запуск Docker..."
    sudo systemctl start docker
    if [[ $? -eq 0 ]]; then
        echo -e "\n✅ Docker запущен."
    else
        echo -e "\n❗ Ошибка при запуске Docker."
    fi
else
    echo -e "\nℹ️ Docker не был перезапущен."
fi

echo -e "\n🏁 Скрипт завершён."




