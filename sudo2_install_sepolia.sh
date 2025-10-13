#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
VIOLET='\033[0;35m'
RESET='\033[0m'

SCRIPT_VERSION="1.7.1"

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
            "menu_options") echo -e '1) Install prerequisites (Docker and other software)\n2) Install node\n3) Update node\n4) Check logs\n5) Check sync status\n6) Setup cron agent wiht Tg notifications\n7) Remove cron agent\n8) Stop containers\n9) Start containers\n\033[31m10) Delete node\033[0m\n11) Change ports for installed node\n12) Check disk usage\n13) Firewall management\n14) Check RPC server\n15) Configure Docker resources\n\033[31m0) Exit\033[0m' ;;
            "goodbye") echo "👋 Goodbye!" ;;
            "invalid_option") echo "❌ Invalid choice, try again." ;;
            "select_option") echo "Select option: " ;;
            "start_containers") echo "🏃‍➡️ Starting containers..." ;;
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
            "ask_custom_ports_prompt") echo "Do you want to configure custom ports? (yes/no, default: no)" ;;
            "enter_exec_rpc_port") printf "Enter Execution Client RPC Port (default: %s): " "$1" ;;
            "enter_exec_p2p_port") printf "Enter Execution Client P2P Port (default: %s): " "$1" ;;
            "enter_exec_auth_port") printf "Enter Execution Client Auth RPC Port (default: %s): " "$1" ;;
            "enter_consensus_rpc_port") printf "Enter Consensus Client RPC Port (default: %s): " "$1" ;;
            "enter_consensus_p2p_port") printf "Enter Consensus Client P2P Port (default: %s): " "$1" ;;
            "invalid_port_input") echo "❌ Invalid input. Port must be a number between 1024 and 65535." ;;
            "ports_configured_message") printf "✅ Ports configured. Execution: RPC=%s, P2P=%s, Auth=%s. Consensus: RPC=%s, P2P=%s.\n" "$1" "$2" "$3" "$4" "$5" ;;
            "current_port_config") printf "🛈 Current ports \n  Execution: RPC=%s, P2P=%s, Auth=%s.\n  Consensus: BEACON=%s, P2P=%s.\n" "$1" "$2" "$3" "$4" "$5" ;;
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
            # Basic messages
            "press_enter_to_continue") echo "Press Enter to continue..." ;;
            "are_you_sure_prompt") echo "Are you sure? [y/N]: " ;;
            # New translation keys
            "checking_docker_chain_rules") echo "Checking rules in DOCKER chain" ;;
            "docker_chain_available") echo "DOCKER chain is available" ;;
            "docker_chain_not_found") echo "DOCKER chain not found" ;;
            "checking_execution_rpc_port") echo "Checking rules for EXECUTION RPC port" ;;
            "checking_consensus_rpc_port") echo "Checking rules for CONSENSUS RPC port" ;;
            "found_rule_for_port") echo "Found rule for port" ;;
            "destination_ip") echo "Destination IP" ;;
            "failed_to_get_ip") echo "Failed to determine destination IP" ;;
            "adding_accept_rule_for_ip") echo "Adding ACCEPT rule for IP" ;;
            "accept_rule_already_exists") echo "ACCEPT rule already exists for IP" ;;
            "added_rules_count") echo "Added total rules count for" ;;
            # DOCKER-USER chain check messages
            "checking_docker_user_chain") echo "[Check] Looking for DOCKER-USER chain..." ;;
            "docker_user_chain_not_found") echo "[Error] DOCKER-USER chain not found!" ;;
            "creating_docker_user_chain") echo "Creating new DOCKER-USER chain..." ;;
            "docker_user_chain_created") echo "✅ DOCKER-USER chain created" ;;
            "added_forward_to_docker_user") echo "Added FORWARD -> DOCKER-USER jump" ;;
            "docker_user_chain_available") echo "✅ DOCKER-USER chain available" ;;
            "adding_forward_to_docker_user") echo "Adding FORWARD -> DOCKER-USER jump..." ;;
            "forward_to_docker_user_added") echo "✅ FORWARD -> DOCKER-USER jump added" ;;
            "forward_to_docker_user_exists") echo "✅ FORWARD -> DOCKER-USER jump already exists" ;;
            # UFW messages
            "checking_ufw_status") echo "[Check] Checking UFW status..." ;;
            "ufw_already_enabled") echo "✅ UFW already enabled" ;;
            "ufw_disabled_configuring") echo "[Notice] UFW disabled, configuring..." ;;
            "adding_ssh_port_rule") echo "Adding SSH rule (port 22)..." ;;
            "adding_ssh_name_rule") echo "Adding SSH rule (by name ssh)..." ;;
            "adding_exec_p2p_port_rule") echo "Adding rule for execution иconsensus P2P..." ;;
            "port_rule_exists") echo "The rule for the port already exists" ;;
            "enabling_ufw") echo "Enabling UFW..." ;;
            "ufw_enabled_successfully") echo "✅ UFW enabled successfully" ;;
            "current_ufw_status") echo "Current UFW status:" ;;
            "failed_to_enable_ufw") echo "[Error] Failed to enable UFW" ;;
            # Port blocking messages
            "blocking_rpc_ports") echo "[Action] Blocking incoming connections on RPC and BEACON ports" ;;
            "blocked_ports") echo "✅ Blocked ports:" ;;
            "ports_already_blocked") echo "⚠️ Ports already blocked:" ;;
            # Rule addition messages
            "adding_rule") echo "[Action] Adding rule:" ;;
            "rule_added") echo "✅ Rule added" ;;
            "failed_to_add_rule") echo "[Error] Failed to add rule!" ;;
            "rule_already_exists") echo "[Skip] Rule already exists" ;;
            # Rule viewing messages
            "current_port_rules") echo "── Current port rules ──" ;;
            "docker_user_port_rules") echo "DOCKER-USER port rules:" ;;
            "ufw_port_rules") echo "UFW port rules:" ;;
            "current_ip_rules") echo "── Current IP rules ──" ;;
            "docker_user_ip_rules") echo "DOCKER-USER IP rules:" ;;
            "ufw_ip_rules") echo "UFW IP rules:" ;;
            # Port management menu
            "port_management_menu") echo "────── Port Management ──────" ;;
            "open_port_option") echo "Open port (add rule)" ;;
            "close_port_option") echo "Close port (delete rule by number)" ;;
            "block_rpc_ports_option") echo "Block RPC and BEACON ports" ;;
            "return_to_main_menu") echo "Return to main menu" ;;
            # Port opening messages
            "opening_port") echo "── Opening port ──" ;;
            "enter_port_number_prompt") echo "Enter port number (e.g., 8080 or 8545,5052,9000): " ;;
            "select_direction") echo "Select direction:" ;;
            "incoming_connections") echo "Incoming connections (--dport)" ;;
            "outgoing_connections") echo "Outgoing connections (--sport)" ;;
            "all_directions") echo "All directions" ;;
            "select_direction_prompt") echo "Select direction: " ;;
            "select_protocol") echo "Select protocol:" ;;
            "all_protocols") echo "All protocols" ;;
            "select_protocol_prompt") echo "Select protocol: " ;;
            "adding_iptables_rule") echo "Adding iptables rule: port" ;;
            "adding_ufw_rule") echo "Adding UFW rule: port" ;;
            "in_and_out") echo "incoming and outgoing" ;;
            "direction") echo "direction" ;;
            "protocol") echo "protocol" ;;
            "invalid_input_error") echo "Error: invalid input" ;;
            # Rule deletion messages
            "deleting_rules") echo "────── Rule Deletion ──────" ;;
            "select_rule_type_to_delete") echo "Select rule type to delete:" ;;
            "delete_iptables_rule") echo "Delete iptables rule" ;;
            "delete_ufw_rule") echo "Delete UFW rule" ;;
            "delete_both_rules") echo "Delete both (iptables and UFW)" ;;
            "enter_iptables_rule_numbers") echo "Enter iptables rule numbers (e.g., 1 or 1,2 or 1,5-8,12):" ;;
            "enter_ufw_rule_numbers") echo "Enter UFW rule numbers (e.g., 1 or 1,2 or 1,5-8,12):" ;;
            "rule_numbers_to_delete_prompt") echo "Rule numbers to delete: " ;;
            "iptables_rule_numbers_prompt") echo "iptables rule numbers to delete: " ;;
            "ufw_rule_numbers_prompt") echo "UFW rule numbers to delete: " ;;
            "deleting_iptables_rule") echo "Deleting iptables rule" ;;
            "deleting_ufw_rule") echo "Deleting UFW rule" ;;
            "rule_not_found_skipping") echo "Rule not found, skipping" ;;
            "invalid_rule_number_skipping") echo "Invalid rule number, skipping" ;;
            "failed_to_delete_rule") echo "Failed to delete rule" ;;
            "deleted_iptables_rules") echo "Deleted iptables rules:" ;;
            "deleted_ufw_rules") echo "Deleted UFW rules:" ;;
            "invalid_choice_cancel") echo "Invalid choice, deletion canceled" ;;
            "invalid_range_skipping") echo "Invalid range, skipping" ;;
            # RPC ports blocking
            "blocking_rpc_ports_for_all") echo "── Blocking RPC and BEACON ports for all incoming connections ──" ;;
            "changing_ufw_policy_to_block_all") echo "Changing UFW policy to block all incoming connections" ;;
            # IP management menu
            "ip_management_menu") echo "────── IP Address Management ──────" ;;
            "allow_access_from_ip") echo "Allow access from IP address" ;;
            "deny_access_delete_rule") echo "Deny access (delete rule)" ;;
            # IP management messages
            "allowing_access_from_ip") echo "── Allowing access from IP ──" ;;
            "enter_ip_or_subnet_prompt") echo "Enter IP address or subnet (e.g., 192.168.1.1 or 192.168.1.0/24 or few addresses separated by commas): " ;;
            "enter_port_number_optional_prompt") echo "Enter port number (5052 or 5052,9100 or leave empty for all ports): " ;;
            "adding_iptables_rule_for_all_traffic_from") echo "Adding iptables rule for all traffic from" ;;
            "adding_ufw_rule_for_all_traffic_from") echo "Adding UFW rule for all traffic from" ;;
            "adding_iptables_rule_for_port") echo "Adding iptables rule for port" ;;
            "from") echo "from" ;;
            "adding_ufw_rule_for_port") echo "[Action] Adding UFW rule for port" ;;
            "port_must_be_number_error") echo "Error: port must be a number" ;;
            "correct_input_examples") echo "Correct input examples:" ;;
            "ip_example") echo "IP: 192.168.1.1 or 10.0.0.0/24" ;;
            # View all rules
            "view_all_rules") echo "────── View All Rules ──────" ;;
            "current_docker_user_chain_rules") echo "Current DOCKER-USER chain rules:" ;;
            "no_rules_in_docker_user_chain") echo "No rules in DOCKER-USER chain" ;;
            "current_ufw_rules") echo "Current UFW rules:" ;;
            "no_active_ufw_rules") echo "No active UFW rules" ;;
            "iptables_rules_stats") echo "iptables rules statistics:" ;;
            "total_accept_rules") echo "Total ACCEPT rules:" ;;
            "total_drop_reject_rules") echo "Total DROP/REJECT rules:" ;;
            "ufw_rules_stats") echo "UFW rules statistics:" ;;
            "default_policy") echo "Default policy:" ;;
            "incoming") echo "Incoming:" ;;
            "outgoing") echo "Outgoing:" ;;
            "total_allow_rules") echo "Total ALLOW rules:" ;;
            "total_deny_reject_rules") echo "Total DENY/REJECT rules:" ;;
            # Rules reset
            "reset_all_rules") echo "────── Reset All Rules ──────" ;;
            "you_are_about_to_perform") echo "You are about to perform the following actions:" ;;
            "clear_all_rules_in_docker_user_chain") echo "Clear all rules in DOCKER-USER chain" ;;
            "reset_all_ufw_rules") echo "Reset all UFW rules" ;;
            "restart_docker_service") echo "Restart Docker service" ;;
            "clearing_docker_user_chain") echo "Clearing DOCKER-USER chain" ;;
            "all_docker_user_rules_deleted") echo "✅ All DOCKER-USER rules deleted" ;;
            "failed_to_clear_docker_user") echo "[Error] Failed to clear DOCKER-USER" ;;
            "resetting_ufw_rules") echo "Resetting UFW rules" ;;
            "all_ufw_rules_reset") echo "✅ All UFW rules reset" ;;
            "failed_to_reset_ufw") echo "[Error] Failed to reset UFW" ;;
            "restarting_docker") echo "Restarting Docker" ;;
            "docker_restarted_successfully") echo "✅ Docker restarted successfully" ;;
            "current_docker_user_status") echo "Current DOCKER-USER status:" ;;
            "failed_to_restart_docker") echo "[Error] Failed to restart Docker" ;;
            "rules_reset_cancelled") echo "Rules reset cancelled" ;;
            # Main menu
            "script_works_in_iptables") echo "Script works with iptables using DOCKER-USER chain and duplicates rules for ufw." ;;
            "port_ip_management_logic") echo "Port/IP management logic is based on adding/removing allow rules." ;;
            "on_first_run") echo "Before working with the function, run the Sepolia node installation. On first run:" ;;
            "first_run_option_1") echo "First run option 1. Confirm ufw activation and ensure iptables are configured;" ;;
            "first_run_option_2") echo "Then using option 2 (item 1 within the option), open the required ports for your node to work. For example for Aztec: 8080,40400" ;;
            "first_run_option_3") echo "Finally using option 2 (item 3 within the option), block RPC and BEACON ports for incoming connections." ;;
            "now_you_can_add_remove") echo "Now you can add/remove needed ports and addresses using options 2 and 3." ;;
            "firewall_management_main_menu") echo "────── Firewall Management Main Menu ──────" ;;
            "enable_and_prepare_option") echo "Enable and prepare (ufw, iptables)" ;;
            "port_management_option") echo "Port management" ;;
            "ip_management_option") echo "IP address management" ;;
            "view_all_rules_option") echo "View all rules" ;;
            "reset_all_rules_option") echo "Reset all rules and restart Docker" ;;
            "exit_option") echo "Exit" ;;
            "exiting_firewall_menu") echo "Exiting firewall menu" ;;
            "configuring_docker_resources") echo "🔧 Configuring Docker container resources based on system specifications..." ;;
            "system_info") echo "📊 System Information:" ;;
            "calculated_resources") echo "📈 Calculated Resource Allocation:" ;;
            "resource_config_saved") echo "✅ Resource configuration saved to" ;;
            "resource_config_loaded") echo "✅ Resource configuration loaded from" ;;
            "using_default_resources") echo "ℹ️ Using default resource configuration" ;;
            "execution_rpc_error") echo "❌ Failed to get response from execution client RPC" ;;
            "execution_rpc_error_with_details") echo "❌ Execution client RPC error: %s" ;;
            "execution_no_result") echo "❌ Invalid response from execution client - no result field" ;;
            "consensus_rpc_error") echo "❌ Failed to get response from consensus client RPC" ;;
            "consensus_rpc_error_with_details") echo "❌ Consensus client RPC error: %s" ;;
            "consensus_no_data") echo "❌ Invalid response from consensus client - no data field" ;;
            "resource_limits_prompt") echo "🔧 Resource Limits Configuration" ;;
            "resource_limits_description") echo "The script has calculated optimal resource limits for your containers based on your system specifications." ;;
            "resource_limits_warning") echo "⚠️  Applying resource limits may affect performance but ensures system stability." ;;
            "apply_resource_limits_question") echo "Do you want to apply these resource limits? (yes/no): " ;;
            "applying_resource_limits") echo "🔧 Applying resource limits..." ;;
            "resource_limits_applied") echo "✅ Resource limits have been applied successfully" ;;
            "skipping_resource_limits") echo "⏭️  Skipping resource limits..." ;;
            "resource_limits_disabled") echo "ℹ️  Resource limits are disabled - containers will use unlimited resources" ;;
            "resource_limits_enabled") echo "✅ Resource limits are enabled" ;;
            "please_enter_yes_or_no") echo "Please enter 'yes' or 'no'" ;;
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
            "menu_options") echo -e '1) Установить требования (Docker и другое ПО)\n2) Установить ноду\n3) Обновить ноду\n4) Проверить логи\n5) Проверить статус синхронизации\n6) Установить cron-агент с Тг уведомлениями\n7) Удалить cron-агент\n8) Остановить контейнеры\n9) Запустить контейнеры\n\033[31m10) Удалить ноду\033[0m\n11) Изменить порты для установленной ноды\n12) Проверить занимаемое место\n13) Управление файрволлом\n14) Проверить RPC-сервер\n15) Настроить ресурсы Docker\n\033[31m0) Выйти\033[0m' ;;
            "goodbye") echo "👋 До свидания!" ;;
            "invalid_option") echo "❌ Неверный выбор, попробуйте снова." ;;
            "select_option") echo "Выберите опцию: " ;;
            "start_containers") echo "🏃‍➡️ Запуск контейнеров..." ;;
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
            "ask_custom_ports_prompt") echo "Хотите настроить пользовательские порты? (yes/no, по умолчанию: no)" ;;
            "enter_exec_rpc_port") printf "Введите RPC-порт клиента исполнения (по умолчанию: %s): " "$1" ;;
            "enter_exec_p2p_port") printf "Введите P2P-порт клиента исполнения (по умолчанию: %s): " "$1" ;;
            "enter_exec_auth_port") printf "Введите Auth RPC-порт клиента исполнения (по умолчанию: %s): " "$1" ;;
            "enter_consensus_rpc_port") printf "Введите RPC-порт клиента консенсуса (по умолчанию: %s): " "$1" ;;
            "enter_consensus_p2p_port") printf "Введите P2P-порт клиента консенсуса (по умолчанию: %s): " "$1" ;;
            "invalid_port_input") echo "❌ Неверный ввод. Порт должен быть числом от 1024 до 65535." ;;
            "ports_configured_message") printf "✅ Порты настроены. Исполнение: RPC=%s, P2P=%s, Auth=%s. Консенсус: RPC=%s, P2P=%s.\n" "$1" "$2" "$3" "$4" "$5" ;;
            "current_port_config") printf "🛈 Текущие порты \n  Исполнение: RPC=%s, P2P=%s, Auth=%s.\n  Консенсус: BEACON=%s, P2P=%s.\n" "$1" "$2" "$3" "$4" "$5" ;;
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
            "ufw_wrong_ip") echo "Неверный IP-адрес. Попробуйте снова" ;;
            # Основные сообщения
            "press_enter_to_continue") echo "Нажмите Enter для продолжения..." ;;
            "are_you_sure_prompt") echo "Вы уверены? [y/N]: " ;;
            # Новые ключи для перевода
            "checking_docker_chain_rules") echo "Проверка правил в цепочке DOCKER" ;;
            "docker_chain_available") echo "Цепочка DOCKER доступна" ;;
            "docker_chain_not_found") echo "Цепочка DOCKER не найдена" ;;
            "checking_execution_rpc_port") echo "Проверка правил для EXECUTION RPC порта" ;;
            "checking_consensus_rpc_port") echo "Проверка правил для CONSENSUS RPC порта" ;;
            "found_rule_for_port") echo "Найдено правило для порта" ;;
            "destination_ip") echo "IP назначения" ;;
            "failed_to_get_ip") echo "Не удалось определить IP назначения" ;;
            "adding_accept_rule_for_ip") echo "Добавляем разрешающее правило для IP" ;;
            "accept_rule_already_exists") echo "Разрешающее правило уже существует для IP" ;;
            "added_rules_count") echo "Добавлено всего правил для" ;;
            # Сообщения проверки цепочки DOCKER-USER
            "checking_docker_user_chain") echo "[Проверка] Ищем цепочку DOCKER-USER..." ;;
            "docker_user_chain_not_found") echo "[Ошибка] Цепочка DOCKER-USER не найдена!" ;;
            "creating_docker_user_chain") echo "Создаем новую цепочку DOCKER-USER..." ;;
            "docker_user_chain_created") echo "✅ Цепочка DOCKER-USER создана" ;;
            "added_forward_to_docker_user") echo "Добавлен переход FORWARD -> DOCKER-USER" ;;
            "docker_user_chain_available") echo "✅ Цепочка DOCKER-USER доступна" ;;
            "adding_forward_to_docker_user") echo "Добавляем переход FORWARD -> DOCKER-USER..." ;;
            "forward_to_docker_user_added") echo "✅ Переход FORWARD -> DOCKER-USER добавлен" ;;
            "forward_to_docker_user_exists") echo "✅ Переход FORWARD -> DOCKER-USER уже существует" ;;
            # Сообщения UFW
            "checking_ufw_status") echo "[Проверка] Проверяем статус UFW..." ;;
            "ufw_already_enabled") echo "✅ UFW уже включен" ;;
            "ufw_disabled_configuring") echo "[Внимание] UFW отключен, настраиваем..." ;;
            "adding_ssh_port_rule") echo "Добавляем правило для SSH (22 порт)..." ;;
            "adding_ssh_name_rule") echo "Добавляем правило для SSH (по имени ssh)..." ;;
            "adding_exec_p2p_port_rule") echo "Добавляем правила для execution и consensus P2P..." ;;
            "port_rule_exists") echo "Правило для порта уже существует" ;;
            "enabling_ufw") echo "Включаем UFW..." ;;
            "ufw_enabled_successfully") echo "✅ UFW успешно включен" ;;
            "current_ufw_status") echo "Текущий статус UFW:" ;;
            "failed_to_enable_ufw") echo "[Ошибка] Не удалось включить UFW" ;;
            # Сообщения блокировки портов
            "blocking_rpc_ports") echo "[Действие] Блокируем входящие соединения на RPC и BEACON порты" ;;
            "blocked_ports") echo "✅ Заблокированы порты:" ;;
            "ports_already_blocked") echo "⚠️ Порты уже заблокированы:" ;;
            # Сообщения добавления правил
            "adding_rule") echo "[Действие] Добавляем правило:" ;;
            "rule_added") echo "✅ Правило добавлено" ;;
            "failed_to_add_rule") echo "[Ошибка] Не удалось добавить правило!" ;;
            "rule_already_exists") echo "[Пропуск] Правило уже существует" ;;
            # Сообщения просмотра правил
            "current_port_rules") echo "── Текущие правила для портов ──" ;;
            "docker_user_port_rules") echo "Правила DOCKER-USER (порты):" ;;
            "ufw_port_rules") echo "Правила UFW (порты):" ;;
            "current_ip_rules") echo "── Текущие правила для IP ──" ;;
            "docker_user_ip_rules") echo "Правила DOCKER-USER (IP):" ;;
            "ufw_ip_rules") echo "Правила UFW (IP):" ;;
            # Меню управления портами
            "port_management_menu") echo "────── Управление портами ──────" ;;
            "open_port_option") echo "Открыть порт (добавить правило)" ;;
            "close_port_option") echo "Закрыть порт (удалить правило по номеру)" ;;
            "block_rpc_ports_option") echo "Блокировать RPC и BEACON порты" ;;
            "return_to_main_menu") echo "Вернуться в главное меню" ;;
            # Сообщения открытия портов
            "opening_port") echo "── Открытие порта ──" ;;
            "enter_port_number_prompt") echo "Введите номер порта (например, 8080 или 8545,5052,9000): " ;;
            "select_direction") echo "Выберите направление:" ;;
            "incoming_connections") echo "Входящие соединения (--dport)" ;;
            "outgoing_connections") echo "Исходящие соединения (--sport)" ;;
            "all_directions") echo "Все направления" ;;
            "select_direction_prompt") echo "Выберите направление: " ;;
            "select_protocol") echo "Выберите протокол:" ;;
            "all_protocols") echo "Все протоколы" ;;
            "select_protocol_prompt") echo "Выберите протокол: " ;;
            "adding_iptables_rule") echo "Добавляем iptables правило: порт" ;;
            "adding_ufw_rule") echo "Добавляем UFW правило: порт" ;;
            "in_and_out") echo "входящие и исходящие" ;;
            "direction") echo "направление" ;;
            "protocol") echo "протокол" ;;
            "invalid_input_error") echo "Ошибка: некорректный ввод" ;;
            # Сообщения удаления правил
            "deleting_rules") echo "────── Удаление правил ──────" ;;
            "select_rule_type_to_delete") echo "Выберите тип правил для удаления:" ;;
            "delete_iptables_rule") echo "Удалить правило iptables" ;;
            "delete_ufw_rule") echo "Удалить правило UFW" ;;
            "delete_both_rules") echo "Удалить оба (iptab..." ;;
            "enter_iptables_rule_numbers") echo "Введите номера правил iptables (например, 1 или 1,2 или 1,5-8,12):" ;;
            "enter_ufw_rule_numbers") echo "Введите номера правил UFW (например, 1 или 1,2 или 1,5-8,12):" ;;
            "rule_numbers_to_delete_prompt") echo "Номера правил для удаления: " ;;
            "iptables_rule_numbers_prompt") echo "номера правил iptables для удаления: " ;;
            "ufw_rule_numbers_prompt") echo "номера правил UFW для удаления: " ;;
            "deleting_iptables_rule") echo "Удаляем правило iptables" ;;
            "deleting_ufw_rule") echo "Удаляем правило UFW" ;;
            "rule_not_found_skipping") echo "Правило не найдено, пропускаем" ;;
            "invalid_rule_number_skipping") echo "Некорректный номер правила, пропускаем" ;;
            "failed_to_delete_rule") echo "Не удалось удалить правило" ;;
            "deleted_iptables_rules") echo "Удалено iptables правил:" ;;
            "deleted_ufw_rules") echo "Удалено UFW правил:" ;;
            "invalid_choice_cancel") echo "Некорректный выбор, удаление отменено" ;;
            "invalid_range_skipping") echo "Некорректный диапазон, пропускаем" ;;
            # Блокировка RPC портов
            "blocking_rpc_ports_for_all") echo "── Блокировка RPC и BEACON портов для всех входящих соединений ──" ;;
            "changing_ufw_policy_to_block_all") echo "Изменяем политику UFW на блокировку всех входящих соединений" ;;
            # Меню управления IP
            "ip_management_menu") echo "────── Управление IP-адресами ──────" ;;
            "allow_access_from_ip") echo "Разрешить доступ с IP-адреса" ;;
            "deny_access_delete_rule") echo "Запретить доступ (удалить правило)" ;;
            # Сообщения управления IP
            "allowing_access_from_ip") echo "── Разрешение доступа с IP ──" ;;
            "enter_ip_or_subnet_prompt") echo "Введите IP-адрес или подсеть (например, 192.168.1.1 или 192.168.1.0/24 или несколько адресов через запятую): " ;;
            "enter_port_number_optional_prompt") echo "Введите номер порта (5052 или 5052,9100 или оставьте пустым для всех портов): " ;;
            "adding_iptables_rule_for_all_traffic_from") echo "Добавляем iptables правило для всего трафика с" ;;
            "adding_ufw_rule_for_all_traffic_from") echo "Добавляем UFW правило для всего трафика с" ;;
            "adding_iptables_rule_for_port") echo "Добавляем iptables правило для порта" ;;
            "from") echo "с" ;;
            "adding_ufw_rule_for_port") echo "[Действие] Добавляем UFW правило для порта" ;;
            "port_must_be_number_error") echo "Ошибка: порт должен быть числом" ;;
            "correct_input_examples") echo "Примеры корректного ввода:" ;;
            "ip_example") echo "IP: 192.168.1.1 или 10.0.0.0/24" ;;
            # Просмотр всех правил
            "view_all_rules") echo "────── Просмотр всех правил ──────" ;;
            "current_docker_user_chain_rules") echo "Текущие правила цепочки DOCKER-USER:" ;;
            "no_rules_in_docker_user_chain") echo "Нет правил в цепочке DOCKER-USER" ;;
            "current_ufw_rules") echo "Текущие правила UFW:" ;;
            "no_active_ufw_rules") echo "Нет активных правил UFW" ;;
            "iptables_rules_stats") echo "Статистика правил iptables:" ;;
            "total_accept_rules") echo "Всего ACCEPT правил:" ;;
            "total_drop_reject_rules") echo "Всего DROP/REJECT правил:" ;;
            "ufw_rules_stats") echo "Статистика правил UFW:" ;;
            "default_policy") echo "Политика по умолчанию:" ;;
            "incoming") echo "Входящие:" ;;
            "outgoing") echo "Исходящие:" ;;
            "total_allow_rules") echo "Всего ALLOW правил:" ;;
            "total_deny_reject_rules") echo "Всего DENY/REJECT правил:" ;;
            # Сброс правил
            "reset_all_rules") echo "────── Сброс всех правил ──────" ;;
            "you_are_about_to_perform") echo "Вы собираетесь выполнить следующие действия:" ;;
            "clear_all_rules_in_docker_user_chain") echo "Очистить все правила в цепочке DOCKER-USER" ;;
            "reset_all_ufw_rules") echo "Сбросить все правила UFW" ;;
            "restart_docker_service") echo "Перезапустить сервис Docker" ;;
            "clearing_docker_user_chain") echo "Очистка цепочки DOCKER-USER" ;;
            "all_docker_user_rules_deleted") echo "✅ Все правила DOCKER-USER удалены" ;;
            "failed_to_clear_docker_user") echo "[Ошибка] Не удалось очистить DOCKER-USER" ;;
            "resetting_ufw_rules") echo "Сброс правил UFW" ;;
            "all_ufw_rules_reset") echo "✅ Все правила UFW сброшены" ;;
            "failed_to_reset_ufw") echo "[Ошибка] Не удалось сбросить UFW" ;;
            "restarting_docker") echo "Перезапуск Docker" ;;
            "docker_restarted_successfully") echo "✅ Docker успешно перезапущен" ;;
            "current_docker_user_status") echo "Текущий статус DOCKER-USER:" ;;
            "failed_to_restart_docker") echo "[Ошибка] Не удалось перезапустить Docker" ;;
            "rules_reset_cancelled") echo "Сброс правил отменен" ;;
            # Главное меню
            "script_works_in_iptables") echo "Скрипт работает с iptables используя цепочку DOCKER-USER и дублирует правила для ufw." ;;
            "port_ip_management_logic") echo "Логика управления портами/IP основана на добавлении/удалении разрешающих правил." ;;
            "on_first_run") echo "Перед работой с функцией запустите установку ноды Sepolia. При первом запуске:" ;;
            "first_run_option_1") echo "Сначала опция 1. Подтвердите активацию ufw и настройку iptables;" ;;
            "first_run_option_2") echo "Затем с помощью опции 2 (пункт 1 внутри опции) откройте необходимые порты для работы вашей ноды. Например для Aztec: 8080,40400" ;;
            "first_run_option_3") echo "Наконец с помощью опции 2 (пункт 3 внутри опции) заблокируйте RPC и BEACON порты для входящих соединений." ;;
            "now_you_can_add_remove") echo "Теперь вы можете добавлять/удалять необходимые порты и адреса с помощью опций 2 и 3." ;;
            "firewall_management_main_menu") echo "────── Главное меню управления файрволлом ──────" ;;
            "enable_and_prepare_option") echo "Включить и подготовить (ufw, iptables)" ;;
            "port_management_option") echo "Управление портами" ;;
            "ip_management_option") echo "Управление IP-адресами" ;;
            "view_all_rules_option") echo "Просмотр всех правил" ;;
            "reset_all_rules_option") echo "Сброс всех правил и перезапуск Docker" ;;
            "exit_option") echo "Выход" ;;
            "exiting_firewall_menu") echo "Выход из меню файрволла" ;;
            "configuring_docker_resources") echo "🔧 Настройка ресурсов контейнеров Docker на основе спецификаций системы..." ;;
            "system_info") echo "📊 Информация о системе:" ;;
            "calculated_resources") echo "📈 Рассчитанное распределение ресурсов:" ;;
            "resource_config_saved") echo "✅ Конфигурация ресурсов сохранена в" ;;
            "resource_config_loaded") echo "✅ Конфигурация ресурсов загружена из" ;;
            "using_default_resources") echo "ℹ️ Используется конфигурация ресурсов по умолчанию" ;;
            "execution_rpc_error") echo "❌ Не удалось получить ответ от RPC клиента исполнения" ;;
            "execution_rpc_error_with_details") echo "❌ Ошибка RPC клиента исполнения: %s" ;;
            "execution_no_result") echo "❌ Недействительный ответ от клиента исполнения - нет поля result" ;;
            "consensus_rpc_error") echo "❌ Не удалось получить ответ от RPC клиента консенсуса" ;;
            "consensus_rpc_error_with_details") echo "❌ Ошибка RPC клиента консенсуса: %s" ;;
            "consensus_no_data") echo "❌ Недействительный ответ от клиента консенсуса - нет поля data" ;;
            "resource_limits_prompt") echo "🔧 Настройка ограничений ресурсов" ;;
            "resource_limits_description") echo "Скрипт рассчитал оптимальные ограничения ресурсов для ваших контейнеров на основе спецификаций системы." ;;
            "resource_limits_warning") echo "⚠️  Применение ограничений ресурсов может повлиять на производительность, но обеспечивает стабильность системы." ;;
            "apply_resource_limits_question") echo "Хотите применить эти ограничения ресурсов? (yes/no): " ;;
            "applying_resource_limits") echo "🔧 Применение ограничений ресурсов..." ;;
            "resource_limits_applied") echo "✅ Ограничения ресурсов успешно применены" ;;
            "skipping_resource_limits") echo "⏭️  Пропуск ограничений ресурсов..." ;;
            "resource_limits_disabled") echo "ℹ️  Ограничения ресурсов отключены - контейнеры будут использовать неограниченные ресурсы" ;;
            "resource_limits_enabled") echo "✅ Ограничения ресурсов включены" ;;
            "please_enter_yes_or_no") echo "Пожалуйста, введите 'yes' или 'no'" ;;
            *) echo "$key" ;;
        esac
    fi
}

# Define print functions for consistency
function print_info {
    echo -e "${BLUE}$1${RESET}"
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

# Constants
NODE_DIR="$HOME/sepolia_node"
DOCKER_COMPOSE_FILE="$NODE_DIR/docker-compose.yml"
JWT_FILE="$NODE_DIR/jwt.hex"
CLIENT_FILE="$NODE_DIR/consensus_client.txt"
EXECUTION_CLIENT_FILE="$NODE_DIR/execution_client.txt"
PORT_CONFIG_FILE="$NODE_DIR/port_config.txt"
RESOURCE_CONFIG_FILE="$NODE_DIR/resource_config.txt"
AGENT_SCRIPT="$NODE_DIR/agent.sh"

# Check for updates
function check_version {
    local remote_version=$(curl -s https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/install_sepolia.sh | grep '^SCRIPT_VERSION=' | cut -d '"' -f2)
    if [[ "$remote_version" != "$SCRIPT_VERSION" ]]; then
        print_info "\n$(t "current_script_version") $SCRIPT_VERSION"
        print_warning "$(t "new_version_avialable") $remote_version"
        print_warning "$(t "new_version_update")"
    else
        print_success "$(t "version_up_to_date")"
    fi
}

# Install base requirements
function install_requirements {
    print_info "$(t "update_base")"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y curl jq cron
    print_success "$(t "autoremove_clean")"
    sudo apt autoremove -y
    sudo apt autoclean -y
    install_docker
}

# Install Docker
function install_docker {
    if ! command -v docker &> /dev/null; then
        print_info "$(t "install_docker")"
        sudo apt update
        sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io -y
        sudo usermod -aG docker $USER
    else
        print_success "$(t "docker_exists")"
    fi
    install_docker_compose
}

# Install Docker Compose
function install_docker_compose {
    if ! command -v docker compose &> /dev/null; then
        print_info "$(t "install_compose")"
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker compose
    else
        print_success "$(t "compose_exists")"
    fi
    print_success "$(t "requirements_done")"
}

# Load port configuration if exists
function load_port_configuration {
    print_info "$(t "loading_port_config")"
    if [ -f "$PORT_CONFIG_FILE" ]; then
        source "$PORT_CONFIG_FILE"
        print_success "$(t "loaded_port_config_from_file" "$PORT_CONFIG_FILE")"
    else
        print_info "$(t "port_config_not_found" "$PORT_CONFIG_FILE")"
    fi
}

# Load resource configuration if exists
function load_resource_configuration {
    print_info "$(t "loading_resource_config")" # Assuming a translation key for this
    if [ -f "$RESOURCE_CONFIG_FILE" ]; then
        source "$RESOURCE_CONFIG_FILE"
        print_success "$(t "resource_config_loaded" "$RESOURCE_CONFIG_FILE")"
    else
        print_info "$(t "using_default_resources")"
        RESOURCE_LIMITS_ENABLED="no"
    fi
}

# Prompt for custom ports
function ask_for_custom_ports {
    read -p "$(t "ask_custom_ports_prompt") " use_custom_ports
    use_custom_ports=${use_custom_ports:-no}
    if [[ "$use_custom_ports" == "yes" ]]; then
        while true; do
            read -p "$(t "enter_exec_rpc_port" "$EXECUTION_RPC_PORT_DEFAULT")" EXECUTION_RPC_PORT
            EXECUTION_RPC_PORT=${EXECUTION_RPC_PORT:-$EXECUTION_RPC_PORT_DEFAULT}
            if [[ $EXECUTION_RPC_PORT =~ ^[0-9]+$ ]] && (( EXECUTION_RPC_PORT >= 1024 && EXECUTION_RPC_PORT <= 65535 )); then
                break
            else
                print_error "$(t "invalid_port_input")"
            fi
        done
        while true; do
            read -p "$(t "enter_exec_p2p_port" "$EXECUTION_P2P_PORT_DEFAULT")" EXECUTION_P2P_PORT
            EXECUTION_P2P_PORT=${EXECUTION_P2P_PORT:-$EXECUTION_P2P_PORT_DEFAULT}
            if [[ $EXECUTION_P2P_PORT =~ ^[0-9]+$ ]] && (( EXECUTION_P2P_PORT >= 1024 && EXECUTION_P2P_PORT <= 65535 )); then
                break
            else
                print_error "$(t "invalid_port_input")"
            fi
        done
        while true; do
            read -p "$(t "enter_exec_auth_port" "$EXECUTION_AUTH_RPC_PORT_DEFAULT")" EXECUTION_AUTH_RPC_PORT
            EXECUTION_AUTH_RPC_PORT=${EXECUTION_AUTH_RPC_PORT:-$EXECUTION_AUTH_RPC_PORT_DEFAULT}
            if [[ $EXECUTION_AUTH_RPC_PORT =~ ^[0-9]+$ ]] && (( EXECUTION_AUTH_RPC_PORT >= 1024 && EXECUTION_AUTH_RPC_PORT <= 65535 )); then
                break
            else
                print_error "$(t "invalid_port_input")"
            fi
        done
        while true; do
            read -p "$(t "enter_consensus_rpc_port" "$CONSENSUS_RPC_PORT_DEFAULT")" CONSENSUS_RPC_PORT
            CONSENSUS_RPC_PORT=${CONSENSUS_RPC_PORT:-$CONSENSUS_RPC_PORT_DEFAULT}
            if [[ $CONSENSUS_RPC_PORT =~ ^[0-9]+$ ]] && (( CONSENSUS_RPC_PORT >= 1024 && CONSENSUS_RPC_PORT <= 65535 )); then
                break
            else
                print_error "$(t "invalid_port_input")"
            fi
        done
        while true; do
            read -p "$(t "enter_consensus_p2p_port" "$CONSENSUS_P2P_PORT_DEFAULT")" CONSENSUS_P2P_PORT
            CONSENSUS_P2P_PORT=${CONSENSUS_P2P_PORT:-$CONSENSUS_P2P_PORT_DEFAULT}
            if [[ $CONSENSUS_P2P_PORT =~ ^[0-9]+$ ]] && (( CONSENSUS_P2P_PORT >= 1024 && CONSENSUS_P2P_PORT <= 65535 )); then
                break
            else
                print_error "$(t "invalid_port_input")"
            fi
        done
        print_success "$(t "ports_configured_message" "$EXECUTION_RPC_PORT" "$EXECUTION_P2P_PORT" "$EXECUTION_AUTH_RPC_PORT" "$CONSENSUS_RPC_PORT" "$CONSENSUS_P2P_PORT")"
        save_port_configuration
    else
        EXECUTION_RPC_PORT=$EXECUTION_RPC_PORT_DEFAULT
        EXECUTION_P2P_PORT=$EXECUTION_P2P_PORT_DEFAULT
        EXECUTION_AUTH_RPC_PORT=$EXECUTION_AUTH_RPC_PORT_DEFAULT
        CONSENSUS_RPC_PORT=$CONSENSUS_RPC_PORT_DEFAULT
        CONSENSUS_P2P_PORT=$CONSENSUS_P2P_PORT_DEFAULT
    fi
    print_info "$(t "current_port_config" "$EXECUTION_RPC_PORT" "$EXECUTION_P2P_PORT" "$EXECUTION_AUTH_RPC_PORT" "$CONSENSUS_RPC_PORT" "$CONSENSUS_P2P_PORT")"
}

# Save port configuration to file
function save_port_configuration {
    print_info "$(t "saving_port_config")"
    cat <<EOF > "$PORT_CONFIG_FILE"
EXECUTION_RPC_PORT=$EXECUTION_RPC_PORT
EXECUTION_P2P_PORT=$EXECUTION_P2P_PORT
EXECUTION_AUTH_RPC_PORT=$EXECUTION_AUTH_RPC_PORT
CONSENSUS_RPC_PORT=$CONSENSUS_RPC_PORT
CONSENSUS_P2P_PORT=$CONSENSUS_P2P_PORT
EOF
    print_success "$(t "port_config_saved" "$PORT_CONFIG_FILE")"
}

# Generate JWT
function generate_jwt {
    print_info "$(t "jwt_gen")"
    openssl rand -hex 32 | tr -d "\n" > "$JWT_FILE"
}

# Choose execution client
function choose_execution_client {
    print_info "$(t "choose_execution_client_prompt")"
    select exec_client in "$(t "client_label_geth")" "$(t "client_label_reth")" "$(t "client_label_nethermind")"; do
        case $exec_client in
            "$(t "client_label_geth")")
                execution_client="geth"
                break
                ;;
            "$(t "client_label_reth")")
                execution_client="reth"
                break
                ;;
            "$(t "client_label_nethermind")")
                execution_client="nethermind"
                break
                ;;
            *)
                print_error "$(t "invalid_choice")"
                ;;
        esac
    done
    print_success "$(t "execution_client_selected" "$exec_client")"
    execution_client_name=$exec_client
    execution_client_display_name=$exec_client
}

# Choose consensus client
function choose_consensus_client {
    print_info "$(t "choose_client")"
    select client in "$(t "client_label_prysm")" "$(t "client_label_teku")" "$(t "client_label_lighthouse")"; do
        case $client in
            "$(t "client_label_prysm")")
                consensus_client="prysm"
                break
                ;;
            "$(t "client_label_teku")")
                consensus_client="teku"
                break
                ;;
            "$(t "client_label_lighthouse")")
                consensus_client="lighthouse"
                break
                ;;
            *)
                print_error "$(t "invalid_choice")"
                ;;
        esac
    done
    print_success "$(t "client_selected" "$consensus_client")"
    consensus_client_name=$consensus_client
    consensus_client_display_name=$consensus_client
}

# Create docker-compose.yml
function create_docker_compose {
    print_info "$(t "creating_compose" "$consensus_client")"
    mkdir -p "$NODE_DIR"
    case $execution_client_name in
        "geth")
            execution_section="
  execution:
    image: ethereum/client-go:latest
    container_name: geth
    restart: always
    ports:
      - $EXECUTION_RPC_PORT:$EXECUTION_RPC_PORT
      - $EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/tcp
      - $EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/udp
    volumes:
      - ./data/geth:/data
    command: >
      --sepolia
      --datadir /data
      --http
      --http.addr 0.0.0.0
      --http.port $EXECUTION_RPC_PORT
      --http.vhosts '*'
      --http.api eth,net,web3,txpool,engine
      --authrpc.addr 0.0.0.0
      --authrpc.port $EXECUTION_AUTH_RPC_PORT
      --authrpc.vhosts '*'
      --authrpc.jwtsecret /data/jwt.hex
      --syncmode full
      --port $EXECUTION_P2P_PORT
    networks:
      - sepolia-net
"
            ;;
        "reth")
            execution_section="
  execution:
    image: ghcr.io/paradigmxyz/reth:latest
    container_name: reth
    restart: always
    ports:
      - $EXECUTION_RPC_PORT:$EXECUTION_RPC_PORT
      - $EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/tcp
      - $EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/udp
    volumes:
      - ./data/reth:/data
    command: >
      node
      --chain sepolia
      --datadir /data
      --http
      --http.addr 0.0.0.0
      --http.port $EXECUTION_RPC_PORT
      --http.api eth,net,web3,txpool,engine,reth
      --authrpc.addr 0.0.0.0
      --authrpc.port $EXECUTION_AUTH_RPC_PORT
      --authrpc.jwtsecret /data/jwt.hex
      --port $EXECUTION_P2P_PORT
    networks:
      - sepolia-net
"
            ;;
        "nethermind")
            execution_section="
  execution:
    image: nethermind/nethermind:latest
    container_name: nethermind
    restart: always
    ports:
      - $EXECUTION_RPC_PORT:$EXECUTION_RPC_PORT
      - $EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/tcp
      - $EXECUTION_P2P_PORT:$EXECUTION_P2P_PORT/udp
    volumes:
      - ./data/nethermind:/data
    environment:
      - NETHERMIND_CONFIG=sepolia
    command: >
      --datadir /data
      --JsonRpc.Enabled=true
      --JsonRpc.Host=0.0.0.0
      --JsonRpc.Port=$EXECUTION_RPC_PORT
      --JsonRpc.EngineHost=0.0.0.0
      --JsonRpc.EnginePort=$EXECUTION_AUTH_RPC_PORT
      --JsonRpc.JwtSecretFile=/data/jwt.hex
      --Network.DiscoveryPort=$EXECUTION_P2P_PORT
      --Network.P2PPort=$EXECUTION_P2P_PORT
    networks:
      - sepolia-net
"
            ;;
        *)
            print_error "$(t "unknown_execution_client" "$execution_client_name")"
            return 1
            ;;
    esac
    case $consensus_client_name in
        "prysm")
            consensus_section="
  consensus:
    image: gcr.io/prysmaticlabs/prysm/beacon-chain:latest
    container_name: prysm
    restart: always
    ports:
      - $CONSENSUS_RPC_PORT:$CONSENSUS_RPC_PORT
      - $CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/tcp
      - $CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/udp
    volumes:
      - ./data/prysm:/data
    command: >
      --sepolia
      --datadir=/data
      --rpc-host=0.0.0.0
      --rpc-port=$CONSENSUS_RPC_PORT
      --grpc-gateway-host=0.0.0.0
      --grpc-gateway-port=$CONSENSUS_RPC_PORT
      --p2p-tcp-port=$CONSENSUS_P2P_PORT
      --p2p-udp-port=$CONSENSUS_P2P_PORT
      --execution-endpoint=http://execution:$EXECUTION_AUTH_RPC_PORT
      --jwt-secret=/data/jwt.hex
    networks:
      - sepolia-net
"
            ;;
        "teku")
            consensus_section="
  consensus:
    image: consensys/teku:latest
    container_name: teku
    restart: always
    ports:
      - $CONSENSUS_RPC_PORT:$CONSENSUS_RPC_PORT
      - $CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/tcp
      - $CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/udp
    volumes:
      - ./data/teku:/data
    command: >
      --network=sepolia
      --data-path=/data
      --rest-api-enabled=true
      --rest-api-host-allowlist=*
      --rest-api-port=$CONSENSUS_RPC_PORT
      --p2p-port=$CONSENSUS_P2P_PORT
      --ee-endpoint=http://execution:$EXECUTION_AUTH_RPC_PORT
      --ee-jwt-secret-file=/data/jwt.hex
    networks:
      - sepolia-net
"
            ;;
        "lighthouse")
            consensus_section="
  consensus:
    image: sigp/lighthouse:latest
    container_name: lighthouse
    restart: always
    ports:
      - $CONSENSUS_RPC_PORT:$CONSENSUS_RPC_PORT
      - $CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/tcp
      - $CONSENSUS_P2P_PORT:$CONSENSUS_P2P_PORT/udp
    volumes:
      - ./data/lighthouse:/root/.lighthouse
    command: >
      lighthouse bn
      --network sepolia
      --datadir /root/.lighthouse
      --http
      --http-address 0.0.0.0
      --http-port $CONSENSUS_RPC_PORT
      --port $CONSENSUS_P2P_PORT
      --execution-endpoint http://execution:$EXECUTION_AUTH_RPC_PORT
      --execution-jwt /root/.lighthouse/jwt.hex
    networks:
      - sepolia-net
"
            ;;
        *)
            print_error "$(t "unknown_client" "$consensus_client_name")"
            return 1
            ;;
    esac
    cat <<EOF > "$DOCKER_COMPOSE_FILE"
version: '3.8'
services:
$execution_section
$consensus_section
networks:
  sepolia-net:
    driver: bridge
EOF
    # Add resource limits if enabled
    if [[ "$RESOURCE_LIMITS_ENABLED" == "yes" ]]; then
        yml_content=$(cat "$DOCKER_COMPOSE_FILE")
        # For execution client
        yml_content=$(echo "$yml_content" | awk -v cpus="$EXECUTION_CPUS" -v mem="$EXECUTION_MEMORY" '
            /container_name: '"$execution_client_name"'/ {
                print
                print "    deploy:"
                print "      resources:"
                print "        limits:"
                print "          cpus: \x27" cpus "\x27"
                print "          memory: " mem
                next
            }
            1' )
        # For consensus client
        yml_content=$(echo "$yml_content" | awk -v cpus="$CONSENSUS_CPUS" -v mem="$CONSENSUS_MEMORY" '
            /container_name: '"$consensus_client_name"'/ {
                print
                print "    deploy:"
                print "      resources:"
                print "        limits:"
                print "          cpus: \x27" cpus "\x27"
                print "          memory: " mem
                next
            }
            1' )
        echo "$yml_content" > "$DOCKER_COMPOSE_FILE"
    fi
}

# Configure Docker resources
function configure_docker_resources {
    print_info "$(t "configuring_docker_resources")"

    # Get system specs
    total_cpus=$(nproc)
    total_memory_kb=$(free -k | awk '/^Mem:/ {print $2}')
    total_memory_gb=$(awk "BEGIN {print $total_memory_kb / 1024 / 1024}")

    print_info "$(t "system_info")"
    echo "  CPUs: $total_cpus"
    echo "  Memory: ${total_memory_gb} GB"

    # Calculate optimal limits
    EXECUTION_CPUS=$(awk "BEGIN {print $total_cpus * 0.6}")
    CONSENSUS_CPUS=$(awk "BEGIN {print $total_cpus * 0.4}")
    EXECUTION_MEMORY=$(awk "BEGIN {print int($total_memory_gb * 0.6)}G")
    CONSENSUS_MEMORY=$(awk "BEGIN {print int($total_memory_gb * 0.4)}G")

    print_info "$(t "calculated_resources")"
    echo "  Execution: CPUs=$EXECUTION_CPUS, Memory=$EXECUTION_MEMORY"
    echo "  Consensus: CPUs=$CONSENSUS_CPUS, Memory=$CONSENSUS_MEMORY"

    print_info "$(t "resource_limits_prompt")"
    print_info "$(t "resource_limits_description")"
    print_warning "$(t "resource_limits_warning")"

    while true; do
        read -p "$(t "apply_resource_limits_question")" apply_limits
        if [[ "$apply_limits" == "yes" ]]; then
            RESOURCE_LIMITS_ENABLED="yes"
            print_info "$(t "applying_resource_limits")"
            save_resource_configuration
            print_success "$(t "resource_limits_applied")"
            break
        elif [[ "$apply_limits" == "no" ]]; then
            RESOURCE_LIMITS_ENABLED="no"
            print_info "$(t "skipping_resource_limits")"
            save_resource_configuration
            print_info "$(t "resource_limits_disabled")"
            break
        else
            print_warning "$(t "please_enter_yes_or_no")"
        fi
    done
}

# Save resource configuration to file
function save_resource_configuration {
    cat <<EOF > "$RESOURCE_CONFIG_FILE"
RESOURCE_LIMITS_ENABLED=$RESOURCE_LIMITS_ENABLED
EXECUTION_CPUS=$EXECUTION_CPUS
EXECUTION_MEMORY=$EXECUTION_MEMORY
CONSENSUS_CPUS=$CONSENSUS_CPUS
CONSENSUS_MEMORY=$CONSENSUS_MEMORY
EOF
    print_success "$(t "resource_config_saved" "$RESOURCE_CONFIG_FILE")"
}

# Install node
function install_node {
    choose_execution_client
    choose_consensus_client
    ask_for_custom_ports
    configure_docker_resources
    generate_jwt
    create_docker_compose
    echo "$execution_client_name" > "$EXECUTION_CLIENT_FILE"
    echo "$consensus_client_name" > "$CLIENT_FILE"
    start_containers
    print_success "$(t "node_installed")"
}

# View logs
function view_logs {
    while true; do
        print_info "$(t "select_logs")"
        echo "1) Execution ($execution_client_name)"
        echo "2) Consensus ($consensus_client_name)"
        echo "0) $(t "back")"
        read -p "$(t "select_option")" log_choice
        case $log_choice in
            1) docker logs -f $execution_client_name ;;
            2) docker logs -f $consensus_client_name ;;
            0) break ;;
            *) print_error "$(t "invalid_option")" ;;
        esac
    done
}

# Check synchronization
function check_sync {
    print_info "$(t "check_sync")"
    # Load execution client name if not already loaded
    if [ -z "$execution_client_name" ]; then
        execution_client_name=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
    fi
    # Load consensus client name if not already loaded
    if [ -z "$consensus_client_name" ]; then
        consensus_client_name=$(cat "$CLIENT_FILE" 2>/dev/null)
    fi
    # Execution client sync check
    print_info "$(t "execution" "$execution_client_name")"
    case $execution_client_name in
        "geth")
            response=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://localhost:$EXECUTION_RPC_PORT)
            if echo "$response" | grep -q '"result":false'; then
                print_success "$(t "execution_synced" "$execution_client_name")"
            else
                current_block=$(echo "$response" | jq -r '.result.currentBlock' | tr -d '"')
                highest_block=$(echo "$response" | jq -r '.result.highestBlock' | tr -d '"')
                current_block_dec=$(( $current_block ))
                highest_block_dec=$(( $highest_block ))
                blocks_left=$((highest_block_dec - current_block_dec))
                progress=$(( (current_block_dec * 100) / highest_block_dec ))
                print_warning "$(t "execution_syncing" "$execution_client_name")"
                print_info "$(t "current_block" "$current_block_dec")"
                print_info "$(t "target_block" "$highest_block_dec")"
                print_info "$(t "blocks_left" "$blocks_left")"
                print_info "$(t "progress" "$progress")"
            fi
            ;;
        "reth")
            syncing_response=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://localhost:$EXECUTION_RPC_PORT)
            if echo "$syncing_response" | grep -q '"result":false'; then
                print_success "$(t "reth_synced_fully")"
            else
                print_warning "$(t "execution_syncing" "$execution_client_name")"
                # Get sync stage details
                stage_response=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"reth_syncing","params":[],"id":1}' http://localhost:$EXECUTION_RPC_PORT)
                if [ -n "$stage_response" ]; then
                    print_info "$(t "reth_sync_details_title")"
                    stages=$(echo "$stage_response" | jq -r '.result.stages | keys[]')
                    for stage in $stages; do
                        current_progress=$(echo "$stage_response" | jq -r ".result.stages.$stage.current")
                        done_progress=$(echo "$stage_response" | jq -r ".result.stages.$stage.done")
                        total_progress=$(echo "$stage_response" | jq -r ".result.stages.$stage.total")
                        if [ "$done_progress" != "null" ] && [ "$total_progress" != "null" ]; then
                            percentage=$(awk "BEGIN {print ($done_progress / $total_progress) * 100}")
                            print_info "$(t "reth_stage_progress" "$stage" "$done_progress" "$total_progress" "$percentage")"
                        else
                            print_info "$(t "reth_no_stages")"
                        fi
                    done
                    headers_target=$(echo "$stage_response" | jq -r '.result.chain_head_target.headers')
                    if [ "$headers_target" != "null" ]; then
                        print_info "$(t "reth_headers_target" "$headers_target")"
                    fi
                else
                    print_warning "$(t "reth_no_stages")"
                fi
            fi
            ;;
        "nethermind")
            syncing_response=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://localhost:$EXECUTION_RPC_PORT)
            if echo "$syncing_response" | grep -q '"result":false'; then
                print_success "$(t "nethermind_synced_fully")"
            else
                if [ -n "$syncing_response" ] && echo "$syncing_response" | grep -q '"result":'; then
                    print_warning "$(t "execution_syncing" "$execution_client_name")"
                    current_block=$(echo "$syncing_response" | jq -r '.result.currentBlock' | tr -d '"')
                    highest_block=$(echo "$syncing_response" | jq -r '.result.highestBlock' | tr -d '"')
                    current_block_dec=$(( $current_block ))
                    highest_block_dec=$(( $highest_block ))
                    blocks_left=$((highest_block_dec - current_block_dec))
                    progress=$(( (current_block_dec * 100) / highest_block_dec ))
                    print_info "$(t "nethermind_block_progress_title")"
                    print_info "$(t "current_block" "$current_block_dec")"
                    print_info "$(t "target_block" "$highest_block_dec")"
                    print_info "$(t "blocks_left" "$blocks_left")"
                    print_info "$(t "progress" "$progress")"
                else
                    print_warning "$(t "nethermind_sync_data_missing")"
                fi
            fi
            # Get current sync stage
            stage_response=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"nethermind_sync_stage","params":[],"id":1}' http://localhost:$EXECUTION_RPC_PORT)
            if [ -n "$stage_response" ]; then
                current_stage=$(echo "$stage_response" | jq -r '.result' | tr -d '"')
                print_info "$(t "nethermind_sync_stage_title")"
                print_info "$(t "nethermind_current_stage" "$current_stage")"
            else
                print_warning "$(t "nethermind_rpc_error" "nethermind_sync_stage")"
            fi
            # Get health status
            health_response=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"nethermind_health","params":[],"id":1}' http://localhost:$EXECUTION_RPC_PORT)
            if [ -n "$health_response" ]; then
                status=$(echo "$health_response" | jq -r '.result.status' | tr -d '"')
                details=$(echo "$health_response" | jq -r '.result.details' | tr -d '"')
                print_info "$(t "nethermind_health_status_title")"
                print_info "$(t "nethermind_health_info" "$status" "$details")"
            else
                print_warning "$(t "nethermind_health_request_failed")"
            fi
            ;;
    esac
    # Consensus client sync check
    print_info "$(t "consensus" "$consensus_client_name")"
    case $consensus_client_name in
        "prysm")
            response=$(curl -s http://localhost:$CONSENSUS_RPC_PORT/eth/v1/node/syncing)
            if [ -n "$response" ]; then
                is_syncing=$(echo "$response" | jq -r '.data.is_syncing')
                head_slot=$(echo "$response" | jq -r '.data.head_slot')
                sync_distance=$(echo "$response" | jq -r '.data.sync_distance')
                if [ "$is_syncing" == "false" ]; then
                    print_success "$(t "prysm_synced")"
                else
                    print_warning "$(t "prysm_syncing")"
                    target_slot=$((head_slot + sync_distance))
                    progress=$(( (head_slot * 100) / target_slot ))
                    print_info "$(t "current_block" "$head_slot")"
                    print_info "$(t "target_block" "$target_slot")"
                    print_info "$(t "blocks_left" "$sync_distance")"
                    print_info "$(t "progress" "$progress")"
                fi
            else
                print_warning "$(t "prysm_no_sync_data")"
            fi
            ;;
        "teku")
            response=$(curl -s http://localhost:$CONSENSUS_RPC_PORT/eth/v1/node/syncing)
            if [ -n "$response" ]; then
                is_syncing=$(echo "$response" | jq -r '.data.is_syncing')
                head_slot=$(echo "$response" | jq -r '.data.head_slot')
                sync_distance=$(echo "$response" | jq -r '.data.sync_distance')
                if [ "$is_syncing" == "false" ]; then
                    print_success "$(t "teku_synced")"
                else
                    print_warning "$(t "teku_syncing")"
                    target_slot=$((head_slot + sync_distance))
                    progress=$(( (head_slot * 100) / target_slot ))
                    print_info "$(t "current_block" "$head_slot")"
                    print_info "$(t "target_block" "$target_slot")"
                    print_info "$(t "blocks_left" "$sync_distance")"
                    print_info "$(t "progress" "$progress")"
                fi
            else
                print_warning "$(t "teku_no_sync_data")"
            fi
            ;;
        "lighthouse")
            response=$(curl -s http://localhost:$CONSENSUS_RPC_PORT/eth/v1/node/syncing)
            if [ -n "$response" ]; then
                is_syncing=$(echo "$response" | jq -r '.data.is_syncing')
                head_slot=$(echo "$response" | jq -r '.data.head_slot')
                sync_distance=$(echo "$response" | jq -r '.data.sync_distance')
                if [ "$is_syncing" == "false" ]; then
                    print_success "$(t "lighthouse_synced")"
                else
                    print_warning "$(t "lighthouse_syncing")"
                    target_slot=$((head_slot + sync_distance))
                    progress=$(( (head_slot * 100) / target_slot ))
                    print_info "$(t "current_block" "$head_slot")"
                    print_info "$(t "target_block" "$target_slot")"
                    print_info "$(t "blocks_left" "$sync_distance")"
                    print_info "$(t "progress" "$progress")"
                fi
            else
                print_warning "$(t "lighthouse_no_sync_data")"
            fi
            ;;
    esac
}

# Setup cron agent with Telegram notifications
function setup_cron_agent {
    # Load client names for cron
    execution_client_name_cron=$(cat "$EXECUTION_CLIENT_FILE" 2>/dev/null || echo "geth")
    execution_client_display_name_cron=$execution_client_name_cron
    consensus_client_name=$(cat "$CLIENT_FILE" 2>/dev/null || echo "prysm")
    consensus_client_display_name=$consensus_client_name
    # Function to validate Telegram token (updated version)
  validate_telegram_token() {
    local token=$1
    # Check token format
    if [[ ! "$token" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
      return 1
    fi
    # Test token by getting bot info
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
  echo "\n$(t "select_cron")"
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
execution_sync_response=\$(curl -s -X POST http://localhost:${EXECUTION_RPC_PORT} \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
if echo "\$execution_sync_response" | grep -q '"result":false'; then
  execution_status="✅ \$EXECUTION_CLIENT_DISPLAY_NAME synced"
elif echo "\$execution_sync_response" | grep -q '"result":'; then
  execution_status="⚠️ \$EXECUTION_CLIENT_DISPLAY_NAME syncing in progress"
else
  curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \
    --data-urlencode "chat_id=\$TG_CHAT_ID" \
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
  curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \
    --data-urlencode "chat_id=\$TG_CHAT_ID" \
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

curl -s -X POST "https://api.telegram.org/bot\$TG_TOKEN/sendMessage" \
  --data-urlencode "chat_id=\$TG_CHAT_ID" \
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

function update_node {
  print_info "$(t "node_update")"
  docker compose -f "$DOCKER_COMPOSE_FILE" pull
  stop_containers
  start_containers
  print_success "$(t "node_updated")"
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

function change_installed_ports {
  print_warning "\n$(t "updating_ports")"
  echo ""
  ask_for_custom_ports
  echo ""
  load_resource_configuration # Load resource configuration
  create_docker_compose
  print_success "\n$(t "ports_updated")"
  print_warning "\n$(t "restart_required")"
}

function firewall_setup() {

  check_docker_user_chain_ufw() {
      echo -e "${BLUE}$(t "checking_docker_user_chain")${RESET}"

      # Проверяем существование цепочки DOCKER-USER
      if ! sudo iptables -L DOCKER-USER >/dev/null 2>&1; then
          echo -e "\n${RED}$(t "docker_user_chain_not_found")${RESET}"
          echo -e "\n${YELLOW}$(t "creating_docker_user_chain")${RESET}"
          sudo iptables -N DOCKER-USER
          echo -e "${GREEN}$(t "docker_user_chain_created")${RESET}"

          # Добавляем переход FORWARD -> DOCKER-USER
          sudo iptables -I FORWARD -j DOCKER-USER
          echo -e "\n${YELLOW}$(t "added_forward_to_docker_user")${RESET}"
      else
          echo -e "${GREEN}$(t "docker_user_chain_available")${RESET}"

          # Проверяем наличие перехода FORWARD -> DOCKER-USER
          if ! sudo iptables -L FORWARD | grep -q "DOCKER-USER"; then
              echo -e "\n${YELLOW}$(t "adding_forward_to_docker_user")${RESET}"
              sudo iptables -I FORWARD -j DOCKER-USER
              echo -e "${GREEN}$(t "forward_to_docker_user_added")${RESET}"
          else
              echo -e "${GREEN}$(t "forward_to_docker_user_exists")${RESET}"
          fi
      fi

      # Проверяем правила DOCKER для указанных портов
      echo -e "\n${BLUE}$(t "checking_docker_chain_rules")${RESET}"
      if sudo iptables -L DOCKER -n >/dev/null 2>&1; then
          echo -e "${GREEN}$(t "docker_chain_available")${RESET}"

          # Функция для добавления правил
          add_docker_user_rules() {
              local port=$1
              local type=$2
              local added=0
              local rules

              echo -e "\n${CYAN}$(t "checking_${type}_rpc_port") $port${RESET}"
              rules=$(sudo iptables -L DOCKER -n | grep -E "tcp dpt:$port($| )")
              while read -r line; do
                  dest_ip=$(echo "$line" | awk 'match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?[[:space:]]+tcp dpt:[0-9]+/) {
                      split(substr($0, RSTART, RLENGTH), parts, /[[:space:]]+/);
                      print parts[1]
                  }')

                  if [ -n "$dest_ip" ]; then
                      echo -e "${YELLOW}$(t "found_rule_for_port") $port: $(t "destination_ip") ${GREEN}$dest_ip${RESET}"

                      # Улучшенная проверка существования правила
                      if ! sudo iptables -n -L DOCKER-USER | grep -q -E "ACCEPT +tcp +-- +${dest_ip//./\\.} +0\.0\.0\.0\/0"; then
                          echo -e "${YELLOW}$(t "adding_accept_rule_for_ip") $dest_ip${RESET}"
                          sudo iptables -I DOCKER-USER -p tcp -s $dest_ip -j ACCEPT
                          added=$((added + 1))
                      else
                          echo -e "${GREEN}$(t "accept_rule_already_exists") $dest_ip${RESET}"
                      fi
                  else
                      echo -e "${YELLOW}$(t "found_rule_for_port") $port: ${RED}$(t "failed_to_get_ip")${RESET}"
                      echo -e "${YELLOW}Строка iptables: $line${RESET}"
                  fi
              done <<< "$rules"

              if [ $added -gt 0 ]; then
                  echo -e "${GREEN}$(t "added_rules_count") $added ${type}${RESET}"
              fi
          }

          # Проверяем правила для EXECUTION_RPC_PORT
          if [ -n "$EXECUTION_RPC_PORT" ]; then
              add_docker_user_rules "$EXECUTION_RPC_PORT" "execution"
          fi

          # Проверяем правила для CONSENSUS_RPC_PORT
          if [ -n "$CONSENSUS_RPC_PORT" ]; then
              add_docker_user_rules "$CONSENSUS_RPC_PORT" "consensus"
          fi
      else
          echo -e "${YELLOW}$(t "docker_chain_not_found")${RESET}"
      fi

      # Вычисляем дополнительный порт (CONSENSUS_P2P_PORT с последней цифрой 1)
      local alt_consensus_p2p_port="${CONSENSUS_P2P_PORT%?}1"

      # Проверяем статус UFW
      echo -e "\n${BLUE}$(t "checking_ufw_status")${RESET}"
      if sudo ufw status | grep -q "Status: active"; then
          echo -e "${GREEN}$(t "ufw_already_enabled")${RESET}"
      else
          echo -e "${YELLOW}$(t "ufw_disabled_configuring")${RESET}"
          # Разрешаем SSH соединения
          echo -e "${YELLOW}$(t "adding_ssh_port_rule")${RESET}"
          sudo ufw allow 22
          echo -e "${YELLOW}$(t "adding_ssh_name_rule")${RESET}"
          sudo ufw allow ssh

          # Включаем UFW с подтверждением
          echo -e "${YELLOW}$(t "enabling_ufw")${RESET}"
          if ! echo "y" | sudo ufw enable; then
              echo -e "${RED}$(t "failed_to_enable_ufw")${RESET}"
              return 1
          fi
          echo -e "\n${GREEN}$(t "ufw_enabled_successfully")${RESET}"
      fi

	# Добавляем правила для портов (общее для обоих случаев)
	echo -e "\n${YELLOW}$(t "adding_exec_p2p_port_rule")${RESET}"
	for port in "$EXECUTION_P2P_PORT" "$CONSENSUS_P2P_PORT" "$alt_consensus_p2p_port"; do
		if ! sudo ufw status | grep -q "$port/tcp"; then
			sudo ufw allow "$port"/tcp
			sudo ufw allow "$port"/udp
		else
			echo -e "${GREEN}$(t "port_rule_exists") $port${RESET}"
		fi
	done

      # Показываем статус
      echo -e "\n${CYAN}$(t "current_ufw_status")${RESET}"
      sudo ufw status numbered

      return 0
  }

    # Проверка существования правила
    rule_exists() {
        local rule="$@"
        if sudo iptables -C DOCKER-USER $rule >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    }

	# Добавление правил блокировки RPC портов
	add_global_drop_rule() {
		# Вычисляем третий порт (CONSENSUS_RPC_PORT с последней цифрой 1)
		local alt_consensus_port="${CONSENSUS_RPC_PORT%?}1"

		# Перенаправляем вывод iptables в /dev/null
		exec 3>&1  # Сохраняем stdout
		exec 1>/dev/null  # Перенаправляем stdout в /dev/null

		# Переменные для отслеживания статуса
		local new_rules=()
		local existing_rules=()

		# Функция для добавления правила блокировки в конец цепочки
		add_drop_rule() {
			local port=$1
			local protocol=$2
			if ! sudo iptables -C DOCKER-USER -p $protocol --dport "$port" -j DROP 2>/dev/null; then
				sudo iptables -A DOCKER-USER -p $protocol --dport "$port" -j DROP 2>/dev/null
				new_rules+=("$port ($protocol)")
				return 0
			else
				existing_rules+=("$port ($protocol)")
				return 1
			fi
		}

		# Блокируем EXECUTION_RPC_PORT (TCP)
		add_drop_rule "$EXECUTION_RPC_PORT" "tcp"

		# Блокируем CONSENSUS_RPC_PORT (TCP)
		add_drop_rule "$CONSENSUS_RPC_PORT" "tcp"

		# Блокируем альтернативный CONSENSUS_RPC_PORT (TCP)
		add_drop_rule "$alt_consensus_port" "tcp"

		# Восстанавливаем stdout
		exec 1>&3

		# Выводим только наши сообщения
		echo -e "\n${YELLOW}$(t "blocking_rpc_ports")${RESET}"

		if [ ${#new_rules[@]} -gt 0 ]; then
			echo -e "${GREEN}$(t "blocked_ports") ${new_rules[*]}${RESET}"
		fi

		if [ ${#existing_rules[@]} -gt 0 ]; then
			echo -e "${YELLOW}$(t "ports_already_blocked") ${existing_rules[*]}${RESET}"
		fi
	}

    # Добавление правила с проверкой и поддержанием DROP в конце
    add_rule() {
        # Добавляем новое правило
        echo -e "\n${BLUE}$(t "adding_rule")${RESET} ${CYAN}sudo iptables -I DOCKER-USER $@${RESET}"
        if ! rule_exists "$@"; then
            if sudo iptables -I DOCKER-USER "$@"; then
                echo -e "${GREEN}$(t "rule_added")${RESET}"
            else
                echo -e "${RED}$(t "failed_to_add_rule")${RESET}"
            fi
        else
            echo -e "${YELLOW}$(t "rule_already_exists")${RESET}"
        fi

        # Возвращаем правило DROP в конец
        add_global_drop_rule
    }

	# Показать правила для портов
	show_port_rules() {
		echo -e "\n${YELLOW}$(t "current_port_rules")${RESET}"
		echo -e "${CYAN}$(t "docker_user_port_rules")${RESET}"
		sudo iptables -L DOCKER-USER -n --line-numbers | grep -E "dpt:|spt:"

		# Правила UFW для портов
		echo -e "\n${CYAN}$(t "ufw_port_rules")${RESET}"
		sudo ufw status numbered | grep -v '^Status:' | grep -E '([0-9]+/[a-zA-Z]+)|(ANYWHERE)|$'

		print_info "\n$(t "current_port_config" "$EXECUTION_RPC_PORT" "$EXECUTION_P2P_PORT" "$EXECUTION_AUTH_RPC_PORT" "$CONSENSUS_RPC_PORT" "$CONSENSUS_P2P_PORT")"
	}

	# Показать правила для IP
	show_ip_rules() {
		echo -e "\n${YELLOW}$(t "current_ip_rules")${RESET}"
		echo -e "${CYAN}$(t "docker_user_ip_rules")${RESET}"
		sudo iptables -L DOCKER-USER -n --line-numbers | awk '$4 != "0.0.0.0/0" && $1 != "target"'

		# Правила UFW для IP
		echo -e "\n${CYAN}$(t "ufw_ip_rules")${RESET}"
		sudo ufw status numbered | grep -v '^Status:' | grep -E '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?)|(ANYWHERE)|$'

		print_info "\n$(t "current_port_config" "$EXECUTION_RPC_PORT" "$EXECUTION_P2P_PORT" "$EXECUTION_AUTH_RPC_PORT" "$CONSENSUS_RPC_PORT" "$CONSENSUS_P2P_PORT")"
	}

	# Меню управления портами
	port_management() {
		# Устанавливаем обработчик прерывания
		trap 'continue' SIGINT

		while true; do
			# Всегда показываем текущие правила с номерами строк при входе в меню
			show_port_rules

			echo -e "\n${CYAN}$(t "port_management_menu")${RESET}"
			echo -e "1) $(t "open_port_option")"
			echo -e "2) $(t "close_port_option")"
			echo -e "3) $(t "block_rpc_ports_option")"
			echo -e "${RED}0) $(t "return_to_main_menu")${RESET}"
			echo -e "${CYAN}────────────────────────────────${RESET}"

			# Чтение выбора с обработкой Ctrl+C
			if ! read -p "$(t "select_option")" choice; then
				continue
			fi

			case $choice in
				1)
					echo -e "\n${GREEN}$(t "opening_port")${RESET}"
					if ! read -p "$(t "enter_port_number_prompt")" ports; then
						continue
					fi

					# Выбор направления
					echo -e "\n${YELLOW}$(t "select_direction")${RESET}"
					echo " 1) $(t "incoming_connections")"
					echo " 2) $(t "outgoing_connections")"
					echo " 3) $(t "all_directions")"
					if ! read -p "$(t "select_direction_prompt")" direction; then
						continue
					fi

					# Выбор протокола
					echo -e "\n${YELLOW}$(t "select_protocol")${RESET}"
					echo " 1) TCP"
					echo " 2) UDP"
					echo " 3) $(t "all_protocols")"
					if ! read -p "$(t "select_protocol_prompt")" protocol; then
						continue
					fi

					if [[ $ports =~ ^[0-9]+(,[0-9]+)*$ ]] && [[ $direction =~ ^[1-3]$ ]] && [[ $protocol =~ ^[1-3]$ ]]; then
						# Определяем параметры направления
						case $direction in
							1)
								direction_param="--dport"
								ufw_direction="in"
								;;
							2)
								direction_param="--sport"
								ufw_direction="out"
								;;
							3)
								direction_param="--dport --sport"
								ufw_direction="both"
								;;
						esac

						# Определяем параметры протокола
						case $protocol in
							1)
								protocols=("tcp")
								;;
							2)
								protocols=("udp")
								;;
							3)
								protocols=("tcp" "udp")
								;;
						esac

						IFS=',' read -ra port_list <<< "$ports"

						# Добавляем правила для каждого порта, протокола и направления
						for port in "${port_list[@]}"; do
							for proto in "${protocols[@]}"; do
								for dir in $direction_param; do
									echo -e "\n${BLUE}────────${RESET}"
									#echo -e "\n${BLUE}$(t "adding_iptables_rule") $port, $(t "protocol") $proto, $(t "direction") $dir${RESET}"
									add_rule -p $proto $dir $port -j ACCEPT

									# Добавляем соответствующее правило для UFW
									if [ "$ufw_direction" == "both" ]; then
										echo -e "\n${BLUE}$(t "adding_ufw_rule") $port/$proto ($(t "in_and_out"))${RESET}"
										sudo ufw allow $port/$proto
										sudo ufw allow out $port/$proto
										echo -e "\n${BLUE}────────${RESET}"
									else
										echo -e "\n${BLUE}$(t "adding_ufw_rule") $port/$proto, $(t "direction") $ufw_direction${RESET}"
										sudo ufw allow $ufw_direction $port/$proto
										echo -e "\n${BLUE}────────${RESET}"
									fi
								done
							done
						done
					else
						echo -e "${RED}$(t "invalid_input_error")${RESET}"
					fi
					;;
				2)
					echo -e "\n${RED}$(t "deleting_rules")${RESET}"
					echo -e "${YELLOW}$(t "select_rule_type_to_delete")${RESET}"
					echo " 1) $(t "delete_iptables_rule")"
					echo " 2) $(t "delete_ufw_rule")"
					echo " 3) $(t "delete_both_rules")"
					if ! read -p "$(t "select_option")" delete_type; then
						continue
					fi

					case $delete_type in
						1)
							# Удаление только iptables правил
							echo -e "\n${YELLOW}$(t "enter_iptables_rule_numbers")${RESET}"
							if ! read -p "$(t "rule_numbers_to_delete_prompt")" rule_numbers; then
								continue
							fi

							# Обрабатываем ввод (номера через запятую и диапазоны)
							declare -a rules_to_delete=()
							IFS=',' read -ra parts <<< "$rule_numbers"
							for part in "${parts[@]}"; do
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											rules_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									rules_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							# Сортируем в обратном порядке для безопасного удаления
							IFS=$'\n' sorted_rules=($(sort -nr <<< "${rules_to_delete[*]}"))
							unset IFS

							deleted_count=0
							for rule_num in "${sorted_rules[@]}"; do
								if sudo iptables -L DOCKER-USER -n --line-numbers | grep -q "^${rule_num}\>"; then
									local rule=$(sudo iptables -S DOCKER-USER $rule_num)
									echo -e "${BLUE}$(t "deleting_iptables_rule") №$rule_num: $rule${RESET}"
									sudo iptables -D DOCKER-USER $rule_num
									((deleted_count++))
								else
									echo -e "${YELLOW}$(t "rule_not_found_skipping") №$rule_num${RESET}"
								fi
							done

							add_global_drop_rule
							echo -e "\n${GREEN}$(t "deleted_iptables_rules") $deleted_count${RESET}"
							;;

						2)
							# Удаление только UFW правил
							echo -e "\n${YELLOW}$(t "enter_ufw_rule_numbers")${RESET}"
							if ! read -p "$(t "rule_numbers_to_delete_prompt")" rule_numbers; then
								continue
							fi

							# Обрабатываем ввод (номера через запятую и диапазоны)
							declare -a rules_to_delete=()
							IFS=',' read -ra parts <<< "$rule_numbers"
							for part in "${parts[@]}"; do
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											rules_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									rules_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							# Сортируем в обратном порядке для безопасного удаления
							IFS=$'\n' sorted_rules=($(sort -nr <<< "${rules_to_delete[*]}"))
							unset IFS

							deleted_count=0
							for rule_num in "${sorted_rules[@]}"; do
								echo -e "${BLUE}$(t "deleting_ufw_rule") №$rule_num${RESET}"
								if echo "y" | sudo ufw --force delete $rule_num; then
									((deleted_count++))
								else
									echo -e "${YELLOW}$(t "failed_to_delete_rule") №$rule_num${RESET}"
								fi
							done

							echo -e "\n${GREEN}$(t "deleted_ufw_rules") $deleted_count${RESET}"
							;;

						3)
							# Удаление и iptables и UFW правил
							echo -e "\n${YELLOW}$(t "enter_iptables_rule_numbers")${RESET}"
							if ! read -p "$(t "iptables_rule_numbers_prompt")" iptables_rules; then
								continue
							fi

							echo -e "\n${YELLOW}$(t "enter_ufw_rule_numbers")${RESET}"
							if ! read -p "$(t "ufw_rule_numbers_prompt")" ufw_rules; then
								continue
							fi

							# Обработка iptables правил
							declare -a iptables_to_delete=()
							IFS=',' read -ra parts <<< "$iptables_rules"
							for part in "${parts[@]}"; do
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											iptables_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									iptables_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							IFS=$'\n' sorted_iptables=($(sort -nr <<< "${iptables_to_delete[*]}"))
							unset IFS

							iptables_deleted=0
							for rule_num in "${sorted_iptables[@]}"; do
								if sudo iptables -L DOCKER-USER -n --line-numbers | grep -q "^${rule_num}\>"; then
									local rule=$(sudo iptables -S DOCKER-USER $rule_num)
									echo -e "${BLUE}$(t "deleting_iptables_rule") №$rule_num: $rule${RESET}"
									sudo iptables -D DOCKER-USER $rule_num
									((iptables_deleted++))
								else
									echo -e "${YELLOW}$(t "rule_not_found_skipping") №$rule_num${RESET}"
								fi
							done

							# Обработка UFW правил
							declare -a ufw_to_delete=()
							IFS=',' read -ra parts <<< "$ufw_rules"
							for part in "${parts[@]}"; do
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											ufw_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									ufw_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							IFS=$'\n' sorted_ufw=($(sort -nr <<< "${ufw_to_delete[*]}"))
							unset IFS

							ufw_deleted=0
							for rule_num in "${sorted_ufw[@]}"; do
								echo -e "${BLUE}$(t "deleting_ufw_rule") №$rule_num${RESET}"
								if echo "y" | sudo ufw --force delete $rule_num; then
									((ufw_deleted++))
								else
									echo -e "${YELLOW}$(t "failed_to_delete_rule") №$rule_num${RESET}"
								fi
							done

							add_global_drop_rule
							echo -e "\n${GREEN}$(t "deleted_iptables_rules") $iptables_deleted${RESET}"
							echo -e "${GREEN}$(t "deleted_ufw_rules") $ufw_deleted${RESET}"
							;;

						*)
							echo -e "${RED}$(t "invalid_choice_cancel")${RESET}"
							;;
					esac
					;;
				3)
					echo -e "\n${BLUE}$(t "blocking_rpc_ports_for_all")${RESET}"
					add_global_drop_rule

					# Также блокируем входящие соединения в UFW
					echo -e "\n${BLUE}$(t "changing_ufw_policy_to_block_all")${RESET}"
					sudo ufw default deny incoming
					;;
				0)
					break
					;;
				*)
					echo -e "${RED}$(t "invalid_option")${RESET}"
					;;
			esac

			echo ""
			if ! read -p "$(t "press_enter_to_continue")"; then
				continue
			fi
		done

		# Сбрасываем обработчик прерывания
		trap - SIGINT
	}

	# Меню управления IP-адресами
	ip_management() {
		# Устанавливаем обработчик прерывания
		trap 'continue' SIGINT

		while true; do
			# Всегда показываем текущие правила с номерами строк при входе в меню
			show_ip_rules

			echo -e "\n${CYAN}$(t "ip_management_menu")${RESET}"
			echo -e "1) $(t "allow_access_from_ip")"
			echo -e "2) $(t "deny_access_delete_rule")"
			echo -e "${RED}0) $(t "return_to_main_menu")${RESET}"
			echo -e "${CYAN}────────────────────────────────────${RESET}"

			# Чтение выбора с обработкой Ctrl+C
			if ! read -p "$(t "select_option")" choice; then
				continue
			fi

			case $choice in
				1)
					echo -e "\n${GREEN}$(t "allowing_access_from_ip")${RESET}"
					if ! read -p "$(t "enter_ip_or_subnet_prompt")" ip_input; then
						continue
					fi

					if ! read -p "$(t "enter_port_number_optional_prompt")" port_input; then
						continue
					fi

					# Выбор направления
					echo -e "\n${YELLOW}$(t "select_direction")${RESET}"
					echo "1) $(t "incoming_connections")"
					echo "2) $(t "outgoing_connections")"
					echo "3) $(t "all_directions")"
					if ! read -p "$(t "select_direction_prompt")" direction; then
						continue
					fi

					# Выбор протокола
					echo -e "\n${YELLOW}$(t "select_protocol")${RESET}"
					echo "1) TCP"
					echo "2) UDP"
					echo "3) $(t "all_protocols")"
					if ! read -p "$(t "select_protocol_prompt")" protocol; then
						continue
					fi

					# Разделяем введенные IP-адреса и порты
					IFS=',' read -ra ip_list <<< "$ip_input"
					IFS=',' read -ra port_list <<< "$port_input"
					unset IFS

					valid_input=true

					# Проверяем все IP-адреса
					for ip in "${ip_list[@]}"; do
						if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
							echo -e "${RED}$(t "invalid_ip_format") $ip${RESET}"
							valid_input=false
						fi
					done

					# Проверяем все порты
					for port in "${port_list[@]}"; do
						if [[ -n $port && ! $port =~ ^[0-9]+$ ]]; then
							echo -e "${RED}$(t "port_must_be_number_error") $port${RESET}"
							valid_input=false
						fi
					done

					if [[ $valid_input == true ]] && [[ $direction =~ ^[1-3]$ ]] && [[ $protocol =~ ^[1-3]$ ]]; then
						# Определяем параметры направления
						case $direction in
							1)
								direction_param="--dport"
								ufw_direction="in"
								;;
							2)
								direction_param="--sport"
								ufw_direction="out"
								;;
							3)
								direction_param="--dport --sport"
								ufw_direction="both"
								;;
						esac

						# Определяем параметры протокола
						case $protocol in
							1) protocols=("tcp") ;;
							2) protocols=("udp") ;;
							3) protocols=("tcp" "udp") ;;
						esac

						# Обрабатываем каждый IP-адрес
						for ip in "${ip_list[@]}"; do
							# Если порты не указаны
							if [[ ${#port_list[@]} -eq 0 ]] || [[ -z $port_input ]]; then
							    echo -e "\n${BLUE}────────${RESET}"
								#echo -e "\n${BLUE}$(t "adding_iptables_rule_for_all_traffic_from") $ip...${RESET}"
								add_rule -s $ip -j ACCEPT

								# Добавляем правило UFW
								echo -e "\n${BLUE}$(t "adding_ufw_rule_for_all_traffic_from") $ip...${RESET}"
								sudo ufw allow from $ip
								echo -e "\n${BLUE}────────${RESET}"
							else
								# Обрабатываем каждый порт
								for port in "${port_list[@]}"; do
									# Добавляем правила для каждого направления и протокола
									for proto in "${protocols[@]}"; do
										for dir in $direction_param; do
											echo -e "\n${BLUE}────────${RESET}"
											#echo -e "\n${BLUE}$(t "adding_iptables_rule_for_port") $port $(t "from") $ip, $(t "protocol") $proto, $(t "direction") $dir...${RESET}"
											add_rule -s $ip -p $proto $dir $port -j ACCEPT

											# Добавляем соответствующее правило UFW
											if [ "$ufw_direction" == "both" ]; then
												echo -e "\n${BLUE}$(t "adding_ufw_rule_for_port") $port/$proto $(t "from") $ip ($(t "in_and_out"))...${RESET}"
												sudo ufw allow from $ip to any port $port proto $proto
												sudo ufw allow out from any to $ip port $port proto $proto
												echo -e "\n${BLUE}────────${RESET}"
											else
												echo -e "\n${BLUE}$(t "adding_ufw_rule_for_port") $port/$proto $(t "from") $ip ($(t "direction") $ufw_direction)...${RESET}"
												if [ "$ufw_direction" == "in" ]; then
													sudo ufw allow from $ip to any port $port proto $proto
													echo -e "\n${BLUE}────────${RESET}"
												else
													sudo ufw allow out from any to $ip port $port proto $proto
													echo -e "\n${BLUE}────────${RESET}"
												fi
											fi
										done
									done
								done
							fi
						done
					else
						echo -e "${RED}$(t "invalid_input_error")${RESET}"
						echo -e "${YELLOW}$(t "correct_input_examples")${RESET}"
						echo -e "$(t "ip_example")"
					fi
					;;
				2)
					echo -e "\n${RED}$(t "deleting_rules")${RESET}"
					echo -e "${YELLOW}$(t "select_rule_type_to_delete")${RESET}"
					echo "1) $(t "delete_iptables_rule")"
					echo "2) $(t "delete_ufw_rule")"
					echo "3) $(t "delete_both_rules")"
					if ! read -p "$(t "select_option")" delete_type; then
						continue
					fi

					case $delete_type in
						1)
							# Удаление только iptables правил
							echo -e "\n${YELLOW}$(t "enter_iptables_rule_numbers")${RESET}"
							if ! read -p "$(t "rule_numbers_to_delete_prompt")" rule_numbers; then
								continue
							fi

							# Обрабатываем ввод (номера через запятую и диапазоны)
							declare -a rules_to_delete=()
							IFS=',' read -ra parts <<< "$rule_numbers"
							for part in "${parts[@]}"; do
								part=$(echo "$part" | tr -d '[:space:]')  # Удаляем пробелы
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											rules_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									rules_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							# Сортируем в обратном порядке для безопасного удаления
							IFS=$'\n' sorted_rules=($(sort -nr <<< "${rules_to_delete[*]}"))
							unset IFS

							deleted_count=0
							for rule_num in "${sorted_rules[@]}"; do
								if sudo iptables -L DOCKER-USER -n --line-numbers | grep -q "^${rule_num}\>"; then
									local rule=$(sudo iptables -S DOCKER-USER $rule_num)
									echo -e "${BLUE}$(t "deleting_iptables_rule") №$rule_num: $rule${RESET}"
									sudo iptables -D DOCKER-USER $rule_num
									((deleted_count++))
								else
									echo -e "${YELLOW}$(t "rule_not_found_skipping") №$rule_num${RESET}"
								fi
							done

							add_global_drop_rule
							echo -e "\n${GREEN}$(t "deleted_iptables_rules") $deleted_count${RESET}"
							;;

						2)
							# Удаление только UFW правил
							echo -e "\n${YELLOW}$(t "enter_ufw_rule_numbers")${RESET}"
							if ! read -p "$(t "rule_numbers_to_delete_prompt")" rule_numbers; then
								continue
							fi

							# Обрабатываем ввод (номера через запятую и диапазоны)
							declare -a rules_to_delete=()
							IFS=',' read -ra parts <<< "$rule_numbers"
							for part in "${parts[@]}"; do
								part=$(echo "$part" | tr -d '[:space:]')  # Удаляем пробелы
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											rules_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									rules_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							# Сортируем в обратном порядке для безопасного удаления
							IFS=$'\n' sorted_rules=($(sort -nr <<< "${rules_to_delete[*]}"))
							unset IFS

							deleted_count=0
							for rule_num in "${sorted_rules[@]}"; do
								echo -e "${BLUE}$(t "deleting_ufw_rule") №$rule_num${RESET}"
								if echo "y" | sudo ufw --force delete $rule_num; then
									((deleted_count++))
								else
									echo -e "${YELLOW}$(t "failed_to_delete_rule") №$rule_num${RESET}"
								fi
							done

							echo -e "\n${GREEN}$(t "deleted_ufw_rules") $deleted_count${RESET}"
							;;

						3)
							# Удаление и iptables и UFW правил
							echo -e "\n${YELLOW}$(t "enter_iptables_rule_numbers")${RESET}"
							if ! read -p "$(t "iptables_rule_numbers_prompt")" iptables_rules; then
								continue
							fi

							echo -e "\n${YELLOW}$(t "enter_ufw_rule_numbers")${RESET}"
							if ! read -p "$(t "ufw_rule_numbers_prompt")" ufw_rules; then
								continue
							fi

							# Обработка iptables правил
							declare -a iptables_to_delete=()
							IFS=',' read -ra parts <<< "$iptables_rules"
							for part in "${parts[@]}"; do
								part=$(echo "$part" | tr -d '[:space:]')  # Удаляем пробелы
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											iptables_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									iptables_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							IFS=$'\n' sorted_iptables=($(sort -nr <<< "${iptables_to_delete[*]}"))
							unset IFS

							iptables_deleted=0
							for rule_num in "${sorted_iptables[@]}"; do
								if sudo iptables -L DOCKER-USER -n --line-numbers | grep -q "^${rule_num}\>"; then
									local rule=$(sudo iptables -S DOCKER-USER $rule_num)
									echo -e "${BLUE}$(t "deleting_iptables_rule") №$rule_num: $rule${RESET}"
									sudo iptables -D DOCKER-USER $rule_num
									((iptables_deleted++))
								else
									echo -e "${YELLOW}$(t "rule_not_found_skipping") №$rule_num${RESET}"
								fi
							done

							# Обработка UFW правил
							declare -a ufw_to_delete=()
							IFS=',' read -ra parts <<< "$ufw_rules"
							for part in "${parts[@]}"; do
								part=$(echo "$part" | tr -d '[:space:]')  # Удаляем пробелы
								if [[ $part =~ ^[0-9]+-[0-9]+$ ]]; then
									# Обрабатываем диапазон
									start=${part%-*}
									end=${part#*-}
									if (( start <= end )); then
										for ((i=start; i<=end; i++)); do
											ufw_to_delete+=("$i")
										done
									else
										echo -e "${YELLOW}$(t "invalid_range_skipping") $part${RESET}"
									fi
								elif [[ $part =~ ^[0-9]+$ ]]; then
									# Одиночный номер
									ufw_to_delete+=("$part")
								else
									echo -e "${YELLOW}$(t "invalid_rule_number_skipping") $part${RESET}"
								fi
							done

							IFS=$'\n' sorted_ufw=($(sort -nr <<< "${ufw_to_delete[*]}"))
							unset IFS

							ufw_deleted=0
							for rule_num in "${sorted_ufw[@]}"; do
								echo -e "${BLUE}$(t "deleting_ufw_rule") №$rule_num${RESET}"
								if echo "y" | sudo ufw --force delete $rule_num; then
									((ufw_deleted++))
								else
									echo -e "${YELLOW}$(t "failed_to_delete_rule") №$rule_num${RESET}"
								fi
							done

							add_global_drop_rule
							echo -e "\n${GREEN}$(t "deleted_iptables_rules") $iptables_deleted${RESET}"
							echo -e "${GREEN}$(t "deleted_ufw_rules") $ufw_deleted${RESET}"
							;;

						*)
							echo -e "${RED}$(t "invalid_choice_cancel")${RESET}"
							;;
					esac
					;;
				0)
					break
					;;
				*)
					echo -e "${RED}$(t "invalid_option")${RESET}"
					;;
			esac

			echo ""
			if ! read -p "$(t "press_enter_to_continue")"; then
				continue
			fi
		done

		# Сбрасываем обработчик прерывания
		trap - SIGINT
	}

	# Просмотр всех правил
	view_rules() {
		echo -e "\n${YELLOW}$(t "view_all_rules")${RESET}"

		# Вывод правил iptables
		echo -e "\n${CYAN}$(t "current_docker_user_chain_rules")${RESET}"
		local iptables_rules=$(sudo iptables -L DOCKER-USER -n --line-numbers)
		if [ -z "$(echo "$iptables_rules" | grep -v '^Chain' | grep -v '^num')" ]; then
			echo -e "${YELLOW}$(t "no_rules_in_docker_user_chain")${RESET}"
		else
			echo "$iptables_rules"
		fi

		# Вывод правил UFW
		echo -e "\n${CYAN}$(t "current_ufw_rules")${RESET}"
		local ufw_rules=$(sudo ufw status numbered | grep -v '^Status:')
		if [ -z "$ufw_rules" ]; then
			echo -e "${YELLOW}$(t "no_active_ufw_rules")${RESET}"
		else
			echo "$ufw_rules"
		fi

		# Статистика iptables
		echo -e "\n${CYAN}$(t "iptables_rules_stats")${RESET}"
		local total_rules=$(sudo iptables -L DOCKER-USER -n | grep -c "^ACCEPT")
		local denied_rules=$(sudo iptables -L DOCKER-USER -n | grep -c "^DROP")
		echo -e "$(t "total_accept_rules") ${GREEN}$total_rules${RESET}"
		echo -e "$(t "total_drop_reject_rules") ${RED}$denied_rules${RESET}"

		# Статистика UFW
		echo -e "\n${CYAN}$(t "ufw_rules_stats")${RESET}"
		local ufw_policy=$(sudo ufw status verbose | grep "Default:")
		local ufw_policy_in=$(echo "$ufw_policy" | awk '{print $2}' | tr -d ',')
		local ufw_policy_out=$(echo "$ufw_policy" | awk '{print $4}')
		local ufw_allow=$(sudo ufw status numbered | grep -c "ALLOW")
		local ufw_deny=$(sudo ufw status numbered | grep -c "DENY")

		echo -e "$(t "default_policy")"
		echo -e "  $(t "incoming") ${BLUE}$ufw_policy_in${RESET}"
		echo -e "  $(t "outgoing") ${BLUE}$ufw_policy_out${RESET}"
		echo -e "$(t "total_allow_rules") ${GREEN}$ufw_allow${RESET}"
		echo -e "$(t "total_deny_reject_rules") ${RED}$ufw_deny${RESET}"
	}

	# Сброс и удаление всех правил
	reset_rules() {
		echo -e "\n${RED}$(t "reset_all_rules")${RESET}"
		echo -e "${YELLOW}$(t "you_are_about_to_perform")${RESET}"
		echo -e "1. $(t "clear_all_rules_in_docker_user_chain")"
		echo -e "2. $(t "reset_all_ufw_rules")"
		echo -e "3. $(t "restart_docker_service")"

		read -p "$(echo -e "${RED}$(t "are_you_sure_prompt") ${RESET}")" confirm
		if [[ $confirm =~ ^[Yy]$ ]]; then
			echo -e "\n${BLUE}1. $(t "clearing_docker_user_chain")...${RESET}"
			if sudo iptables -F DOCKER-USER; then
				echo -e "${GREEN}$(t "all_docker_user_rules_deleted")${RESET}"
			else
				echo -e "${RED}$(t "failed_to_clear_docker_user")${RESET}"
				return 1
			fi

			echo -e "\n${BLUE}2. $(t "resetting_ufw_rules")...${RESET}"
			if echo "y" | sudo ufw --force reset; then
				echo -e "${GREEN}$(t "all_ufw_rules_reset")${RESET}"
			else
				echo -e "${RED}$(t "failed_to_reset_ufw")${RESET}"
			fi

			echo -e "\n${BLUE}3. $(t "restarting_docker")...${RESET}"
			if sudo systemctl restart docker; then
				echo -e "${GREEN}$(t "docker_restarted_successfully")${RESET}"
				echo -e "\n${YELLOW}$(t "current_docker_user_status")${RESET}"
				sudo iptables -L DOCKER-USER -n
				echo -e "\n${YELLOW}$(t "current_ufw_status")${RESET}"
				sudo ufw status
			else
				echo -e "${RED}$(t "failed_to_restart_docker")${RESET}"
			fi
		else
			echo -e "${YELLOW}$(t "rules_reset_cancelled")${RESET}"
		fi
	}

    # Главное меню
    while true; do
        echo -e "\n${YELLOW}$(t "script_works_in_iptables")${RESET}"
		echo -e "${YELLOW}$(t "port_ip_management_logic")${RESET}"
		echo -e "${YELLOW}$(t "on_first_run")${RESET}"
		echo -e "${YELLOW}   1) $(t "first_run_option_1")${RESET}"
		echo -e "${YELLOW}   2) $(t "first_run_option_2")${RESET}"
		echo -e "${YELLOW}   3) $(t "first_run_option_3")${RESET}"
		echo -e "${YELLOW}$(t "now_you_can_add_remove")${RESET}"
		echo -e "\n${BLUE}$(t "firewall_management_main_menu")${RESET}"
		echo -e "${RESET}1) $(t "enable_and_prepare_option")${RESET}"
        echo -e "${RESET}2) $(t "port_management_option")${RESET}"
        echo -e "${RESET}3) $(t "ip_management_option")${RESET}"
        echo -e "${RESET}4) $(t "view_all_rules_option")${RESET}"
        echo -e "${RED}5) $(t "reset_all_rules_option")${RESET}"
        echo -e "${RED}0) $(t "exit_option")${RESET}"
        echo -e "${BLUE}───────────────────────────────────────────────${RESET}"

        read -p "$(t "select_option")" choice

        case $choice in
			1) check_docker_user_chain_ufw ;;
            2) port_management ;;
            3) ip_management ;;
            4) view_rules ;;
            5) reset_rules ;;
            0)
                echo -e "${GREEN}$(t "exiting_firewall_menu")${RESET}"
                break
                ;;
            *)
                echo -e "${RED}$(t "invalid_option")${RESET}"
                ;;
        esac

		if [[ "$choice" != "0" ]]; then
            echo ""
            read -p "$(t "press_enter_to_continue")"
        fi
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
  load_resource_configuration # Load resource config at the start of the menu
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
      11) change_installed_ports ;;
      12) check_disk_usage ;;
      13) firewall_setup ;;
      14) run_rpc_check ;;
      15) configure_docker_resources ;;
      0) print_info "$(t "goodbye")"; exit 0 ;;
      *) print_error "$(t "invalid_option")" ;;
    esac
  done
}

main_menu