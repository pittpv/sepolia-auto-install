#!/bin/bash

# Color definitions (headings only)
BLUE='\e[0;34m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
RED='\e[0;31m'
RESET='\e[0m'

source $HOME/sepolia-node/port_config.env

# ======= RPC HEALTH GUIDE =======
echo -e "\n${BLUE}========================================"
echo "              RPC Health Guide"
echo -e "========================================${RESET}"
echo "200 : OK"
echo "400 : Bad Request"
echo "401 : Unauthorized"
echo "403 : Forbidden"
echo "404 : Not Found"
echo "413 : Payload Too Large"
echo "26  : Call Address Error"
echo "429 : Too Many Requests"
echo "500 : Internal Error"
echo "503 : Unavailable"
echo "Unreachable : Node/network unreachable"

# ======= ETHEREUM NODE HEALTH CHECKER =======
echo -e "\n${BLUE}========================================"
echo "        ETHEREUM NODE HEALTH CHECKER"
echo -e "========================================${RESET}"


read -p "Use localhost (127.0.0.1) or external IP? [Choose l or i]: " choice

if [[ "$choice" =~ ^[Ll]$ ]]; then
  HOST="127.0.0.1"
elif [[ "$choice" =~ ^[Ii]$ ]]; then

  IP=$(curl -s https://api.ipify.org)
  if [[ -z "$IP" ]]; then
    echo -e "${RED}Failed to get external IP${NC}"
    exit 1
  fi
  HOST="$IP"
else
  echo -e "${RED}Invalid choice. Please use 'l' or 'i'.${NC}"
  exit 1
fi

EXEC_RPC="http://$HOST:$EXECUTION_RPC_PORT"
BEACON_RPC="http://$HOST:$CONSENSUS_RPC_PORT"

echo "Execution Layer RPC: $EXEC_RPC"
echo "Beacon Node RPC:     $BEACON_RPC"

echo -e "\n${CYAN}--- Your Execution RPC ---${NC}"
echo -e "\n${NC}$EXEC_RPC${NC}"
echo -e "\n${CYAN}--- Your Beacon RPC ---${NC}"
echo -e "\n${NC}$BEACON_RPC${NC}"

echo -e "\n● Execution RPC Check"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$EXEC_RPC" -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
if [[ "$HTTP_CODE" == "200" ]]; then
  BLOCKNUM=$(echo "$BODY" | jq -r '.result' 2>/dev/null)
  if [[ "$BLOCKNUM" != "null" && "$BLOCKNUM" != "" ]]; then
    DEC_BLOCKNUM=$((16#${BLOCKNUM:2}))
    echo -e "${GREEN}✓ Healthy${RESET} (Block: ${DEC_BLOCKNUM})"
    EXEC_OK=1
  else
    echo -e "${RED}✗ Unhealthy${RESET}"
    EXEC_OK=0
  fi
else
  echo -e "${RED}✗ Unreachable (HTTP $HTTP_CODE)${RESET}"
  EXEC_OK=0
fi

echo -e "\n● Beacon Node Check"
BEACON_RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 5 "$BEACON_RPC/eth/v1/node/version")
BEACON_HTTP_CODE=$(echo "$BEACON_RESPONSE" | tail -n1)
BEACON_BODY=$(echo "$BEACON_RESPONSE" | sed '$d')

if [[ "$BEACON_HTTP_CODE" == "200" ]]; then
  VER=$(echo "$BEACON_BODY" | jq -r '.data.version' 2>/dev/null)
  if [[ "$VER" && "$VER" != "null" ]]; then
    echo -e "${GREEN}✓ Reachable${RESET} (Version: ${VER})"
    BEACON_OK=1
  else
    echo -e "${YELLOW}⚠ Invalid JSON response format${RESET}"
    BEACON_OK=0
  fi
else
  echo -e "${RED}✗ Unreachable (HTTP $BEACON_HTTP_CODE)${RESET}"
  BEACON_OK=0
fi

HEAD=""
if [[ $BEACON_OK -eq 1 ]]; then
  HEAD_RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 5 "$BEACON_RPC/eth/v1/beacon/headers/head")
  HEAD_HTTP_CODE=$(echo "$HEAD_RESPONSE" | tail -n1)
  HEAD_BODY=$(echo "$HEAD_RESPONSE" | sed '$d')
  if [[ "$HEAD_HTTP_CODE" == "200" ]]; then
    HEAD=$(echo "$HEAD_BODY" | jq -r '.data.header.message.slot' 2>/dev/null)
    if ! [[ "$HEAD" =~ ^[0-9]+$ ]]; then
      echo -e "${YELLOW}⚠ Failed to get head slot${RESET}"
      HEAD=""
    fi
  else
    echo -e "${YELLOW}⚠ Failed to get head slot (HTTP $HEAD_HTTP_CODE)${RESET}"
    HEAD=""
  fi
fi

if [[ -n "$HEAD" ]]; then
  echo -e "\n● Blob Sidecars Check (Last 10 Slots)"
  TOTAL=10
  SLOTS_WITH_BLOBS=0
  ERRORS=0
  TOTAL_BLOBS=0
  for ((i=0; i<10; i++)); do
    SLOT=$((HEAD-i))
    BLOB_RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 "$BEACON_RPC/eth/v1/beacon/blob_sidecars/$SLOT")
    BLOB_HTTP_CODE=$(echo "$BLOB_RESPONSE" | tail -n1)
    BLOB_BODY=$(echo "$BLOB_RESPONSE" | sed '$d')
    if [[ "$BLOB_HTTP_CODE" == "200" ]]; then
      N=$(echo "$BLOB_BODY" | jq -r '.data | length' 2>/dev/null)
      if [[ "$N" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "${GREEN}✓ Slot $SLOT: $N blob(s)${RESET}"
        ((SLOTS_WITH_BLOBS++))
        ((TOTAL_BLOBS+=N))
      else
        echo -e "${YELLOW}⚠ Slot $SLOT: No blobs${RESET}"
      fi
    elif [[ "$BLOB_HTTP_CODE" == "404" ]]; then
      echo -e "${YELLOW}⚠ Slot $SLOT: Not found${RESET}"
      ((ERRORS++))
    else
      echo -e "${RED}✗ Slot $SLOT: Error (HTTP $BLOB_HTTP_CODE)${RESET}"
      ((ERRORS++))
    fi
  done

  SUCCESS_RATE=$(awk -v s="$SLOTS_WITH_BLOBS" -v t="$TOTAL" 'BEGIN { printf "%.2f", (s/t)*100 }')
  if (( $(echo "$SUCCESS_RATE < 25" | bc -l) )); then
    STATUS="${RED}CRITICAL${RESET}"
  elif (( $(echo "$SUCCESS_RATE < 75" | bc -l) )); then
    STATUS="${YELLOW}WARNING${RESET}"
  else
    STATUS="${GREEN}HEALTHY${RESET}"
  fi
fi

echo -e "\n${BLUE}========== Summary ==========${RESET}"
printf "Execution RPC : %b\n" "$([[ ${EXEC_OK:-0} -eq 1 ]] && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}")"
printf "Beacon RPC    : %b\n" "$([[ ${BEACON_OK:-0} -eq 1 ]] && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}")"
if [[ -n "$HEAD" ]]; then
  printf "Blob Success  : %d/%d slots (%.2f%%) -> %b\n" "$SLOTS_WITH_BLOBS" "$TOTAL" "$SUCCESS_RATE" "$STATUS"
  printf "Total Blobs   : %d (Errors: %d)\n" "$TOTAL_BLOBS" "$ERRORS"
fi

echo -e "\nThreshold Guide: ${GREEN}HEALTHY: ≥75%${RESET} | ${YELLOW}WARNING: 25%-75%${RESET} | ${RED}CRITICAL: <25%${RESET}"
