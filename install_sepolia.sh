#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
VIOLET='\033[0;35m'
RESET='\033[0m'

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
            "welcome") echo "                     Welcome to the Sepolia Ethereum Node Setup and Management Script" ;;
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
            "execution") echo "🧠 Execution (geth):" ;;
            "execution_synced") echo "   ✅ Execution synchronized" ;;
            "execution_syncing") echo "⏳ Geth is syncing..." ;;
            "prysm_synced") echo "   ✅ Prysm synchronized" ;;
            "prysm_syncing") echo "⏳ Prysm is syncing..." ;;
            "teku_synced") echo "   ✅ Teku synchronized" ;;
            "teku_syncing") echo "⏳ Teku is syncing..." ;;
            "lighthouse_synced") echo "   ✅ Lighthouse synchronized" ;;
            "lighthouse_syncing") echo "⏳ Lighthouse is syncing..." ;;
            "syncing") echo "⏳ Geth is syncing..." ;;
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
            "menu_options") echo '1) Install prerequisites (Docker and other software)\n2) Install node\n3) Update node\n4) Check logs\n5) Check sync status\n6) Setup cron agent wiht Tg notifications\n7) Remove cron agent\n8) Stop containers\n9) Start containers\n10) Delete node\n11) Check disk usage\n12) Firewall management\n13) Exit' ;;
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
            *) echo "$key" ;;
        esac
    else
        case "$key" in
            "welcome") echo "                     Добро пожаловать в скрипт установки и управления нодой Sepolia Ethereum" ;;
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
            "execution") echo "🧠 Execution (geth):" ;;
            "execution_synced") echo "   ✅ Execution синхронизирован" ;;
            "execution_syncing") echo "⏳ Geth синхронизируется..." ;;
            "prysm_synced") echo "   ✅ Prysm синхронизирован" ;;
            "prysm_syncing") echo "⏳ Prysm синхронизируется..." ;;
            "teku_synced") echo "   ✅ Teku синхронизирован" ;;
            "teku_syncing") echo "⏳ Teku синхронизируется..." ;;
            "lighthouse_synced") echo "   ✅ Lighthouse синхронизирован" ;;
            "lighthouse_syncing") echo "⏳ Lighthouse синхронизируется..." ;;
            "syncing") echo "⏳ Geth синхронизируется..." ;;
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
            "menu_options") echo '1) Установить требования (Docker и другое ПО)\n2) Установить ноду\n3) Обновить ноду\n4) Проверить логи\n5) Проверить статус синхронизации\n6) Установить cron-агент с Тг уведомлениями\n7) Удалить cron-агент\n8) Остановить контейнеры\n9) Запустить контейнеры\n10) Удалить ноду\n11) Проверить занимаемое место\n12) Управление файрволлом\n13) Выйти' ;;
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
            *) echo "$key" ;;
        esac
    fi
}

# Rest of the script remains the same, just replace all echo messages with t function calls
# For example:
# print_info "🔐 Генерация jwt.hex..." becomes print_info "$(t "jwt_gen")"
# print_success "✅ Выбран клиент: $client" becomes print_success "$(t "client_selected" "$client")"

NODE_DIR="/root/sepolia-node"
DOCKER_COMPOSE_FILE="$NODE_DIR/docker-compose.yml"
JWT_FILE="$NODE_DIR/jwt.hex"
CLIENT_FILE="$NODE_DIR/client"
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
  head -c 32 /dev/urandom | xxd -p -c 32 > "$JWT_FILE"
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
  local client=$(cat "$CLIENT_FILE" 2>/dev/null || echo "")
  if [[ -z "$client" ]]; then
    print_error "$(t "unknown_client" "$client")"
    exit 1
  fi

  print_info "$(t "creating_compose" "$client")"
  cat > "$DOCKER_COMPOSE_FILE" <<EOF
services:
  geth:
    image: ethereum/client-go:stable
    container_name: geth
    restart: unless-stopped
    volumes:
      - $NODE_DIR/geth:/data
      - $JWT_FILE:/jwt.hex
    ports:
      - "8545:8545"
      - "30303:30303"
      - "8551:8551"
    command: >
      --sepolia
      --datadir /data
      --http --http.addr 0.0.0.0 --http.api eth,web3,net,engine
      --authrpc.addr 0.0.0.0 --authrpc.port 8551
      --authrpc.jwtsecret /jwt.hex
      --authrpc.vhosts=*
      --http.corsdomain="*"
      --syncmode=snap
      --cache=4096
EOF

  case $client in
    lighthouse)
      cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  lighthouse:
    image: sigp/lighthouse:latest
    container_name: lighthouse
    restart: unless-stopped
    volumes:
      - $NODE_DIR/lighthouse:/root/.lighthouse
      - $JWT_FILE:/root/jwt.hex
    depends_on:
      - geth
    ports:
      - "5052:5052"
      - "9000:9000/tcp"
      - "9000:9000/udp"
    command: >
      lighthouse bn
      --network sepolia
      --execution-endpoint http://geth:8551
      --execution-jwt /root/jwt.hex
      --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      --http
      --http-address 0.0.0.0
EOF
      ;;
    prysm)
      cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  prysm:
    image: gcr.io/prysmaticlabs/prysm/beacon-chain:stable
    container_name: prysm
    restart: unless-stopped
    volumes:
      - $NODE_DIR/prysm:/data
      - $JWT_FILE:/jwt.hex
    depends_on:
      - geth
    ports:
      - "5052:5052"
    command: >
      --sepolia
      --datadir=/data
      --execution-endpoint=http://geth:8551
      --jwt-secret=/jwt.hex
      --accept-terms-of-use
      --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      --grpc-gateway-port=5052
      --grpc-gateway-host=0.0.0.0
EOF
      ;;
    teku)
      cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  teku:
    image: consensys/teku:latest
    container_name: teku
    restart: unless-stopped
    volumes:
      - $NODE_DIR/teku:/data
      - $JWT_FILE:/jwt.hex
    depends_on:
      - geth
    ports:
      - "5052:5052"
    command: >
      --network=sepolia
      --data-path=/data
      --ee-endpoint=http://geth:8551
      --ee-jwt-secret-file=/jwt.hex
      --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      --rest-api-enabled=true
      --rest-api-interface=0.0.0.0
EOF
      ;;
    *)
      echo "$(t "unknown_client" "$client")"
      exit 1
      ;;
  esac
}

function install_node {
  mkdir -p "$NODE_DIR"
  print_info "$(t "node_install")"
  choose_consensus_client
  generate_jwt
  create_docker_compose
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d
  print_success "$(t "node_installed")"
  echo -e "${BLUE}RPC:${RESET}      http://localhost:8545"
  echo -e "${BLUE}BEACON:${RESET}   http://localhost:5052"
}

function update_node {
  print_info "$(t "node_update")"
  docker compose -f "$DOCKER_COMPOSE_FILE" pull
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d
  print_success "$(t "node_updated")"
}

function view_logs {
  local client=$(cat "$CLIENT_FILE" 2>/dev/null || echo "lighthouse")
  print_info "$(t "select_logs")"
  select opt in "Geth" "$client" "$(t "back")"; do
    case $REPLY in
      1) docker logs -f geth; break ;;
      2) docker logs -f "$client"; break ;;
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
  local client=$(cat "$CLIENT_FILE" 2>/dev/null || echo "lighthouse")
  print_info "$(t "check_sync")"

  print_info "$(t "execution")"
  local sync_data=$(curl -s -X POST http://localhost:8545 -H 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
  local is_syncing=$(echo "$sync_data" | jq -r '.result')

  if [[ "$is_syncing" == "false" ]]; then
    echo "$(t "execution_synced")"
  else
    local current=$(echo "$sync_data" | jq -r '.result.currentBlock')
    local highest=$(echo "$sync_data" | jq -r '.result.highestBlock')

    if [[ -z "$current" || -z "$highest" || "$current" == "null" || "$highest" == "null" ]]; then
      echo "$(t "sync_data_missing")"
    else
      local current_dec=$(hex_to_dec "$current")
      local highest_dec=$(hex_to_dec "$highest")

      if [[ $highest_dec -eq 0 ]]; then
        echo "$(t "sync_data_invalid")"
      else
        local remaining=$((highest_dec - current_dec))
        local progress=$((100 * current_dec / highest_dec))
        echo "$(t "syncing")"
        echo "$(t "current_block" "$current_dec")"
        echo "$(t "target_block" "$highest_dec")"
        echo "$(t "blocks_left" "$remaining")"
        echo "$(t "progress" "$progress")"

        echo "$(t "sync_speed")"
        sleep 5
        local sync_data2=$(curl -s -X POST http://localhost:8545 -H 'Content-Type: application/json' \
          --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
        local current2=$(echo "$sync_data2" | jq -r '.result.currentBlock')
        local current2_dec=$(hex_to_dec "$current2")

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
    fi
  fi

  echo ""
  echo "$(t "consensus" "$client")"

  case "$client" in
    prysm|teku)
      local syncing_resp=$(curl -s http://localhost:5052/eth/v1/node/syncing)
      if [[ "$syncing_resp" == "{}" || -z "$syncing_resp" ]]; then
        echo "$(t "${client}_no_sync_data")"
        local fin_resp=$(curl -s http://localhost:5052/eth/v1/node/finality)
        if [[ -z "$fin_resp" ]]; then
          fin_resp=$(curl -s http://localhost:5052/eth/v1/beacon/states/head/finality_checkpoints)
        fi
        if [[ -n "$fin_resp" ]]; then
          echo "$(t "${client}_beacon_active")"
          echo "$fin_resp" | jq
        else
          echo "$(t "${client}_no_finality")"
        fi
      else
        echo "$syncing_resp" | jq
        local is_syncing=$(echo "$syncing_resp" | jq -r '.data.is_syncing')
        if [[ "$is_syncing" == "false" ]]; then
          echo "$(t "${client}_synced")"
        else
          echo "$(t "${client}_syncing")"
        fi
      fi

      echo ""
      echo "$(t "${client}_health")"
      curl -s http://localhost:5052/eth/v1/node/health | jq
      ;;

    lighthouse)
      local syncing_resp=$(curl -s http://localhost:5052/eth/v1/node/syncing)
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

      echo ""
      echo "$(t "lighthouse_health")"
      curl -s http://localhost:5052/eth/v1/node/health | jq
      ;;

    *)
      echo "$(t "unknown_client" "$client")"
      ;;
  esac
}

function setup_cron_agent {
  local client=$(cat "$CLIENT_FILE" 2>/dev/null || echo "")
  read -p "$(t "enter_tg_token")" tg_token
  read -p "$(t "enter_tg_chat")" tg_chat_id

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

  touch "$AGENT_SCRIPT"
  chmod +x "$AGENT_SCRIPT"

  cat <<EOF > "$AGENT_SCRIPT"
#!/bin/bash
CLIENT="$client"
TG_TOKEN="$tg_token"
TG_CHAT_ID="$tg_chat_id"

# Проверка Geth
geth_sync_response=\$(curl -s -X POST http://localhost:8545 \\
  -H "Content-Type: application/json" \\
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')

if echo "\$geth_sync_response" | grep -q '"result":false'; then
  geth_status="✅ Geth synced"
elif echo "\$geth_sync_response" | grep -q '"result":'; then
  geth_status="⚠️ Geth syncing in progress"
else
  curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \\
    --data-urlencode "chat_id=\$TG_CHAT_ID" \\
    --data-urlencode "text=❌ Geth not responding or returned invalid data!"
  exit 1
fi

# Проверка Consensus клиента
consensus_response=\$(curl -s http://localhost:5052/eth/v1/node/syncing)
is_syncing=\$(echo "\$consensus_response" | jq -r '.data.is_syncing' 2>/dev/null)

if [ "\$is_syncing" == "false" ]; then
  consensus_status="✅ \$CLIENT synced"
elif [ "\$is_syncing" == "true" ]; then
  consensus_status="⚠️ \$CLIENT syncing in progress"
else
  curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \\
    --data-urlencode "chat_id=\$TG_CHAT_ID" \\
    --data-urlencode "text=❌ \$CLIENT not responding or returned invalid data!"
  exit 1
fi

STATUS_MSG="[Sepolia Node Monitor]
Execution client: \$geth_status
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

  print_info "$(t "geth_usage")"
  docker exec -it geth du -sh /data 2>/dev/null || print_warning "$(t "container_not_running" "geth")"

  if [[ -f "$CLIENT_FILE" ]]; then
    local client=$(cat "$CLIENT_FILE")
    print_info "$(t "client_usage" "$client")"
    docker exec -it "$client" du -sh /data 2>/dev/null || \
    docker exec -it "$client" du -sh /root/.lighthouse 2>/dev/null || \
    print_warning "$(t "container_not_running" "$client")"
  else
    print_warning "$(t "client_not_found" "$CLIENT_FILE")"
  fi
}

function delete_node {
  print_warning "$(t "confirm_delete")"
  read -r confirm
  if [[ "$confirm" == "y" ]]; then
    stop_containers
    rm -rf "$NODE_DIR"
    print_success "$(t "deleted")"
  else
    print_info "$(t "cancelled")"
  fi
}

firewall_setup() {
    while true; do
        echo ""
        echo "$(t "firewall_menu")"
        echo "1) $(t "firewall_enable")"
        echo "2) $(t "firewall_local_ports")"
        echo "3) $(t "firewall_remote_ip")"
        echo "4) $(t "back")"
        read -p "$(t "select_option")" uwf_choice

        case $uwf_choice in
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
                sudo ufw allow 30303/tcp
                sudo ufw allow 30303/udp
                sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp
                sudo ufw allow from 127.0.0.1 to any port 5052 proto tcp
                sudo ufw reload
                print_success "$(t "local_ports_success")"
                ;;
            3)
                read -p "$(t "enter_ip")" remote_ip
                echo "$(t "setting_remote_ports") $remote_ip..."
                sudo ufw allow 30303/tcp
                sudo ufw allow 30303/udp
                sudo ufw deny 8545/tcp
                sudo ufw deny 3500/tcp
                sudo ufw allow from "$remote_ip" to any port 8545 proto tcp
                sudo ufw allow from "$remote_ip" to any port 5052 proto tcp
                sudo ufw reload
                print_success "$(t "remote_ports_success")"
                ;;
            4)
                echo "$(t "return_main_menu")"
                break
                ;;
            *)
                echo "$(t "invalid_choice")"
                ;;
        esac
    done
}

# Main menu
function main_menu {
  show_logo
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
      11) check_disk_usage ;;
      12) firewall_setup ;;
      13) print_info "$(t "goodbye")"; exit 0 ;;
      *) print_error "$(t "invalid_option")" ;;
    esac
  done
}

main_menu