#!/bin/bash

# Color definitions (headings only)
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
BLUE='\e[0;34m'
CYAN='\e[0;36m'
RESET='\e[0m'

PORT_CONFIG="$HOME/sepolia-node/port_config.env"

if [[ -f "$PORT_CONFIG" ]]; then
  source "$PORT_CONFIG"
else
  echo "File $PORT_CONFIG not found. Default values are being used."
  EXECUTION_RPC_PORT=8545
  CONSENSUS_RPC_PORT=5052
fi

################################################################################
# Environment & Tool Setup
################################################################################

# Ensure robust shell environment (locale, PATH)
export LC_ALL=C
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Essential tools list
declare -A TOOLS=([curl]="curl" [jq]="jq" [bc]="bc" [gawk]="gawk")

print_separator() {
    printf '=%.0s' {1..50}; echo
}

print_header() {
    print_separator
    printf '%26s\n' "Tools Checker"
    print_separator
}

print_tool_status() {
    local installed=()
    local missing=()
    for tool in "${!TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            installed+=("$tool ✓")
        else
            missing+=("$tool ✗")
        fi
    done
    echo "● Installed"
    for item in "${installed[@]}"; do
        echo "  $item"
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "● Missing"
        for item in "${missing[@]}"; do
            echo "  $item"
        done
    fi
    print_separator
}

# Detect package manager and install cmd
if command -v dnf &>/dev/null; then
    INSTALL_CMD="dnf install -qy"
elif command -v apt-get &>/dev/null; then
    INSTALL_CMD="apt-get install -qqy"
elif command -v pacman &>/dev/null; then
    INSTALL_CMD="pacman -S --noconfirm --needed"
else
    echo "Unsupported package manager. Please install dependencies manually:"
    printf '%s\n' "${TOOLS[@]}"
    exit 1
fi

################################################################################
# Dependencies: Initial Check & Auto-Install (Silent)
################################################################################

clear
print_header
echo "Checking tools before install..."
print_tool_status

MISSING=()
for tool in "${!TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING+=("${TOOLS[$tool]}")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    if [ $(id -u) -eq 0 ]; then
        for t in "${!TOOLS[@]}"; do
            if ! command -v "$t" &>/dev/null; then
                $INSTALL_CMD "${TOOLS[$t]}" >/dev/null 2>&1 || true
            fi
        done
    else
        for t in "${!TOOLS[@]}"; do
            if ! command -v "$t" &>/dev/null; then
                sudo --non-interactive --validate >/dev/null 2>&1 &&
                sudo $INSTALL_CMD "${TOOLS[$t]}" >/dev/null 2>&1 || true
            fi
        done
    fi
fi

################################################################################
# Dependencies: Verify Success (Prompt for Root If Needed)
################################################################################

clear
print_header
echo "Checking tools after install..."
print_tool_status

MISSING=()
for tool in "${!TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING+=("${TOOLS[$tool]}")
    fi
done

if [ ${#MISSING[@]} -gt 0 ] && [ $(id -u) -ne 0 ]; then
    print_header
    echo "● Retrying with root access"
    print_separator
    INSTALL_CMD="for t in ${MISSING[*]}; do $INSTALL_CMD \"\$t\" >/dev/null 2>&1 || true; done"
    printf "Enter Password (will show visibly): "
    stty echo
    read -r SUDO_PASS
    stty -echo
    echo -en "\r\033[K"
    if echo "$SUDO_PASS" | sudo -S sh -c "$INSTALL_CMD"; then
        echo "Root Access Enabled ✓"
    else
        echo "Root Access Failed ✗"
    fi
    print_separator
    clear
    print_header
    echo "Checking tools after root access..."
    print_tool_status
elif [ ${#MISSING[@]} -gt 0 ]; then
    echo "WARNING: Running as root, but some tools still missing. Please check."
fi

################################################################################
# Dependencies: Exit If Missing Critical Tools
################################################################################

STILL_MISSING=()
for tool in "${!TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        STILL_MISSING+=("${TOOLS[$tool]}")
    fi
done

if [ ${#STILL_MISSING[@]} -gt 0 ]; then
    print_header
    echo "Critical Tools Missing: ${STILL_MISSING[*]}"
    echo "Cannot proceed. Install them manually."
    print_separator
    exit 1
fi

################################################################################
# Pre-Main UI Elements & Header
################################################################################

clear
print_separator
echo "All required tools found. Proceeding to main checks... ✓"
print_separator
clear

# Tools status for main display
FOUND=0; MISSING_DISPLAY=()
for tool in "${!TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        ((FOUND++))
    else
        MISSING_DISPLAY+=("${TOOLS[$tool]}")
    fi
done
if (( FOUND == 4 )); then
    TOOL_STATUS="${GREEN}Found (4/4) ✓${RESET}"
elif (( ${#MISSING_DISPLAY[@]} > 0 )); then
    TOOL_STATUS="${RED}Not Found (${FOUND}/4) ✗ (${MISSING_DISPLAY[*]})${RESET}"
else
    TOOL_STATUS="${YELLOW}Error (unexpected tool count)${RESET}"
fi

# Header/separator utils
SEP_WIDTH=50
sep_equals() { printf '=%.0s' $(seq 1 $SEP_WIDTH); echo; }
sep_dashes() { printf -- '-%.0s' $(seq 1 $SEP_WIDTH); echo; }
center_text() {
    local text="$1"
    local padding=$(( (SEP_WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

sep_equals
center_text "ETHEREUM NODE HEALTH CHECKER"
sep_equals
echo -en "Tools : ${TOOL_STATUS}"

################################################################################
# User Input: RPC Endpoints
################################################################################
echo -e "\n"
read -p "Use localhost (127.0.0.1) or external IP? [Choose l or i]: " choice

if [[ "$choice" =~ ^[Ll]$ ]]; then
  HOST="127.0.0.1"
elif [[ "$choice" =~ ^[Ii]$ ]]; then

  IP=$(curl -s https://api.ipify.org)
  if [[ -z "$IP" ]]; then
    echo -e "${RED}Failed to get external IP${RESET}"
    exit 1
  fi
  HOST="$IP"
else
  echo -e "${RED}Invalid choice. Please use 'l' or 'i'.${RESET}"
  exit 1
fi

EXEC_RPC="http://$HOST:$EXECUTION_RPC_PORT"
BEACON_RPC="http://$HOST:$CONSENSUS_RPC_PORT"

echo -e "\n${CYAN}--- Your Execution RPC ---${RESET}"
echo -e "\n${RESET}$EXEC_RPC${RESET}"
echo -e "\n${CYAN}--- Your Beacon RPC ---${RESET}"
echo -e "\n${RESET}$BEACON_RPC${RESET}"

################################################################################
# Geth Version Check (if execution_client is geth)
################################################################################

GETH_VERSION=""
EXECUTION_CLIENT_FILE="$HOME/sepolia-node/execution_client"

if [[ -f "$EXECUTION_CLIENT_FILE" ]]; then
    EXECUTION_CLIENT=$(cat "$EXECUTION_CLIENT_FILE" | tr -d '[:space:]')
    if [[ "$EXECUTION_CLIENT" == "geth" ]]; then
        echo -e "\n● Geth Version Check"
        printf "✓ Checking Geth version ..."
        GETH_RESPONSE=$(curl -s --connect-timeout 5 -w "\n%{http_code}" -X POST "$EXEC_RPC" \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}')
        printf "\r\033[K"
        GETH_HTTP_CODE=$(echo "$GETH_RESPONSE" | tail -n1)
        GETH_BODY=$(echo "$GETH_RESPONSE" | sed '$d')
        if [[ "$GETH_HTTP_CODE" == "200" ]]; then
            CLIENT_VERSION=$(echo "$GETH_BODY" | jq -r '.result' 2>/dev/null)
            if [[ "$CLIENT_VERSION" != "null" && "$CLIENT_VERSION" != "" ]]; then
                # Extract Geth version (e.g., "Geth/v1.16.4-stable-41714b49" from full string)
                GETH_VERSION=$(echo "$CLIENT_VERSION" | grep -o 'Geth/[^/]*' | head -1)
                echo -e "${GREEN}✓ Geth detected${RESET} (Version: ${GETH_VERSION})"
            else
                echo -e "${YELLOW}⚠ Could not parse Geth version${RESET}"
            fi
        else
            echo -e "${YELLOW}⚠ Could not fetch Geth version (HTTP $GETH_HTTP_CODE)${RESET}"
        fi
    fi
fi

################################################################################
# Sepolia RPC Check (Timeout, Connection Feedback, Clear Error State)
################################################################################

echo -e "\n● Sepolia RPC Check"
printf "✓ Trying to Connect ..."
SEPOLIA_RESPONSE=$(curl -s --connect-timeout 5 -w "\n%{http_code}" -X POST "$EXEC_RPC" \
    -H "Content-Type: application/json" \
    --data-raw '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
printf "\r\033[K"
SEPOLIA_HTTP_CODE=$(echo "$SEPOLIA_RESPONSE" | tail -n1)
SEPOLIA_BODY=$(echo "$SEPOLIA_RESPONSE" | sed '$d')
if [[ "$SEPOLIA_HTTP_CODE" == "200" ]]; then
    SEPOLIA_BLOCKNUM=$(echo "$SEPOLIA_BODY" | jq -r '.result' 2>/dev/null)
    if [[ "$SEPOLIA_BLOCKNUM" != "null" && "$SEPOLIA_BLOCKNUM" != "" ]]; then
        DEC_BLOCKNUM=$((16#${SEPOLIA_BLOCKNUM:2}))
        if [[ -n "$GETH_VERSION" ]]; then
            echo -e "${GREEN}✓ Healthy${RESET} (Block: ${DEC_BLOCKNUM}, ${GETH_VERSION})"
        else
            echo -e "${GREEN}✓ Healthy${RESET} (Block: ${DEC_BLOCKNUM})"
        fi
        SEPOLIA_OK=1
    else
        echo -e "${RED}✗ Unhealthy${RESET}"
    fi
else
    if [[ -z "$SEPOLIA_HTTP_CODE" || "$SEPOLIA_HTTP_CODE" == "000" ]]; then
        echo -e "${RED}✗ Unreachable (Connection Timeout)${RESET}"
    elif [[ "$SEPOLIA_HTTP_CODE" =~ ^[1-5][0-9]{2}$ ]]; then
        echo -e "${RED}✗ Unreachable (HTTP $SEPOLIA_HTTP_CODE)${RESET}"
    else
        echo -e "${RED}✗ Unreachable (unknown error)${RESET}"
    fi
fi

################################################################################
# Beacon Node Check (Timeout, Connection Feedback, Clear Error State)
################################################################################

echo -e "\n● Beacon Node Check"
printf "✓ Trying to Connect ..."
BEACON_RESPONSE=$(curl -s --max-time 5 -w "\n%{http_code}" "$BEACON_RPC/eth/v1/node/version")
printf "\r\033[K"
BEACON_HTTP_CODE=$(echo "$BEACON_RESPONSE" | tail -n1)
BEACON_BODY=$(echo "$BEACON_RESPONSE" | sed '$d')
if [[ "$BEACON_HTTP_CODE" == "200" ]]; then
    VER=$(echo "$BEACON_BODY" | jq -r '.data.version' 2>/dev/null)
    if [[ "$VER" && "$VER" != "null" ]]; then
        echo -e "${GREEN}✓ Reachable${RESET} (Version: ${VER})"
        BEACON_OK=1
    else
        echo -e "${YELLOW}⚠ Invalid JSON response format${RESET}"
    fi
else
    if [[ -z "$BEACON_HTTP_CODE" || "$BEACON_HTTP_CODE" == "000" ]]; then
        echo -e "${RED}✗ Unreachable (Connection Timeout)${RESET}"
    else
        echo -e "${RED}✗ Unreachable (HTTP $BEACON_HTTP_CODE)${RESET}"
    fi
fi

################################################################################
# Beacon Head Slot Check
################################################################################

HEAD=""
if [[ $BEACON_OK -eq 1 ]]; then
    HEAD_RESPONSE=$(curl -s --max-time 5 -w "\n%{http_code}" "$BEACON_RPC/eth/v1/beacon/headers/head")
    HEAD_HTTP_CODE=$(echo "$HEAD_RESPONSE" | tail -n1)
    HEAD_BODY=$(echo "$HEAD_RESPONSE" | sed '$d')
    if [[ "$HEAD_HTTP_CODE" == "200" ]]; then
        HEAD=$(echo "$HEAD_BODY" | jq -r '.data.header.message.slot' 2>/dev/null)
        [[ ! "$HEAD" =~ ^[0-9]+$ ]] && HEAD=""
    fi
fi

################################################################################
# Blob Sidecars Health Check (Last 10 Slots)
################################################################################

if [[ -n "$HEAD" ]]; then
    echo -e "\n● Blob Sidecars Check (Last 10 Slots)"
    TOTAL=10; SLOTS_WITH_BLOBS=0; TOTAL_BLOBS=0; BLOB_FETCH_ERRORS=0
    for ((i=0; i<TOTAL; i++)); do
        SLOT=$((HEAD-i))
        BLOB_RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 "$BEACON_RPC/eth/v1/beacon/blob_sidecars/$SLOT")
        BLOB_HTTP_CODE=$(echo "$BLOB_RESPONSE" | tail -n1)
        BLOB_BODY=$(echo "$BLOB_RESPONSE" | sed '$d')
        N=$(echo "$BLOB_BODY" | jq -r '.data | length' 2>/dev/null)
        if [[ "$BLOB_HTTP_CODE" == "200" && "$N" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "${GREEN}✓ Slot $SLOT: Fetch success, $N blob(s)${RESET}"
            ((SLOTS_WITH_BLOBS++)); ((TOTAL_BLOBS+=N))
        else
            echo -e "${RED}✗ Slot $SLOT: No blobs or fetch failed${RESET}"
            ((BLOB_FETCH_ERRORS++))
        fi
    done
    SUCCESS_RATE=$((SLOTS_WITH_BLOBS*100/TOTAL))
    if (( SUCCESS_RATE < 40 )); then STATUS="${RED}CRITICAL${RESET}"
    elif (( SUCCESS_RATE < 70 )); then STATUS="${YELLOW}WARNING${RESET}"
    else STATUS="${GREEN}HEALTHY${RESET}"; fi

    ############################################################################
    # Rate Limiting Test (100 Sequential Requests)
    ############################################################################

    echo -e "\n● Rate Limiting Check (100-req burst)"
    TARGET_ENDPOINT="$BEACON_RPC/eth/v1/beacon/blob_sidecars/head"
    REQS=100
    START_MS=$(date +%s%3N)
    HTTP_CODES=$(seq 1 $REQS | xargs -P$REQS -I{} \
        curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 "$TARGET_ENDPOINT")
    END_MS=$(date +%s%3N)
    ELAPSED_MS=$((END_MS - START_MS))
    ELAPSED_MS=${ELAPSED_MS:-1}
    REQS=${REQS:-1}
    RPS=$(gawk -v REQS="$REQS" -v ELAPSED_MS="$ELAPSED_MS" 'BEGIN { print REQS/(ELAPSED_MS/1000) }')
    RPS=${RPS:-0}
    if ! [[ "$RPS" =~ ^[0-9]+(\.[0-9]*)?$ ]]; then
        RPS=0
    fi
    if echo "$HTTP_CODES" | grep -q "429"; then
        RL_COUNT=$(echo "$HTTP_CODES" | grep -c "429")
        echo -e "${RED}✗ Rate limit detected ($RL_COUNT/$REQS HTTP 429)${RESET}"
    else
        echo -e "${GREEN}✓ No rate limiting detected${RESET}"
    fi
    echo "Completed in ${ELAPSED_MS} ms (~${RPS} req/sec)"

    ############################################################################
    # Performance Tier Assignment (Fun, Inspired)
    ############################################################################

    get_tier() {
        local rps="$1"
        [[ -z "$rps" ]] && echo "Tier C - Genin" && return
        rps=$(echo "$RPS" | tr ',' '.' | grep -Eo '[0-9]+(\.[0-9]*)?')
        rps=${rps:-0}
        if (( $(echo "$rps >= 200" | bc -l) )); then
            echo "Tier S - Kage"
        elif (( $(echo "$rps >= 100" | bc -l) )); then
            echo "Tier A - Jonin"
        elif (( $(echo "$rps >= 50" | bc -l) )); then
            echo "Tier B - Chunin"
        else
            echo "Tier C - Genin"
        fi
    }
    TIER_STRING=$(get_tier "$RPS")
fi

################################################################################
# Verdict Logic: Node Suitability & Performance Tier
################################################################################

if [[ ${SEPOLIA_OK:-0} -ne 1 || ${BEACON_OK:-0} -ne 1 ]]; then
    VERDICT="${RED}Not Suitable for Node${RESET}"
else
    if (( SUCCESS_RATE >= 70 )); then
        case "$TIER_STRING" in
            "Tier S - Kage") VERDICT="${GREEN}Enterprise – Kage Node${RESET}" ;;
            "Tier A - Jonin") VERDICT="${GREEN}Production – Jonin Node${RESET}" ;;
            "Tier B - Chunin") VERDICT="${CYAN}Stable – Chunin Node${RESET}" ;;
            "Tier C - Genin") VERDICT="${CYAN}Stable – Genin Node${RESET}" ;;
        esac
    elif (( SUCCESS_RATE >= 40 )); then
        case "$TIER_STRING" in
            "Tier S - Kage") VERDICT="${GREEN}Production – Kage Node${RESET}" ;;
            "Tier A - Jonin") VERDICT="${CYAN}Stable – Jonin Node${RESET}" ;;
            "Tier B - Chunin") VERDICT="${YELLOW}Unstable – Chunin Node${RESET}" ;;
            "Tier C - Genin") VERDICT="${YELLOW}Unstable – Genin Node${RESET}" ;;
        esac
    else
        VERDICT="${RED}Not Suitable${RESET}"
    fi
fi

################################################################################
# Final Summary Table
################################################################################

sep_equals
center_text "Summary"
sep_equals
echo -e "Sepolia RPC   : $( [[ ${SEPOLIA_OK:-0} -eq 1 ]] && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}" )"
echo -e "Beacon RPC    : $( [[ ${BEACON_OK:-0} -eq 1 ]] && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}" )"
[[ -n "$HEAD" ]] && echo -e "Blob Health   : $STATUS"
[[ -n "$HEAD" ]] && echo -e "RPS Tier      : ${TIER_STRING}"
[[ -n "$HEAD" ]] && echo -e "Blob Success  : $SLOTS_WITH_BLOBS/$TOTAL slots (${SUCCESS_RATE}%)"
[[ -n "$HEAD" ]] && echo -e "Total Blobs   : $TOTAL_BLOBS"
[[ -n "$HEAD" ]] && echo -e "Blob Errors   : $BLOB_FETCH_ERRORS/$TOTAL"
sep_dashes
echo -e "RPS Tiers:"
echo -e "S ≥ 200       (Kage)"
echo -e "A = 100-199   (Jonin)"
echo -e "B = 50-99     (Chunin)"
echo -e "C < 50        (Genin)"
sep_equals
echo -e "Verdict : $VERDICT"
sep_equals
