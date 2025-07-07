#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
VIOLET='\033[0;35m'
RESET='\033[0m'

SCRIPT_VERSION="1.5.1"

# Default Port Configurations
# These variables define the default port numbers for various services.
# They can be overridden by user input or loaded from a configuration file if such a mechanism is implemented.
EXECUTION_RPC_PORT_DEFAULT="8545"
EXECUTION_P2P_PORT_DEFAULT="30303"
EXECUTION_AUTH_RPC_PORT_DEFAULT="8551" # Standard port for authenticated RPC
CONSENSUS_RPC_PORT_DEFAULT="5052" # Used for HTTP API (e.g., Prysm's gRPC gateway, Lighthouse/Teku REST API)
CONSENSUS_P2P_PORT_DEFAULT="9000" # Common P2P port for consensus clients (TCP/UDP)

# Effective ports to be used by the script.
# These are initialized with the default values and may be updated later by user input or a config file.
EXECUTION_RPC_PORT=$EXECUTION_RPC_PORT_DEFAULT
EXECUTION_P2P_PORT=$EXECUTION_P2P_PORT_DEFAULT
EXECUTION_AUTH_RPC_PORT=$EXECUTION_AUTH_RPC_PORT_DEFAULT
CONSENSUS_RPC_PORT=$CONSENSUS_RPC_PORT_DEFAULT
CONSENSUS_P2P_PORT=$CONSENSUS_P2P_PORT_DEFAULT

function show_logo() {
    echo -e "${BLUE}$(t "welcome")${RESET}"
    curl -s https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/other/logo.sh | bash
}

# Language selection
echo -e ${BLUE}"Select language / Выберите язык:${RESET}"
select lang in "English" "Русский"; do
    case $lang in
        English)
            lang="en"
            break
            ;;
        Русский)
            lang="ru"
            break
            ;;
        *)
            echo "Invalid choice, please select again"
            ;;
    esac
done

# Translation function
function t {
    local key="$1"
    shift

    if [[ "$lang" == "en" ]]; then
        case "$key" in
            "welcome") echo "              Welcome to the Sepolia Ethereum Node Setup and Management Script" ;;
            "jwt_gen") echo "🔐 Generating jwt.hex..." ;;
            "choose_client") echo "🔧 Choose consensus client:" ;;
            "client_selected") echo "✅ Selected client: $1" ;;
            "invalid_choice") echo "❌ Invalid choice. Please try again." ;;
            "creating_compose") echo "🛠️ Creating docker-compose.yml for client $1..." ;;
            "unknown_client") echo "❌ Unknown client: $1" ;;
            "node_install") echo "🚀 Installing Sepolia node..." ;;
            "node_installed") echo "✅ Node installed and running." ;;
            "node_update") echo "🔄 Updating containers..." ;;
            "node_updated") echo "✅ Update completed." ;;
            "select_logs") echo "📋 Select logs:" ;;
            "back") echo "Back" ;;
            "check_sync") echo "📡 Checking synchronization..." ;;
            "execution") echo "🧠 Execution ($1):" ;;
            "execution_synced") echo "   ✅ $1 synchronized" ;;
            "execution_syncing") echo "⏳ $1 is syncing..." ;;
            "prysm_synced") echo "   ✅ Prysm synchronized" ;;
            "prysm_syncing") echo "⏳ Prysm is syncing..." ;;
            "teku_synced") echo "   ✅ Teku synchronized" ;;
            "teku_syncing") echo "⏳ Teku is syncing..." ;;
            "lighthouse_synced") echo "   ✅ Lighthouse synchronized" ;;
            "lighthouse_syncing") echo "⏳ Lighthouse is syncing..." ;;
            "syncing") echo "⏳ $1 is syncing..." ;;
            "current_block") echo "   Current block:     $1" ;;
            "target_block") echo "   Target block:     $1" ;;
            "blocks_left") echo "   Blocks remaining:  $1" ;;
            "progress") echo "   Progress:         $1%" ;;
            "sync_speed") echo "📏 Estimating sync speed..." ;;
            "speed") echo "   Speed:         $1 blocks/sec" ;;
            "eta") echo "   Estimated time:   $1" ;;
            "low_speed") echo "   ⏱️ Speed too low to estimate" ;;
            "consensus") echo "🌐 Consensus ($1):" ;;
            "no_sync_data") echo "⚠️ No /eth/v1/node/syncing data, trying finality..." ;;
            "beacon_active") echo "✅ Beacon chain active (finality data received)" ;;
            "no_finality") echo "❌ Failed to get finality data" ;;
            "health") echo "❤️ Beacon node health:" ;;
            "enter_tg_token") echo "Enter Telegram token: " ;;
            "enter_tg_chat") echo "Enter Telegram chat_id: " ;;
            "select_cron") echo "Select cron agent interval:" ;;
            "cron_options") echo $'1) Every 5 minutes\n2) Every 10 minutes\n3) Every 15 minutes\n4) Every 30 minutes\n5) Every hour' ;;
            "invalid_interval") echo "Invalid choice. Setting default interval: every 10 minutes." ;;
            "cron_installed") echo "✅ Cron agent installed with interval: $1" ;;
            "cron_removed") echo "🗑️ Agent and cron task removed." ;;
            "stop_containers") echo "🛑 Stopping containers... " ;;
            "containers_stopped") echo "✅ Containers stopped." ;;
            "no_compose") echo "⚠️ docker-compose.yml not found." ;;
            "disk_usage") echo "💽 Disk space usage:" ;;
            "geth_usage") echo "🔧 Geth:" ;;
            "client_usage") echo "🔧 Consensus client ($1):" ;;
            "container_not_running") echo "Container $1 not running or unknown data path" ;;
            "client_not_found") echo "Client file not found: $1" ;;
            "confirm_delete") echo "⚠️ This will delete all node data. Continue? (y/n)" ;;
            "deleted") echo "🗑️ Node completely removed." ;;
            "cancelled") echo "❌ Deletion cancelled." ;;
            "menu_title") echo "====== Sepolia Node Manager ======" ;;
            "menu_options") echo -e '1) Install prerequisites (Docker and other software)\n2) Install node\n3) Update node\n4) Check logs\n5) Check sync status\n6) Setup cron agent wiht Tg notifications\n7) Remove cron agent\n8) Stop containers\n9) Start containers\n\033[31m10) Delete node\033[0m\n11) Change ports for installed node\n12) Check disk usage\n13) Firewall management\n14) Check RPC server\n\033[31m0) Exit\033[0m' ;;
            "goodbye") echo "👋 Goodbye!" ;;
            "invalid_option") echo "❌ Invalid choice, try again." ;;
            "select_option") echo "Select option: " ;;
            "start_containers") echo "🏃‍➡️ Start containers" ;;
            "containers_started") echo "✅ Containers started." ;;
            "client_label_prysm") echo "Prysm (recommended)" ;;
            "client_label_teku") echo "Teku" ;;
            "client_label_lighthouse") echo "Lighthouse" ;;
            "update_base") echo "🛠 Updating system and installing base packages..." ;;
            "install_docker") echo "📦 Installing Docker..." ;;
            "docker_exists") echo "✅ Docker is already installed. Skipping." ;;
            "install_compose") echo "📦 Installing Docker Compose..." ;;
            "compose_exists") echo "✅ Docker Compose is already installed. Skipping." ;;
            "requirements_done") echo "✅ All requirements successfully installed." ;;
            "autoremove_clean") echo "Cleaning the system from unnecessary files..." ;;
            "firewall_menu") echo "🛡️ Firewall management:" ;;
            "firewall_enable") echo "Enable firewall" ;;
            "firewall_local_ports") echo "Allow ports for local usage" ;;
            "firewall_remote_ip") echo "Allow/deny ports for another IP address" ;;
            "enabling_firewall") echo "Enabling firewall..." ;;
            "setting_local_ports") echo "Configuring ports for local use..." ;;
            "enter_ip") echo "Enter IP address of the server: " ;;
            "setting_remote_ports") echo "Configuring ports for IP" ;;
            "return_main_menu") echo "Returning to main menu." ;;
            "firewall_enabled_success") echo "✅ Firewall successfully enabled." ;;
            "local_ports_success") echo "✅ Local ports successfully configured." ;;
            "remote_ports_success") echo "✅ Remote IP ports successfully configured." ;;
            "confirm_enable_firewall") echo "Do you really want to enable the firewall?" ;;
            "firewall_enable_cancelled") echo "❌ Firewall enabling cancelled." ;;
            "firewall_already_enabled") echo "🔒 Firewall is already enabled." ;;
            "choose_execution_client_prompt") echo "Choose execution client:" ;;
            "execution_client_selected") echo "✅ Selected execution client: $1" ;;
            "client_label_geth") echo "Geth (recommended)" ;;
            "client_label_reth") echo "Reth" ;;
            "client_label_nethermind") echo "Nethermind" ;;
            "unknown_execution_client") echo "❌ Unknown execution client: $1." ;;
            "execution_client_usage") echo "🔧 Execution client ($1):" ;;
            "jwt_not_found_error") echo "❌ Critical Error: JWT file not found at $1 before starting containers. Halting." ;;
            "sync_data_invalid") echo "❌ The synchronization data is invalid. If the client was launched recently, then try again later." ;;
            "teku_no_sync_data") echo "No Teku synchronization data. Please check again later." ;;
            "lighthouse_no_sync_data") echo "No Lighthouse synchronization data. Please check again later." ;;
            "prysm_no_sync_data") echo "No Prysm synchronization data. Please check again later." ;;
            "teku_no_finality") echo "Teku - no finality." ;;
            "lighthouse_no_finality") echo "Lighthouse - no finality." ;;
            "prysm_no_finality") echo "Prysm - no finality." ;;
            "teku_health") echo "Teku health." ;;
            "firewall_delete_rules") printf "Delete rules for ports (ExecRPC: %s, ConsRPC: %s, ExecP2P: %s, ConsP2P: %s)" "$1" "$2" "$3" "$4" ;;
            "firewall_view_rules") echo "View UFW rules" ;;
            "firewall_disable") echo "Disable firewall" ;;
            "deleting_old_rules") echo "Deleting old rules..." ;;
            "no_matching_rules") printf "No rules found for current ports (%s, %s, %s, %s)." "$1" "$2" "$3" "$4" ;;
            "deleting_rule_number") echo "Deleting rule №" ;;
            "rules_deleted_success") echo "✅ Rules successfully deleted." ;;
            "view_ufw_rules") echo "UFW rules" ;;
            "press_enter_to_continue") echo "Press Enter to go back..." ;;
            "disabling_firewall") echo "Disabling firewall..." ;;
            "confirm_disable_firewall") echo "Do you really want to disable the firewall?" ;;
            "firewall_disabled_success") echo "✅ Firewall successfully disabled." ;;
            "firewall_disable_cancelled") echo "❌ Firewall disabling cancelled." ;;
            "confirm_delete_firewall_rules") printf "Are you sure you want to delete firewall rules for ports %s, %s, %s, %s?" "$1" "$2" "$3" "$4" ;;
            "firewall_delete_cancelled") echo "❌ Firewall rule deletion cancelled." ;;
            "rules_to_be_deleted") echo "The following firewall rules will be deleted:" ;;
            "ask_custom_ports_prompt") echo "Do you want to configure custom ports? (yes/no, default: no)" ;;
            "enter_exec_rpc_port") printf "Enter Execution Client RPC Port (default: %s): " "$1" ;;
            "enter_exec_p2p_port") printf "Enter Execution Client P2P Port (default: %s): " "$1" ;;
            "enter_exec_auth_port") printf "Enter Execution Client Auth RPC Port (default: %s): " "$1" ;;
            "enter_consensus_rpc_port") printf "Enter Consensus Client RPC Port (default: %s): " "$1" ;;
            "enter_consensus_p2p_port") printf "Enter Consensus Client P2P Port (default: %s): " "$1" ;;
            "invalid_port_input") echo "❌ Invalid input. Port must be a number between 1024 and 65535." ;;
            "ports_configured_message") printf "✅ Ports configured. Execution: RPC=%s, P2P=%s, Auth=%s. Consensus: RPC=%s, P2P=%s.\n" "$1" "$2" "$3" "$4" "$5" ;;
            "saving_port_config") echo "💾 Saving port configuration..." ;;
            "port_config_saved") printf "✅ Port configuration saved to %s.\n" "$1" ;;
            "loading_port_config") echo "🔄 Attempting to load port configuration..." ;;
            "loaded_port_config_from_file") printf "✅ Port configuration loaded from %s.\n" "$1" ;;
            "port_config_not_found") printf "ℹ️ No custom port configuration found (%s). Using default/session values.\n" "$1" ;;
            "reth_no_stages") echo "Reth: No detailed stage information available or already synced." ;;
            "reth_stage_progress") printf "  Stage '%s': %s / %s (%s%% complete)" "$1" "$2" "$3" "$4" ;;
            "reth_headers_target") printf "  Overall Chain Head Target (Headers): Block %s" "$1" ;;
            "reth_synced_fully") echo "Reth: Fully Synced (eth_syncing returned false)." ;;
            "reth_sync_details_title") echo "Reth Sync Stages Details:" ;;
            "nethermind_sync_stage_title") echo "Nethermind Sync Stage:" ;;
            "nethermind_current_stage") printf "  Current Stage: %s" "$1" ;;
            "nethermind_block_progress_title") echo "Nethermind Block Sync Progress:" ;;
            "nethermind_health_status_title") echo "Nethermind Health Status:" ;;
            "nethermind_health_info") echo "  Overall Status: %s\n  Node Health Details: %s" ;;
            "nethermind_health_request_failed") echo "  Failed to retrieve health status." ;;
            "nethermind_synced_fully") echo "Nethermind: Fully Synced (eth_syncing returned false)." ;;
            "nethermind_sync_data_missing") echo "Nethermind: Sync data missing from eth_syncing (after confirming not fully synced)." ;;
            "nethermind_rpc_error") printf "Nethermind: Error calling RPC method %s." "$1" ;;
            "chatid_linked") echo "✅ ChatID successfully linked to Sepolia node" ;;
            "invalid_token") echo "Invalid Telegram bot token. Please try again." ;;
            "token_format") echo "Token should be in format: 1234567890:ABCdefGHIJKlmNoPQRsTUVwxyZ" ;;
            "invalid_chatid") echo "Invalid Telegram chat ID or the bot doesn't have access to this chat. Please try again." ;;
            "chatid_number") echo "Chat ID must be a number (can start with - for group chats). Please try again." ;;
            "teku_beacon_active") echo "Teku Beacon node is active." ;;
            "prysm_beacon_active") echo "Prysm Beacon node is active." ;;
            "lighthouse_beacon_active") echo "Lighthouse Beacon node is active." ;;
            "sync_check_basic") echo "Basic sync check." ;;
            "sync_progress_not_valid") echo "(Failed to retrieve data for progress calculation)" ;;
            "sync_progress_process") echo "Sync Progress:" ;;
            "updating_ports") echo "🔄 Updating ports..." ;;
            "ports_updated") echo "✅ Ports have been updated." ;;
            "restart_required") echo "♻️ To apply changes, restart the node containers, remove the old cron agent, and create a new one." ;;
            "current_script_version") echo "📌 Current script version:" ;;
            "new_version_avialable") echo "🚀 New version available:" ;;
            "new_version_update") echo "Please update your Sepolia script" ;;
            "version_up_to_date") echo "✅ You are using the latest version" ;;
            *) echo "$key" ;;
        esac
    else
        case "$key" in
            "welcome") echo "          Добро пожаловать в скрипт установки и управления нодой Sepolia Ethereum" ;;
            "jwt_gen") echo "🔐 Генерация jwt.hex..." ;;
            "choose_client") echo "🔧 Выберите consensus клиент:" ;;
            "client_selected") echo "✅ Выбран клиент: $1" ;;
            "invalid_choice") echo "❌ Неверный выбор. Попробуйте снова." ;;
            "creating_compose") echo "🛠️ Создание docker-compose.yml для клиента $1..." ;;
            "unknown_client") echo "❌ Неизвестный клиент: $1" ;;
            "node_install") echo "🚀 Установка Sepolia-ноды..." ;;
            "node_installed") echo "✅ Нода установлена и запущена." ;;
            "node_update") echo "🔄 Обновление контейнеров..." ;;
            "node_updated") echo "✅ Обновление завершено." ;;
            "select_logs") echo "📋 Выберите логи:" ;;
            "back") echo "Назад" ;;
            "check_sync") echo "📡 Проверка синхронизации..." ;;
            "execution") echo "🧠 Execution ($1):" ;;
            "execution_synced") echo "   ✅ $1 синхронизирован" ;;
            "execution_syncing") echo "⏳ $1 синхронизируется..." ;;
            "prysm_synced") echo "   ✅ Prysm синхронизирован" ;;
            "prysm_syncing") echo "⏳ Prysm синхронизируется..." ;;
            "teku_synced") echo "   ✅ Teku синхронизирован" ;;
            "teku_syncing") echo "⏳ Teku синхронизируется..." ;;
            "lighthouse_synced") echo "   ✅ Lighthouse синхронизирован" ;;
            "lighthouse_syncing") echo "⏳ Lighthouse синхронизируется..." ;;
            "syncing") echo "⏳ $1 синхронизируется..." ;;
            "current_block") echo "   Текущий блок:     $1" ;;
            "target_block") echo "   Целевой блок:     $1" ;;
            "blocks_left") echo "   Осталось блоков:  $1" ;;
            "progress") echo "   Прогресс:         $1%" ;;
            "sync_speed") echo "📏 Оцениваем скорость синхронизации..." ;;
            "speed") echo "   Скорость:         $1 блоков/сек" ;;
            "eta") echo "   Оценка времени:   $1" ;;
            "low_speed") echo "   ⏱️ Скорость слишком мала для оценки времени" ;;
            "consensus") echo "🌐 Consensus ($1):" ;;
            "no_sync_data") echo "⚠️ Нет данных /eth/v1/node/syncing, пробуем финализацию..." ;;
            "beacon_active") echo "✅ Beacon chain активен (данные финализации получены)" ;;
            "no_finality") echo "❌ Не удалось получить данные финализации" ;;
            "health") echo "❤️ Beacon node health:" ;;
            "enter_tg_token") echo "Введите Telegram токен: " ;;
            "enter_tg_chat") echo "Введите Telegram chat_id: " ;;
            "select_cron") echo "Выберите интервал запуска cron-агента:" ;;
            "cron_options") echo $'1) Каждые 5 минут\n2) Каждые 10 минут\n3) Каждые 15 минут\n4) Каждые 30 минут\n5) Каждый час' ;;
            "invalid_interval") echo "Некорректный выбор. Устанавливаю интервал по умолчанию: каждые 10 минут." ;;
            "cron_installed") echo "✅ Cron-агент установлен и будет запускаться с интервалом: $1" ;;
            "cron_removed") echo "🗑️ Агент и задача cron удалены." ;;
            "stop_containers") echo "🛑 Остановка контейнеров... " ;;
            "containers_stopped") echo "✅ Контейнеры остановлены." ;;
            "no_compose") echo "⚠️ Файл docker-compose.yml не найден." ;;
            "disk_usage") echo "💽 Используемое дисковое пространство:" ;;
            "geth_usage") echo "🔧 Geth:" ;;
            "client_usage") echo "🔧 Consensus клиент ($1):" ;;
            "container_not_running") echo "Контейнер $1 не запущен или неизвестный путь данных" ;;
            "client_not_found") echo "Файл клиента не найден: $1" ;;
            "confirm_delete") echo "⚠️ Это действие удалит все данные ноды. Продолжить? (y/n)" ;;
            "deleted") echo "🗑️ Нода полностью удалена." ;;
            "cancelled") echo "❌ Удаление отменено." ;;
            "menu_title") echo "====== Sepolia Node Manager ======" ;;
            "menu_options") echo -e '1) Установить требования (Docker и другое ПО)\n2) Установить ноду\n3) Обновить ноду\n4) Проверить логи\n5) Проверить статус синхронизации\n6) Установить cron-агент с Тг уведомлениями\n7) Удалить cron-агент\n8) Остановить контейнеры\n9) Запустить контейнеры\n\033[31m10) Удалить ноду\033[0m\n11) Изменить порты для установленной ноды\n12) Проверить занимаемое место\n13) Управление файрволлом\n14) Проверить RPC-сервер\n\033[31m0) Выйти\033[0m' ;;
            "goodbye") echo "👋 До свидания!" ;;
            "invalid_option") echo "❌ Неверный выбор, попробуйте снова." ;;
            "select_option") echo "Выберите опцию: " ;;
            "start_containers") echo "🏃‍➡️ Запустить контейнеры" ;;
            "containers_started") echo "✅ Контейнеры запущены." ;;
            "client_label_prysm") echo "Prysm (рекомендуется)" ;;
            "client_label_teku") echo "Teku" ;;
            "client_label_lighthouse") echo "Lighthouse" ;;
            "update_base") echo "🛠 Обновление системы и установка базовых пакетов..." ;;
            "install_docker") echo "📦 Устанавливаем Docker..." ;;
            "docker_exists") echo "✅ Docker уже установлен. Пропускаем" ;;
            "install_compose") echo "📦 Устанавливаем Docker Compose..." ;;
            "compose_exists") echo "✅ Docker Compose уже установлен. Пропускаем" ;;
            "requirements_done") echo "✅ Все необходимые требования установлены" ;;
            "autoremove_clean") echo "Очистка системы от ненужных файлов..." ;;
            "firewall_menu") echo "🛡️ Управление файрволлом:" ;;
            "firewall_enable") echo "Включить файрволл" ;;
            "firewall_local_ports") echo "Разрешить порты для локального использования" ;;
            "firewall_remote_ip") echo "Разрешить/запретить порты для другого IP-адреса" ;;
            "enabling_firewall") echo "Включение файрволла..." ;;
            "setting_local_ports") echo "Настройка портов для локального использования..." ;;
            "enter_ip") echo "Введите IP-адрес сервера: " ;;
            "setting_remote_ports") echo "Настройка портов для IP-адреса" ;;
            "return_main_menu") echo "Возврат в главное меню." ;;
            "firewall_enabled_success") echo "✅ Файрволл успешно включён." ;;
            "local_ports_success") echo "✅ Порты для локального использования успешно настроены." ;;
            "remote_ports_success") echo "✅ Порты для указанного IP успешно настроены." ;;
            "confirm_enable_firewall") echo "Вы действительно хотите включить файрволл?" ;;
            "firewall_enable_cancelled") echo "❌ Включение файрволла отменено." ;;
            "firewall_already_enabled") echo "🔒 Файрволл уже включён." ;;
            "choose_execution_client_prompt") echo "Выберите execution клиент:" ;;
            "execution_client_selected") echo "✅ Выбран execution клиент: $1" ;;
            "client_label_geth") echo "Geth (Рекомендуется)" ;;
            "client_label_reth") echo "Reth" ;;
            "client_label_nethermind") echo "Nethermind" ;;
            "unknown_execution_client") echo "❌ Неизвестный execution клиент: $1." ;;
            "execution_client_usage") echo "🔧 Execution клиент ($1):" ;;
            "jwt_not_found_error") echo "❌ Критическая ошибка: JWT файл не найден по пути $1 перед запуском контейнеров. Остановка." ;;
            "sync_data_invalid") echo "❌ Данные синхронизации недействительны. Если клиент был запущен недавно, то попробуйте еще раз позже." ;;
            "teku_no_sync_data") echo "Нет данных о синхронизации Teku. Повторите проверку позднее." ;;
            "lighthouse_no_sync_data") echo "Нет данных о синхронизации Lighthouse. Повторите проверку позднее." ;;
            "prysm_no_sync_data") echo "Нет данных о синхронизации Prysm. Повторите проверку позднее." ;;
            "teku_no_finality") echo "Teku - нет финалити." ;;
            "lighthouse_no_finality") echo "Lighthouse - нет финалити." ;;
            "prysm_no_finality") echo "Prysm - нет финалити." ;;
            "teku_health") echo "Teku здоровье." ;;
            "firewall_delete_rules") printf "Удалить правила для портов (ExecRPC: %s, ConsRPC: %s, ExecP2P: %s, ConsP2P: %s)" "$1" "$2" "$3" "$4" ;;
            "firewall_view_rules") echo "Просмотреть правила UFW" ;;
            "firewall_disable") echo "Отключить файрволл" ;;
            "deleting_old_rules") echo "Удаление старых правил..." ;;
            "no_matching_rules") printf "Правила для текущих портов (%s, %s, %s, %s) не найдены." "$1" "$2" "$3" "$4" ;;
            "deleting_rule_number") echo "Удаление правила №" ;;
            "rules_deleted_success") echo "✅ Правила успешно удалены." ;;
            "view_ufw_rules") echo "Правила UFW" ;;
            "press_enter_to_continue") echo "Нажмите Enter для возврата назад..." ;;
            "disabling_firewall") echo "Отключение файрволла..." ;;
            "confirm_disable_firewall") echo "Вы действительно хотите отключить файрволл?" ;;
            "firewall_disabled_success") echo "✅ Файрволл успешно отключён." ;;
            "firewall_disable_cancelled") echo "❌ Отключение файрволла отменено." ;;
            "confirm_delete_firewall_rules") printf "Вы действительно хотите удалить правила файрволла для портов %s, %s, %s, %s?" "$1" "$2" "$3" "$4" ;;
            "firewall_delete_cancelled") echo "❌ Удаление правил файрволла отменено." ;;
            "rules_to_be_deleted") echo "Будут удалены следующие правила файрволла:" ;;
            "ask_custom_ports_prompt") echo "Хотите настроить пользовательские порты? (yes/no, по умолчанию: no)" ;;
            "enter_exec_rpc_port") printf "Введите RPC-порт клиента исполнения (по умолчанию: %s): " "$1" ;;
            "enter_exec_p2p_port") printf "Введите P2P-порт клиента исполнения (по умолчанию: %s): " "$1" ;;
            "enter_exec_auth_port") printf "Введите Auth RPC-порт клиента исполнения (по умолчанию: %s): " "$1" ;;
            "enter_consensus_rpc_port") printf "Введите RPC-порт клиента консенсуса (по умолчанию: %s): " "$1" ;;
            "enter_consensus_p2p_port") printf "Введите P2P-порт клиента консенсуса (по умолчанию: %s): " "$1" ;;
            "invalid_port_input") echo "❌ Неверный ввод. Порт должен быть числом от 1024 до 65535." ;;
            "ports_configured_message") printf "✅ Порты настроены. Исполнение: RPC=%s, P2P=%s, Auth=%s. Консенсус: RPC=%s, P2P=%s.\n" "$1" "$2" "$3" "$4" "$5" ;;
            "saving_port_config") echo "💾 Сохранение конфигурации портов..." ;;
            "port_config_saved") printf "✅ Конфигурация портов сохранена в %s.\n" "$1" ;;
            "loading_port_config") echo "🔄 Попытка загрузки конфигурации портов..." ;;
            "loaded_port_config_from_file") printf "✅ Конфигурация портов загружена из %s.\n" "$1" ;;
            "port_config_not_found") printf "ℹ️ Пользовательская конфигурация портов не найдена (%s). Используются значения по умолчанию/сессии.\n" "$1" ;;
            "reth_no_stages") echo "Reth: Подробная информация об этапах отсутствует или уже синхронизировано." ;;
            "reth_stage_progress") printf "  Этап '%s': %s / %s (%s%% завершено)" "$1" "$2" "$3" "$4" ;;
            "reth_headers_target") printf "  Общая целевая высота цепочки (Headers): Блок %s" "$1" ;;
            "reth_synced_fully") echo "Reth: Полностью синхронизирован (eth_syncing вернул false)." ;;
            "reth_sync_details_title") echo "Reth Подробности этапов синхронизации:" ;;
            "nethermind_sync_stage_title") echo "Этап синхронизации Nethermind:" ;;
            "nethermind_current_stage") printf "  Текущий этап: %s" "$1" ;;
            "nethermind_block_progress_title") echo "Прогресс синхронизации блоков Nethermind:" ;;
            "nethermind_health_status_title") echo "Статус работоспособности Nethermind:" ;;
            "nethermind_health_info") echo "  Общий статус: %s\n  Подробности о работоспособности ноды: %s" ;;
            "nethermind_health_request_failed") echo "  Не удалось получить статус работоспособности." ;;
            "nethermind_synced_fully") echo "Nethermind: Полностью синхронизирован (eth_syncing вернул false)." ;;
            "nethermind_sync_data_missing") echo "Nethermind: Данные синхронизации отсутствуют в eth_syncing (после подтверждения неполной синхронизации)." ;;
            "nethermind_rpc_error") printf "Nethermind: Ошибка при вызове RPC метода %s." "$1" ;;
            "chatid_linked") echo "✅ ChatID успешно связан с Sepolia node" ;;
            "invalid_token") echo "Неверный токен Telegram бота. Пожалуйста, попробуйте снова." ;;
            "token_format") echo "Токен должен быть в формате: 1234567890:ABCdefGHIJKlmNoPQRsTUVwxyZ" ;;
            "invalid_chatid") echo "Неверный Chat ID или бот не имеет доступа к этому чату. Пожалуйста, попробуйте снова." ;;
            "chatid_number") echo "Chat ID должен быть числом (может начинаться с - для групповых чатов). Пожалуйста, попробуйте снова." ;;
            "teku_beacon_active") echo "Beacon-нода Teku активна." ;;
            "prysm_beacon_active") echo "Beacon-нода Prysm активна." ;;
            "lighthouse_beacon_active") echo "Beacon-нода Lighthouse активна." ;;
            "sync_check_basic") echo "Базовая проверка синхронизации." ;;
            "sync_progress_not_valid") echo "(Не удалось получить данные для расчёта прогресса)" ;;
            "sync_progress_process") echo "Прогресс синхронизации:" ;;
            "updating_ports") echo "🔄 Обновляем порты..." ;;
            "ports_updated") echo "✅ Порты обновлены." ;;
            "restart_required") echo "♻️ Для применения изменений перезапустите контейнеры ноды, удалите старого cron-агента и создайте нового." ;;
            "current_script_version") echo "📌 Текущая версия скрипта:" ;;
            "new_version_avialable") echo "🚀 Доступна новая версия:" ;;
            "new_version_update") echo "Пожалуйста, обновите Sepolia скрипт" ;;
            "version_up_to_date") echo "✅ Установлена актуальная версия" ;;
            *) echo "$key" ;;
        esac
    fi
}

function check_version() {
# === Проверяем и добавляем ключ VERSION в ~/.env-sepolia-version ===
  # Если ключа VERSION в .env-sepolia-version нет – дописать его, не затронув остальные переменные
  INSTALLED_VERSION=$(grep '^VERSION=' ~/.env-sepolia-version | cut -d'=' -f2)

  if [ -z "$INSTALLED_VERSION" ]; then
    echo "VERSION=$SCRIPT_VERSION" >> ~/.env-sepolia-version
    INSTALLED_VERSION="$SCRIPT_VERSION"
  elif [ "$INSTALLED_VERSION" != "$SCRIPT_VERSION" ]; then
  # Обновляем строку VERSION в .env-sepolia-version
    sed -i "s/^VERSION=.*/VERSION=$SCRIPT_VERSION/" ~/.env-sepolia-version
    INSTALLED_VERSION="$SCRIPT_VERSION"
  fi

  # === Скачиваем remote version_control.json и определяем последнюю версию ===
  REMOTE_VC_URL="https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/other/version_control.json"
  # Скачиваем весь JSON, отбираем массив .[].VERSION, сортируем, берём последний
  if remote_data=$(curl -fsSL "$REMOTE_VC_URL"); then
    REMOTE_LATEST_VERSION=$(echo "$remote_data" | jq -r '.[].VERSION' | sort -V | tail -n1)
  else
    REMOTE_LATEST_VERSION=""
  fi

  # === Выводим текущую версию и, если надо, предупреждение об обновлении ===
  echo -e "\n${CYAN}$(t "current_script_version") ${INSTALLED_VERSION}${NC}"
  if [ -n "$REMOTE_LATEST_VERSION" ] && [ "$REMOTE_LATEST_VERSION" != "$INSTALLED_VERSION" ]; then
    echo -e "${YELLOW}$(t "new_version_avialable") ${REMOTE_LATEST_VERSION}. $(t "new_version_update").${NC}"
  elif [ -n "$REMOTE_LATEST_VERSION" ]; then
    echo -e "${GREEN}$(t "version_up_to_date")${NC}"
  fi

}

# Rest of the script remains the same, just replace all echo messages with t function calls
# For example:
# print_info "🔐 Генерация jwt.hex..." becomes print_info "$(t "jwt_gen")"
# print_success "✅ Выбран клиент: $client" becomes print_success "$(t "client_selected" "$client")"

NODE_DIR="/root/sepolia-node"
DOCKER_COMPOSE_FILE="$NODE_DIR/docker-compose.yml" # This one remains unchanged as per instructions
JWT_FILE="$NODE_DIR/jwt.hex"
CLIENT_FILE="$NODE_DIR/client"
EXECUTION_CLIENT_FILE="$NODE_DIR/execution_client"
AGENT_SCRIPT="$NODE_DIR/cron_agent.sh"

function print_info {
  echo -e "${CYAN}$1${RESET}"
}

function print_success {
  echo -e "${GREEN}$1${RESET}"
}

function print_warning {
  echo -e "${YELLOW}$1${RESET}"
}

function print_error {
  echo -e "${RED}$1${RESET}"
}

function generate_jwt {
  print_info "$(t "jwt_gen")"
  mkdir -p "$NODE_DIR"
  head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$JWT_FILE"
}

function ask_for_custom_ports {
  load_port_configuration # Load existing config first
  print_info "$(t "ask_custom_ports_prompt")"
  read -r custom_ports_choice
  if [[ "${custom_ports_choice,,}" == "yes" || "${custom_ports_choice,,}" == "y" || "${custom_ports_choice,,}" == "да" || "${custom_ports_choice,,}" == "д" ]]; then
    # Helper function for validated port input
    get_validated_port() {
    local prompt_key="$1"
    local default_value="$2"
    local current_value=""

    while true; do
        local prompt=$(t "$prompt_key" "$default_value")
        # Удаляем возможные символы перевода строки
        prompt=${prompt//$'\n'/}
        prompt=${prompt//$'\r'/}

        read -r -p "$prompt" user_input

        if [[ -z "$user_input" ]]; then
            current_value="$default_value"
            break
        elif [[ "$user_input" =~ ^[0-9]+$ && "$user_input" -ge 1024 && "$user_input" -le 65535 ]]; then
            current_value="$user_input"
            break
        else
            print_error "$(t "invalid_port_input")"
        fi
    done

    echo "$current_value"
}

    EXECUTION_RPC_PORT=$(get_validated_port "enter_exec_rpc_port" "$EXECUTION_RPC_PORT_DEFAULT")
    EXECUTION_P2P_PORT=$(get_validated_port "enter_exec_p2p_port" "$EXECUTION_P2P_PORT_DEFAULT")
    EXECUTION_AUTH_RPC_PORT=$(get_validated_port "enter_exec_auth_port" "$EXECUTION_AUTH_RPC_PORT_DEFAULT")
    CONSENSUS_RPC_PORT=$(get_validated_port "enter_consensus_rpc_port" "$CONSENSUS_RPC_PORT_DEFAULT")
    CONSENSUS_P2P_PORT=$(get_validated_port "enter_consensus_p2p_port" "$CONSENSUS_P2P_PORT_DEFAULT")
  fi

  mkdir -p "$NODE_DIR"
  local port_config_file="$NODE_DIR/port_config.env"
  print_info "$(t "saving_port_config")"
  {
    echo "EXECUTION_RPC_PORT=\"$EXECUTION_RPC_PORT\""
    echo "EXECUTION_P2P_PORT=\"$EXECUTION_P2P_PORT\""
    echo "EXECUTION_AUTH_RPC_PORT=\"$EXECUTION_AUTH_RPC_PORT\""
    echo "CONSENSUS_RPC_PORT=\"$CONSENSUS_RPC_PORT\""
    echo "CONSENSUS_P2P_PORT=\"$CONSENSUS_P2P_PORT\""
  } > "$port_config_file"
  print_success "$(t "port_config_saved" "$port_config_file")"

  print_success "$(t "ports_configured_message" "$EXECUTION_RPC_PORT" "$EXECUTION_P2P_PORT" "$EXECUTION_AUTH_RPC_PORT" "$CONSENSUS_RPC_PORT" "$CONSENSUS_P2P_PORT")"
}


function load_port_configuration {
  local port_config_file="$NODE_DIR/port_config.env"
  print_info "\n$(t "loading_port_config")"
  if [[ -f "$port_config_file" ]]; then
    # Temporarily disable errexit if set, to prevent script exit if source fails (e.g. bad file)
    local prev_opts=""
    if [[ $- == *e* ]]; then
      prev_opts=$(set +o | grep errexit)
      set +e
    fi

    source "$port_config_file"

    # Restore errexit if it was previously set
    if [[ -n "$prev_opts" ]]; then
      set -o errexit
    fi
    print_success "$(t "loaded_port_config_from_file" "$port_config_file")"
  else
    print_info "$(t "port_config_not_found" "$port_config_file")"
  fi
}

function choose_consensus_client {
  mkdir -p "$NODE_DIR"

  local options=("prysm" "teku" "lighthouse")
  local labels=(
    "$(t "client_label_prysm")"
    "$(t "client_label_teku")"
    "$(t "client_label_lighthouse")"
  )

  PS3="$(t "choose_client")"$'\n> '
  select opt_label in "${labels[@]}"; do
    case $REPLY in
      1|2|3)
        local selected="${options[$((REPLY-1))]}"
        echo "$selected" > "$CLIENT_FILE"
        print_success "$(t "client_selected" "$selected")"
        return
        ;;
      *) print_error "$(t "invalid_choice")" ;;
    esac
  done
}

function choose_execution_client {
  mkdir -p "$NODE_DIR"

  local options=("geth" "reth" "nethermind")
  local labels=(
    "$(t "client_label_geth")"
    "$(t "client_label_reth")"
    "$(t "client_label_nethermind")"
  )

  PS3="$(t "choose_execution_client_prompt")"$'\n> '
  select opt_label in "${labels[@]}"; do
    case $REPLY in
      1|2|3)
        local selected="${options[$((REPLY-1))]}"
        echo "$selected" > "$EXECUTION_CLIENT_FILE"
        print_success "$(t "execution_client_selected" "$selected")"
        return
        ;;
      *) print_error "$(t "invalid_choice")" ;;
    esac
  done
}

function install_requirements {
  cd $HOME

  print_info "$(t "update_base")"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install screen curl git jq nano gnupg build-essential ca-certificates wget lz4 gcc make lsb-release software-properties-common apt-transport-https iptables automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

  if ! command -v docker &> /dev/null; then
    print_info "$(t "install_docker")"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
  else
    print_info "$(t "docker_exists")"
  fi

  if ! command -v docker-compose &> /dev/null; then
    print_info "$(t "install_compose")"
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  else
    print_info "$(t "compose_exists")"
  fi

  print_info "$(t "autoremove_clean")"
  sudo apt autoremove -y && sudo apt clean

  echo ""
  print_success "$(t "requirements_done")"
}

function create_docker_compose {
  local consensus_client=$(cat "$CLIENT_FILE" 2>/dev/null || echo "")
  if [[ -z "$consensus_client" ]]; then
    print_error "$(t "unknown_client" "$consensus_client")" # This uses the consensus client variable name for now
    exit 1
  fi

  local execution_client=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
  local execution_client_image=""
  local execution_client_container_name=""
  local execution_client_volumes=""
  local execution_client_ports="[\"8545:8545\", \"30303:30303\", \"8551:8551\"]" # Common ports
  local execution_client_command=""
  local execution_client_data_dir_name="" # This will store just the client name like "geth", "reth"
  # local execution_client_data_path_base="$NODE_DIR/execution" # Base path for execution data - REMOVED

  # mkdir -p "$NODE_DIR/config" "$execution_client_data_path_base" "$NODE_DIR/consensus" # REMOVED - Assuming $NODE_DIR is created by install_node
  # Individual client data dirs (e.g. $NODE_DIR/geth) will be implicitly created by Docker if not existing, or can be added here if strict creation is needed before compose.
  # For this reversion, we'll rely on docker-compose to create them or ensure `install_node` handles $NODE_DIR.

  case $execution_client in
    geth)
      execution_client_image="ethereum/client-go:stable"
      execution_client_container_name="geth"
      execution_client_data_dir_name="geth" # Keep this as the client name itself
      execution_client_command="      --sepolia
      --datadir=/data
      --http
      --http.addr=0.0.0.0
      --http.api=eth,web3,net,engine
      --http.port=$EXECUTION_RPC_PORT
      --port=$EXECUTION_P2P_PORT
      --authrpc.addr=0.0.0.0
      --authrpc.port=$EXECUTION_AUTH_RPC_PORT
      --authrpc.jwtsecret=/jwt.hex
      --authrpc.vhosts=*
      --http.corsdomain=\"*\"
      --syncmode=snap
      --cache=4096"
      ;;
    reth)
      execution_client_image="ghcr.io/paradigmxyz/reth:latest"
      execution_client_container_name="reth"
      execution_client_data_dir_name="reth" # Keep this as the client name itself
      execution_client_command="      node
      --chain=sepolia
      --datadir=/data
      --http
      --http.port=$EXECUTION_RPC_PORT
      --http.api=eth,net,web3,rpc,debug
      --http.addr=0.0.0.0
      --authrpc.addr=0.0.0.0
      --authrpc.port=$EXECUTION_AUTH_RPC_PORT
      --authrpc.jwtsecret=/jwt.hex
      --metrics=0.0.0.0:9090"
      ;;
    nethermind)
      execution_client_image="nethermind/nethermind:latest"
      execution_client_container_name="nethermind"
      execution_client_data_dir_name="nethermind" # Keep this as the client name itself
      execution_client_command="      --config=sepolia
      --datadir=/data
      --JsonRpc.Enabled=true
      --JsonRpc.Host=0.0.0.0
      --JsonRpc.Port=$EXECUTION_RPC_PORT
      --Network.DiscoveryPort=$EXECUTION_P2P_PORT
      --Network.P2PPort=$EXECUTION_P2P_PORT
      --JsonRpc.EnabledModules=[debug,eth,web3,net]
      --JsonRpc.EngineHost=0.0.0.0
      --JsonRpc.EnginePort=$EXECUTION_AUTH_RPC_PORT
      --JsonRpc.EngineEnabledModules=[Engine,Eth,Subscribe,Web3]
      --JsonRpc.JwtSecretFile=/jwt.hex
      --Metrics.Enabled=true
      --Metrics.ExposePort=9090
      --HealthChecks.Enabled=true"
      ;;
    *)
      print_warning "$(t "unknown_execution_client" "$execution_client")"
      # Default to Geth
      execution_client="geth"
      execution_client_image="ethereum/client-go:stable"
      execution_client_container_name="geth"
      execution_client_data_dir_name="geth"
      execution_client_command="      --sepolia
      --datadir=/data
      --http
      --http.addr=0.0.0.0
      --http.api=eth,web3,net,engine
      --http.port=$EXECUTION_RPC_PORT
      --port=$EXECUTION_P2P_PORT
      --authrpc.addr=0.0.0.0
      --authrpc.port=$EXECUTION_AUTH_RPC_PORT
      --authrpc.jwtsecret=/jwt.hex
      --authrpc.vhosts=*
      --http.corsdomain=\"*\"
      --syncmode=snap
      --cache=4096"
      ;;
  esac

  # mkdir -p "$execution_client_data_path_base/$execution_client_data_dir_name" # REMOVED

  # Reverted to simple, non-conditional volume definition
  # execution_client_volumes="- $NODE_DIR/$execution_client_data_dir_name:/data\n      - $JWT_FILE:/jwt.hex" # REMOVED

  print_info "$(t "creating_compose" "$consensus_client / $execution_client")"
  cat > "$DOCKER_COMPOSE_FILE" <<EOF
services:
  $execution_client_container_name:
    image: $execution_client_image
    container_name: $execution_client_container_name
    restart: unless-stopped
    volumes:
      - $NODE_DIR/$execution_client_data_dir_name:/data
      - $JWT_FILE:/jwt.hex
    ports:
      - "$EXECUTION_RPC_PORT:$EXECUTION_RPC_PORT"
      - "$EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/tcp"
      - "$EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/udp"
      - "$EXECUTION_AUTH_RPC_PORT:$EXECUTION_AUTH_RPC_PORT"
    command:
${execution_client_command}
EOF

  local consensus_execution_endpoint="http://$execution_client_container_name:$EXECUTION_AUTH_RPC_PORT"

  case $consensus_client in
    lighthouse)
      # mkdir -p "$NODE_DIR/consensus/lighthouse" # REMOVED
      cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  lighthouse:
    image: sigp/lighthouse:latest
    container_name: lighthouse
    restart: unless-stopped
    volumes:
      - $NODE_DIR/lighthouse:/root/.lighthouse
      - $JWT_FILE:/root/jwt.hex
    depends_on:
      - $execution_client_container_name
    ports:
      - "$CONSENSUS_RPC_PORT:$CONSENSUS_RPC_PORT"
      - "$CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/tcp"
      - "$CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/udp"
    command:
      lighthouse bn
      --network sepolia
      --execution-endpoint=$consensus_execution_endpoint
      --execution-jwt=/root/jwt.hex
      --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      --http
      --http-address=0.0.0.0
      --listen-address=0.0.0.0
      --http-port=$CONSENSUS_RPC_PORT
      --enr-address=$(curl -s https://ip4only.me/api/ | cut -d',' -f2)
      --enr-tcp-port=$CONSENSUS_P2P_PORT
      --enr-udp-port=$CONSENSUS_P2P_PORT
      --discovery-port=$CONSENSUS_P2P_PORT
      --port=$CONSENSUS_P2P_PORT
EOF
      ;;
    prysm)
      # mkdir -p "$NODE_DIR/consensus/prysm" # REMOVED
      cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  prysm:
    image: gcr.io/prysmaticlabs/prysm/beacon-chain:stable
    container_name: prysm
    restart: unless-stopped
    volumes:
      - $NODE_DIR/prysm:/data
      - $JWT_FILE:/jwt.hex
    depends_on:
      - $execution_client_container_name
    ports:
      - "$CONSENSUS_RPC_PORT:$CONSENSUS_RPC_PORT"
      - "$CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/tcp"
      - "$CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/udp"
    command:
      --sepolia
      --datadir=/data
      --execution-endpoint=$consensus_execution_endpoint
      --jwt-secret=/jwt.hex
      --accept-terms-of-use
      --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      --grpc-gateway-port=$CONSENSUS_RPC_PORT
      --grpc-gateway-host=0.0.0.0
EOF
      ;;
    teku)
      mkdir -p "$NODE_DIR/teku/logs"
      mkdir -p "$NODE_DIR/teku/validator/slashprotection"
      mkdir -p "$NODE_DIR/teku/beacon"
      chmod -R 777 "$NODE_DIR/teku/beacon"
      chmod -R 777 "$NODE_DIR/teku/validator"
      chmod -R 777 "$NODE_DIR/teku/logs"
      cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  teku:
    image: consensys/teku:latest
    container_name: teku
    restart: unless-stopped
    volumes:
      - $NODE_DIR/teku:/data
      - $JWT_FILE:/jwt.hex
    depends_on:
      - $execution_client_container_name
    ports:
      - "$CONSENSUS_RPC_PORT:$CONSENSUS_RPC_PORT"
      - "$CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/tcp"   # P2P TCP
      - "$CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/udp"   # P2P UDP
    command:
      --network=sepolia
      --data-path=/data
      --ee-endpoint=$consensus_execution_endpoint
      --ee-jwt-secret-file=/jwt.hex
      --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      --rest-api-enabled=true
      --rest-api-interface=0.0.0.0
      --rest-api-port=$CONSENSUS_RPC_PORT
      --rest-api-host-allowlist=*
      --p2p-port=$CONSENSUS_P2P_PORT
      --p2p-advertised-ip=$(curl -s https://ip4only.me/api/ | cut -d',' -f2)
      --metrics-enabled=true
      --metrics-port=8008
      --metrics-host-allowlist=*
EOF
      ;;
    *)
      # This was already handled for consensus_client at the beginning of the function
      print_error "$(t "unknown_client" "$consensus_client")"
      exit 1
      ;;
  esac
}

function install_node {
  print_info "$(t "node_install")"
  mkdir -p "$NODE_DIR"
  ask_for_custom_ports # Call the new function here
  choose_execution_client
  choose_consensus_client
  generate_jwt
  create_docker_compose
  if [[ ! -f "$JWT_FILE" ]]; then
    print_error "$(t "jwt_not_found_error" "$JWT_FILE")"
    exit 1
  fi
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d
  print_success "$(t "node_installed")"
  echo -e "${BLUE}RPC:${RESET}      http://localhost:$EXECUTION_RPC_PORT"
  echo -e "${BLUE}BEACON:${RESET}   http://localhost:$CONSENSUS_RPC_PORT"
}

function update_node {
  print_info "$(t "node_update")"
  docker compose -f "$DOCKER_COMPOSE_FILE" pull
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d
  print_success "$(t "node_updated")"
}

function view_logs {
  local execution_client_name=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
  local consensus_client_name=$(cat "$CLIENT_FILE" 2>/dev/null || echo "lighthouse")

  # Capitalize first letter for display
  local display_execution_client_name="${execution_client_name^}"
  local display_consensus_client_name="${consensus_client_name^}"

  print_info "$(t "select_logs")"
  select opt in "$display_execution_client_name" "$display_consensus_client_name" "$(t "back")"; do
    case $REPLY in
      1) docker logs --tail 500 -f "$execution_client_name"; break ;;
      2) docker logs --tail 500 -f "$consensus_client_name"; break ;;
      3) break ;;
      *) print_error "$(t "invalid_option")";;
    esac
  done
}

function hex_to_dec() {
  printf "%d\n" "$((16#${1#0x}))"
}

function format_time() {
  local seconds=$1
  local h=$((seconds / 3600))
  local m=$(((seconds % 3600) / 60))
  local s=$((seconds % 60))
  if [[ "$lang" == "en" ]]; then
    printf "%02dh %02dm %02ds" $h $m $s
  else
    printf "%02dч %02dм %02dс" $h $m $s
  fi
}

function check_sync {
  local consensus_client_name=$(cat "$CLIENT_FILE" 2>/dev/null || echo "prysm")
  local execution_client_name=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
  local display_execution_client_name="${execution_client_name^}"

  print_info "\n$(t "check_sync")"
  print_info "\n$(t "execution" "$display_execution_client_name")"

  local sync_data=$(curl -s -X POST "http://localhost:$EXECUTION_RPC_PORT" -H 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')

    #echo "DEBUG: $EXECUTION_RPC_PORT"
    #echo "DEBUG: $sync_data"

  if echo "$sync_data" | jq -e '.result == false' >/dev/null 2>&1; then
    echo "$(t "execution_synced" "$display_execution_client_name")"
  else
    if [[ "$execution_client_name" == "geth" ]]; then
      # Старая схема для Geth
      local current=$(echo "$sync_data" | jq -r '.result.currentBlock // .result.syncing.currentBlock // .result.syncingData.currentBlock // empty')
      local highest=$(echo "$sync_data" | jq -r '.result.highestBlock // .result.syncing.highestBlock // .result.syncingData.highestBlock // empty')

      if [[ -z "$current" || -z "$highest" || "$current" == "null" || "$highest" == "null" ]]; then
        echo "$(t "sync_data_missing")"
        return
      fi

      local current_dec=$((16#${current:2}))
      local highest_dec=$((16#${highest:2}))

      if [[ $highest_dec -eq 0 ]]; then
        echo "$(t "sync_data_invalid")"
      else
        local remaining=$((highest_dec - current_dec))
        local progress=$((100 * current_dec / highest_dec))
        echo "$(t "syncing" "$display_execution_client_name")"
        echo "$(t "current_block" "$current_dec")"
        echo "$(t "target_block" "$highest_dec")"
        echo "$(t "blocks_left" "$remaining")"
        echo "$(t "progress" "$progress")"

        echo "$(t "sync_speed")"
        sleep 5
        local sync_data2=$(curl -s -X POST "http://localhost:$EXECUTION_RPC_PORT" -H 'Content-Type: application/json' \
          --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
        local current2=$(echo "$sync_data2" | jq -r '.result.currentBlock // .result.syncing.currentBlock // .result.syncingData.currentBlock // empty')
        local current2_dec=$((16#${current2:2}))

        local delta_blocks=$((current2_dec - current_dec))
        local speed_bps=0
        if [[ $delta_blocks -gt 0 ]]; then
          speed_bps=$((delta_blocks / 5))
        fi

        echo "$(t "speed" "$speed_bps")"

        if [[ $speed_bps -gt 0 ]]; then
          local est_sec=$((remaining / speed_bps))
          echo "$(t "eta" "$(format_time $est_sec)")"
        else
          echo "$(t "low_speed")"
        fi
      fi

    elif [[ "$execution_client_name" == "reth" ]]; then
  # Новая схема для Reth через stages
  echo "$(t "syncing" "$display_execution_client_name")"
  echo ""
  # Проверяем, есть ли stages в ответе
  local stages_exist=$(echo "$sync_data" | jq '.result.stages? != null')
  if [[ "$stages_exist" != "true" ]]; then
    echo "$(t "reth_no_stages")"
    return
  fi

  local execution_block=0
  local bodies_block=0
  local headers_block=0
  local highest_block_hex=$(echo "$sync_data" | jq -r '.result.highestBlock')
  local highest_block_dec=0
  if [[ "$highest_block_hex" =~ ^0x[0-9a-fA-F]+$ ]]; then
    highest_block_dec=$((16#${highest_block_hex:2}))
  fi

  local stages_json=$(echo "$sync_data" | jq -c '.result.stages[]')

  # Для хранения блоков всех stages
  declare -A stage_blocks

  while IFS= read -r stage; do
    local name=$(echo "$stage" | jq -r '.name')
    local block_hex=$(echo "$stage" | jq -r '.block')
    local block_dec=0
    if [[ "$block_hex" =~ ^0x[0-9a-fA-F]+$ ]]; then
      block_dec=$((16#${block_hex:2}))
    fi

    # echo "$name: $block_hex (dec: $block_dec)"

    # Запоминаем блоки для известных stages
    if [[ "$name" == "Execution" ]]; then
      execution_block=$block_dec
    elif [[ "$name" == "Bodies" ]]; then
      bodies_block=$block_dec
    elif [[ "$name" == "Headers" ]]; then
      headers_block=$block_dec
    fi

    stage_blocks["$name"]=$block_dec

  done <<< "$stages_json"

  # ─── Все stages ─────────────────────────────────────────────────────
  for stage_name in  "Headers" "Bodies" "SenderRecovery" "Execution" "AccountHashing" "StorageHashing" "MerkleUnwind" "MerkleExecute" "TransactionLookup" "IndexAccountHistory" "IndexStorageHistory" "PruneSenderRecovery" "Prune" "Finish"; do
    local block=${stage_blocks[$stage_name]:-0}
    if [[ $headers_block -gt 0 ]]; then
        local percent=$((100 * block / headers_block))
        if [[ $percent -eq 0 ]]; then
            echo "⚠️ $stage_name $(t sync_progress_process) $block $(t sync_progress_not_valid)"
        else
            print_success "🧮 $stage_name $(t sync_progress_process) $block / $headers_block = $percent%"
        fi
    else
        echo "⚠️ $stage_name $(t sync_progress_process) $block $(t sync_progress_not_valid)"
    fi
  done

    elif [[ "$execution_client_name" == "nethermind" ]]; then
      # Initial Full Sync Check (eth_syncing)
      if echo "$sync_data" | jq -e '.result == false' >/dev/null 2>&1; then
        echo "$(t "nethermind_synced_fully")"
        # Even if fully synced, we might want to show health, so don't return immediately.
        # If a 'return' is desired here, it would skip stage and health display for fully synced nodes.
      fi

    echo ""
    echo "$(t nethermind_sync_stage_title)"

    local stage_rpc_payload='{"jsonrpc":"2.0","id":0,"method":"debug_getSyncStage","params":[]}'

    stage_data=$(curl -s -X POST "http://localhost:$EXECUTION_RPC_PORT" \
                  -H 'Content-Type: application/json' --data "$stage_rpc_payload")

    if [[ -n "$stage_data" ]] && \
       echo "$stage_data" | jq -e '.error == null and .result != null' >/dev/null; then
        stage_name_display=$(echo "$stage_data" | jq -r '.result.currentStage // "N/A"')
        printf "%s\n" "$(t nethermind_current_stage "$stage_name_display")"
    elif echo "$stage_data" | jq -e '.error != null' >/dev/null; then
        error_message=$(echo "$stage_data" | jq -r '.error.message // "Unknown RPC error"')
        printf "%s\n" "$(t nethermind_rpc_error "debug_getSyncStage") Details: $error_message"
    else
        printf "%s\n" "$(t nethermind_rpc_error "debug_getSyncStage") Details: Empty or invalid response"
    fi

      # Block Sync Progress (from eth_syncing data, only if not reported as fully synced by eth_syncing)
      if ! (echo "$sync_data" | jq -e '.result == false' >/dev/null 2>&1); then
        echo ""
        echo "$(t "nethermind_block_progress_title")"
        local current_hex=$(echo "$sync_data" | jq -r '.result.currentBlock // empty')
        local highest_hex=$(echo "$sync_data" | jq -r '.result.highestBlock // empty')

        if [[ -z "$current_hex" || "$current_hex" == "null" || -z "$highest_hex" || "$highest_hex" == "null" ]]; then
          echo "$(t "nethermind_sync_data_missing")"
        else
          local current_dec=$(hex_to_dec "$current_hex")
          local highest_dec=$(hex_to_dec "$highest_hex")

          if [[ $highest_dec -eq 0 && $current_dec -gt 0 ]]; then # If highest is 0 but current is not, it might be pre-sync or error
            echo "$(t "sync_data_invalid")"
          elif [[ $highest_dec -eq 0 && $current_dec -eq 0 && "$stage_name_display" != "Finished" && "$stage_name_display" != "SnapSync" && "$stage_name_display" != "FastSync" && "$stage_name_display" != "FullSync" && "$stage_name_display" != "N/A" ]] ; then
            # If both are 0, but stage suggests it's not done, data might be missing for block progress
            echo "$(t "nethermind_sync_data_missing")"
          elif [[ $highest_dec -ge $current_dec ]]; then # Normal progress or just finished
            local remaining=$((highest_dec - current_dec))
            local progress_pct=0
            if [[ $highest_dec -gt 0 ]]; then # Avoid division by zero if highest_dec is 0 (e.g. at very start)
                if [[ $current_dec -ge $highest_dec ]]; then # handles current == highest or current > highest
                    progress_pct=100
                else
                    progress_pct=$((current_dec * 100 / highest_dec))
                fi
            elif [[ $current_dec -gt 0 ]]; then # highest is 0, but current is not (should not happen if previous checks are good)
                 progress_pct=0 # Or some other indicator of unusual state
            fi # if highest_dec is 0 and current_dec is 0, progress_pct remains 0

            echo "$(t "current_block" "$current_dec")"
            echo "$(t "target_block" "$highest_dec")"
            echo "$(t "blocks_left" "$remaining")"
            echo "$(t "progress" "$progress_pct")"
          else # current_dec > highest_dec, should ideally be caught by eth_syncing:false
             echo "$(t "execution_synced" "$display_execution_client_name")"
          fi
        fi
      fi

    # --- Health Status Check -----------------------------------------------
        echo ""
        echo "$(t nethermind_health_status_title)"

        local health_output
        local health_status_overall="Unknown"
        local health_details_str=""

        health_output=$(curl -s -X GET "http://localhost:$EXECUTION_RPC_PORT/health" -H 'Content-Type: application/json')

        if [[ -n "$health_output" ]]; then
          if echo "$health_output" | jq -e '.status' >/dev/null 2>&1; then
            health_status_overall=$(echo "$health_output" | jq -r '.status')
          elif ! echo "$health_output" | jq -e . >/dev/null 2>&1; then
            health_status_overall="$health_output"
            health_details_str="$health_output"
          fi

          if [[ -z "$health_details_str" ]]; then
            if echo "$health_output" | jq -e . >/dev/null 2>&1; then
              health_details_str=$(echo "$health_output" | jq '.')
            else
              health_details_str="$health_output"
            fi
          fi

          printf "$(t nethermind_health_info)\n" "$health_status_overall" "$health_details_str"
        else
          printf "$(t nethermind_health_info)\n" "Unknown" "$(t nethermind_health_request_failed)"
        fi

    else
      echo "⚠️ $(t "unknown_execution_client" "$execution_client_name"). $(t "sync_check_basic")"
      echo "$sync_data" | jq '.result'
    fi
  fi

  echo ""
  echo "$(t "consensus" "$consensus_client_name")"

  case "$consensus_client_name" in
    prysm|teku)
      local syncing_resp=$(curl -s "http://localhost:$CONSENSUS_RPC_PORT/eth/v1/node/syncing")
      if [[ "$syncing_resp" == "{}" || -z "$syncing_resp" ]]; then
        echo "$(t "${consensus_client_name}_no_sync_data")"
        local fin_resp=$(curl -s "http://localhost:$CONSENSUS_RPC_PORT/eth/v1/node/finality")
        if [[ -z "$fin_resp" ]]; then
          fin_resp=$(curl -s "http://localhost:$CONSENSUS_RPC_PORT/eth/v1/beacon/states/head/finality_checkpoints")

          #echo "DEBUG: $CONSENSUS_RPC_PORT"
          #echo "DEBUG: $syncing_resp"
          #echo "DEBUG: $fin_resp"

        fi
        if [[ -n "$fin_resp" ]]; then
          echo "$(t "${consensus_client_name}_beacon_active")"
          echo "$fin_resp" | jq
        else
          echo "$(t "${consensus_client_name}_no_finality")"
        fi
      else
        echo "$syncing_resp" | jq
        local is_syncing=$(echo "$syncing_resp" | jq -r '.data.is_syncing')
        if [[ "$is_syncing" == "false" ]]; then
          echo "$(t "${consensus_client_name}_synced")"
        else
          echo "$(t "${consensus_client_name}_syncing")"
        fi
      fi
      ;;

    lighthouse)
      local syncing_resp=$(curl -s "http://localhost:$CONSENSUS_RPC_PORT/eth/v1/node/syncing")

          #echo "DEBUG: $CONSENSUS_RPC_PORT"
          #echo "DEBUG: $syncing_resp"

      if [[ "$syncing_resp" == "{}" || -z "$syncing_resp" ]]; then
        echo "$(t "lighthouse_no_sync_data")"
      else
        echo "$syncing_resp" | jq
        local is_syncing=$(echo "$syncing_resp" | jq -r '.data.is_syncing')
        if [[ "$is_syncing" == "false" ]]; then
          echo "$(t "lighthouse_synced")"
        else
          echo "$(t "lighthouse_syncing")"
        fi
      fi
      ;;

    *)
      echo "$(t "unknown_client" "$consensus_client_name")"
      ;;
  esac
}

function setup_cron_agent {
  local consensus_client_name=$(cat "$CLIENT_FILE" 2>/dev/null || echo "prysm") # Default to prysm if not set
  local consensus_client_display_name="${consensus_client_name^}"
  local execution_client_name_cron=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
  local execution_client_display_name_cron="${execution_client_name_cron^}"

  # Function to validate Telegram bot token
  validate_telegram_token() {
    local token=$1
    if [[ ! "$token" =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
      return 1
    fi
    # Test token by making API call
    local response=$(curl -s "https://api.telegram.org/bot${token}/getMe")
    if [[ "$response" == *"ok\":true"* ]]; then
      return 0
    else
      return 1
    fi
  }

  # Function to validate Telegram chat ID (updated version)
  validate_telegram_chat() {
    local token=$1
    local chat_id=$2
    # Test chat ID by trying to send a test message
    local response=$(curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
      -d chat_id="${chat_id}" \
      -d text="$(t "chatid_linked")" \
      -d parse_mode="Markdown")

    if [[ "$response" == *"ok\":true"* ]]; then
      return 0
    else
      return 1
    fi
  }

  # Get and validate Telegram bot token
  while true; do
    echo -e "\n${BLUE}$(t "enter_tg_token")${NC}"
    read -p "> " tg_token

    if validate_telegram_token "$tg_token"; then
      break
    else
      echo -e "${RED}$(t "invalid_token")${NC}"
      echo -e "${YELLOW}$(t "token_format")${NC}"
    fi
  done

  # Get and validate Telegram chat ID
  while true; do
    echo -e "\n${BLUE}$(t "enter_tg_chat")${NC}"
    read -p "> " tg_chat_id

    if [[ "$tg_chat_id" =~ ^-?[0-9]+$ ]]; then
      if validate_telegram_chat "$tg_token" "$tg_chat_id"; then
        break
      else
        echo -e "${RED}$(t "invalid_chatid")${NC}"
      fi
    else
      echo -e "${RED}$(t "chatid_number")${NC}"
    fi
  done

  #read -p "$(t "enter_tg_token")" tg_token
  #read -p "$(t "enter_tg_chat")" tg_chat_id

  echo "$(t "select_cron")"
  echo "$(t "cron_options")"
  read -p "$(t "select_option")" interval_choice

  case $interval_choice in
    1) cron_schedule="*/5 * * * *" ;;
    2) cron_schedule="*/10 * * * *" ;;
    3) cron_schedule="*/15 * * * *" ;;
    4) cron_schedule="*/30 * * * *" ;;
    5) cron_schedule="0 * * * *" ;;
    *)
      echo "$(t "invalid_interval")"
      cron_schedule="*/10 * * * *"
      ;;
  esac

  mkdir -p "$NODE_DIR" # Ensure the node directory exists
  touch "$AGENT_SCRIPT"
  chmod +x "$AGENT_SCRIPT"

  cat <<EOF > "$AGENT_SCRIPT"
#!/bin/bash
CLIENT="$consensus_client_name" # Consensus client name
CLIENT_DISPLAY_NAME="$consensus_client_display_name"
EXECUTION_CLIENT_NAME="$execution_client_name_cron"
EXECUTION_CLIENT_DISPLAY_NAME="$execution_client_display_name_cron"
TG_TOKEN="$tg_token"
TG_CHAT_ID="$tg_chat_id"

# Check Execution Client
execution_sync_response=\$(curl -s -X POST http://localhost:${EXECUTION_RPC_PORT} \\
  -H "Content-Type: application/json" \\
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')

if echo "\$execution_sync_response" | grep -q '"result":false'; then
  execution_status="✅ \$EXECUTION_CLIENT_DISPLAY_NAME synced"
elif echo "\$execution_sync_response" | grep -q '"result":'; then
  execution_status="⚠️ \$EXECUTION_CLIENT_DISPLAY_NAME syncing in progress"
else
  curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \\
    --data-urlencode "chat_id=\$TG_CHAT_ID" \\
    --data-urlencode "text=❌ \$EXECUTION_CLIENT_DISPLAY_NAME not responding or returned invalid data!"
  exit 1
fi

# Check Consensus Client
consensus_response=\$(curl -s http://localhost:${CONSENSUS_RPC_PORT}/eth/v1/node/syncing)
is_syncing=\$(echo "\$consensus_response" | jq -r '.data.is_syncing' 2>/dev/null)

if [ "\$is_syncing" == "false" ]; then
  consensus_status="✅ \$CLIENT_DISPLAY_NAME synced" # CLIENT_DISPLAY_NAME here is consensus_client_name
elif [ "\$is_syncing" == "true" ]; then
  consensus_status="⚠️ \$CLIENT_DISPLAY_NAME syncing in progress" # CLIENT_DISPLAY_NAME here is consensus_client_name
else
  curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \\
    --data-urlencode "chat_id=\$TG_CHAT_ID" \\
    --data-urlencode "text=❌ \$CLIENT_DISPLAY_NAME not responding or returned invalid data!" # CLIENT_DISPLAY_NAME here is consensus_client_name
  exit 1
fi

get_ip_address() {
  curl -s https://api.ipify.org || echo "unknown-ip"
}
ip=\$(get_ip_address)

STATUS_MSG="[Sepolia Node Monitor]
🌐 Server: \$ip
Execution client: \$execution_status
Consensus client: \$consensus_status"

curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \\
  --data-urlencode "chat_id=\$TG_CHAT_ID" \\
  --data-urlencode "text=\$STATUS_MSG"
EOF


  # Remove old entry if exists
  crontab -l 2>/dev/null | grep -v "$AGENT_SCRIPT" > /tmp/current_cron

  # Add new entry with selected interval
  echo "$cron_schedule $AGENT_SCRIPT" >> /tmp/current_cron
  crontab /tmp/current_cron
  rm /tmp/current_cron

  print_success "$(t "cron_installed" "$cron_schedule")"
}

function remove_cron_agent {
  crontab -l 2>/dev/null | grep -v "$AGENT_SCRIPT" | crontab -
  rm -f "$AGENT_SCRIPT"
  print_success "$(t "cron_removed")"
}

function stop_containers {
  print_info "$(t "stop_containers")"
  if [[ -f "$DOCKER_COMPOSE_FILE" ]]; then
    docker compose -f "$DOCKER_COMPOSE_FILE" down
    print_success "$(t "containers_stopped")"
  else
    print_warning "$(t "no_compose")"
  fi
}

function start_containers {
  print_info "$(t "start_containers")"
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d
  print_success "$(t "containers_started")"
}

function check_disk_usage {
  print_info "$(t "disk_usage")"

  local execution_client_name=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
  # Determine container name - for Geth, Reth, Nethermind, it's the same as the client name.
  local execution_container_name="$execution_client_name"

  print_info "$(t "execution_client_usage" "$execution_client_name")"
  docker exec -it "$execution_container_name" du -sh /data 2>/dev/null || print_warning "$(t "container_not_running" "$execution_container_name")"

  if [[ -f "$CLIENT_FILE" ]]; then
    local consensus_client_name=$(cat "$CLIENT_FILE")
    print_info "$(t "client_usage" "$consensus_client_name")" # This is for the consensus client
    # Adjust data path based on consensus client if necessary, e.g. lighthouse uses /root/.lighthouse
    local consensus_data_path="/data"
    if [[ "$consensus_client_name" == "lighthouse" ]]; then
      consensus_data_path="/root/.lighthouse"
    fi
    docker exec -it "$consensus_client_name" du -sh "$consensus_data_path" 2>/dev/null || print_warning "$(t "container_not_running" "$consensus_client_name")"
  else
    # This was client_not_found for consensus client, perhaps we don't need a message if EXECUTION_CLIENT_FILE is also missing as it defaults
    print_warning "$(t "client_not_found" "$CLIENT_FILE")"
  fi
}

function delete_node {
  print_warning "$(t "confirm_delete")"
  read -r confirm
  if [[ "$confirm" == "y" ]]; then
    stop_containers
    rm -rf "$NODE_DIR"
    remove_cron_agent
    print_success "$(t "deleted")"
  else
    print_info "$(t "cancelled")"
  fi
}

function change_intsalled_ports {
  print_warning "\n$(t "updating_ports")"
  echo ""
  ask_for_custom_ports
  echo ""
  create_docker_compose
  print_success "\n$(t "ports_updated")"
  print_warning "\n$(t "restart_required")"
}

function firewall_setup() {
    while true; do
        echo ""
        print_info "$(t "firewall_menu")"
        echo "1) $(t "firewall_enable")"
        echo "2) $(t "firewall_local_ports")"
        echo "3) $(t "firewall_remote_ip")"
        echo "4) $(t "firewall_delete_rules" "$EXECUTION_RPC_PORT" "$CONSENSUS_RPC_PORT" "$EXECUTION_P2P_PORT" "$CONSENSUS_P2P_PORT")"
        echo "5) $(t "firewall_view_rules")"
        echo "6) $(t "firewall_disable")"
        echo -e "${RED}7) $(t "back")${RESET}"
        read -p "$(t "select_option")" ufw_choice

        case $ufw_choice in
            1)
                echo "$(t "enabling_firewall")"
                if sudo ufw status | grep -q "Status: active"; then
                    print_info "$(t "firewall_already_enabled")"
                else
                    read -p "$(t "confirm_enable_firewall") [y/n]: " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        sudo ufw allow 22
                        sudo ufw allow ssh
                        sudo ufw enable
                        print_success "$(t "firewall_enabled_success")"
                    else
                        print_info "$(t "firewall_enable_cancelled")"
                    fi
                fi
                ;;
            2)
                echo "$(t "setting_local_ports")"
                sudo ufw allow $EXECUTION_P2P_PORT/tcp
                sudo ufw allow $EXECUTION_P2P_PORT/udp
                sudo ufw allow $CONSENSUS_P2P_PORT/tcp # Assuming consensus P2P might also be needed locally by some setups
                sudo ufw allow $CONSENSUS_P2P_PORT/udp # Assuming consensus P2P might also be needed locally by some setups
                sudo ufw allow from 127.0.0.1 to any port $EXECUTION_RPC_PORT proto tcp
                sudo ufw allow from 127.0.0.1 to any port $CONSENSUS_RPC_PORT proto tcp
                sudo ufw reload
                print_success "$(t "local_ports_success")"
                ;;
            3)
                read -p "$(t "enter_ip")" remote_ip
                echo "$(t "setting_remote_ports") $remote_ip..."
                sudo ufw allow $EXECUTION_P2P_PORT/tcp
                sudo ufw allow $EXECUTION_P2P_PORT/udp
                sudo ufw allow $CONSENSUS_P2P_PORT/tcp
                sudo ufw allow $CONSENSUS_P2P_PORT/udp
                sudo ufw deny $EXECUTION_RPC_PORT/tcp
                sudo ufw deny $CONSENSUS_RPC_PORT/tcp
                sudo ufw allow from "$remote_ip" to any port $EXECUTION_RPC_PORT proto tcp
                sudo ufw allow from "$remote_ip" to any port $CONSENSUS_RPC_PORT proto tcp
                sudo ufw reload
                print_success "$(t "remote_ports_success")"
                ;;
            4)
                echo "$(t "deleting_old_rules")"
                # Получаем список правил, нумерованных. Search for any of the main ports.
                mapfile -t rules < <(sudo ufw status numbered | grep -E "$EXECUTION_RPC_PORT|$CONSENSUS_RPC_PORT|$EXECUTION_P2P_PORT|$CONSENSUS_P2P_PORT" | nl -w1 -s':' | tac)

                if [[ ${#rules[@]} -eq 0 ]]; then
                    print_info "$(t "no_matching_rules" "$EXECUTION_RPC_PORT" "$CONSENSUS_RPC_PORT" "$EXECUTION_P2P_PORT" "$CONSENSUS_P2P_PORT")"
                else
                    print_info "$(t "rules_to_be_deleted")"
                    for rule in "${rules[@]}"; do
                        rule_num=$(echo "$rule" | awk -F: '{print $1}' | xargs)
                        rule_text=$(echo "$rule" | cut -d: -f2-)
                        echo "  $rule_num: $rule_text"
                    done

                    echo
                    print_warning "$(t "confirm_delete_firewall_rules" "$EXECUTION_RPC_PORT" "$CONSENSUS_RPC_PORT" "$EXECUTION_P2P_PORT" "$CONSENSUS_P2P_PORT") (y/n)"
                    read -r confirm
                    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                        print_info "$(t "firewall_delete_cancelled")"
                    else
                        for rule in "${rules[@]}"; do
                            rule_num=$(echo "$rule" | awk -F: '{print $1}' | xargs)
                            echo "$(t "deleting_rule_number") $rule_num: $(echo "$rule" | cut -d: -f2-)"
                            sudo ufw --force delete "$rule_num"
                        done
                        sudo ufw reload
                        print_success "$(t "rules_deleted_success")"
                    fi
                fi
                ;;
            5)
                echo ""
                echo "===== $(t "view_ufw_rules") ====="
                sudo ufw status verbose
                echo ""
                read -p "$(t "press_enter_to_continue")"
                ;;
            6)
                echo "$(t "disabling_firewall")"
                read -p "$(t "confirm_disable_firewall") [y/n]: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    sudo ufw disable
                    print_success "$(t "firewall_disabled_success")"
                else
                    print_info "$(t "firewall_disable_cancelled")"
                fi
                ;;
            7)
                echo "$(t "return_main_menu")"
                break
                ;;
            *)
                echo "$(t "invalid_option")"
                ;;
        esac
    done
}


#Script created by Creed https://www.notion.so/Aztec-Commands-by-Creed-1f2da4dd4652808e908bc7426bbbb284
function run_rpc_check {
  URL="https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/other/rpc_check.sh"
  echo -e "${CYAN}Running RPC check script from GitHub...${RESET}"
  bash <(curl -s "$URL") || print_error "Failed to run RPC check script."
}

# Main menu
function main_menu {
  show_logo
  check_version
  load_port_configuration # Load config at the start of the menu
  while true; do
    echo -e "\n${BLUE}$(t "menu_title")${RESET}"
    echo -e "$(t "menu_options")"
    echo -e "${BLUE}==================================${RESET}"
    read -p "$(t "select_option")" choice
    case $choice in
      1) install_requirements ;;
      2) install_node ;;
      3) update_node ;;
      4) view_logs ;;
      5) check_sync ;;
      6) setup_cron_agent ;;
      7) remove_cron_agent ;;
      8) stop_containers ;;
      9) start_containers ;;
      10) delete_node ;;
      11) change_intsalled_ports ;;
      12) check_disk_usage ;;
      13) firewall_setup ;;
      14) run_rpc_check ;;
      0) print_info "$(t "goodbye")"; exit 0 ;;
      *) print_error "$(t "invalid_option")" ;;
    esac
  done
}

main_menu
