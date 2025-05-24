RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}=== Ethereum Node Health & Blob Checker ===${NC}"
EXEC_RPC=http://localhost:8545
BEACON_RPC=http://localhost:5052

echo -e "\n${CYAN}--- Your Execution RPC ---${NC}"
echo -e "\n${NC}$EXEC_RPC${NC}"
echo -e "\n${CYAN}--- Your Beacon RPC ---${NC}"
echo -e "\n${NC}$BEACON_RPC${NC}"

echo -e "\n${CYAN}--- Checking Execution RPC ---${NC}"
BLOCKNUM=$(curl -s -X POST "$EXEC_RPC" -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r .result)
if [[ "$BLOCKNUM" != "null" && "$BLOCKNUM" != "" ]]; then
  DEC_BLOCKNUM=$((16#${BLOCKNUM:2}))
  echo -e "${GREEN}✓ Healthy${NC} (Block: ${CYAN}$DEC_BLOCKNUM${NC})"; EXEC_OK=1
else
  echo -e "${RED}✗ Unhealthy${NC}"; EXEC_OK=0
fi

echo -e "\n${CYAN}--- Checking Beacon Node ---${NC}"
VER=$(curl -s --max-time 5 "$BEACON_RPC/eth/v1/node/version" | jq -r .data.version)
[[ "$VER" && "$VER" != "null" ]] && { echo -e "${GREEN}✓ Reachable${NC} (Version: ${CYAN}$VER${NC})"; BEACON_OK=1; } || { echo -e "${RED}✗ Unreachable${NC}"; BEACON_OK=0; }

HEAD=$(curl -s --max-time 5 "$BEACON_RPC/eth/v1/beacon/headers/head" | jq -r .data.header.message.slot)
if [[ "$HEAD" =~ ^[0-9]+$ ]]; then
  echo -e "\n${CYAN}-- Blob Sidecars: Last 10 Slots --${NC}"
  TOTAL=10; SLOTS_WITH_BLOBS=0; ERRORS=0; TOTAL_BLOBS=0
  for ((i=0; i<10; i++)); do
    SLOT=$((HEAD-i)); TRY=0; BLOB_COUNT=0
    while ((TRY<3)); do
      RESP=$(curl -s --max-time 10 "$BEACON_RPC/eth/v1/beacon/blob_sidecars/$SLOT")
      CODE=$(echo "$RESP" | jq -r '.code // 200' 2>/dev/null)
      JQ_EXIT=$?
      
      if [[ $JQ_EXIT -ne 0 ]]; then
        ((TRY++))
        sleep 2
        continue
      fi

      case $CODE in
        200)
          N=$(echo "$RESP" | jq -r '.data | length')
          if [[ "$N" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "${GREEN}✓ Slot $SLOT: $N blob(s)${NC}"
            ((SLOTS_WITH_BLOBS++))
            ((TOTAL_BLOBS+=N))
            break
          else
            echo -e "${YELLOW}⚠ Slot $SLOT: No blobs${NC}"
            break
          fi
          ;;
        404|500|*) 
          echo -e "${RED}✗ Slot $SLOT: Error ${CODE}${NC}"
          ((ERRORS++))
          break
          ;;
      esac
    done
    ((TRY==3)) && { echo -e "${RED}✗ Slot $SLOT: Failed after 3 retries${NC}"; ((ERRORS++)); }
  done
  
  # Calculate true success rate (only slots with blobs)
  SUCCESS_RATE=$(awk -v s="$SLOTS_WITH_BLOBS" -v t="$TOTAL" 'BEGIN { printf "%.2f", (s/t)*100 }')
  
  # Determine status
  if (( $(echo "$SUCCESS_RATE < 25" | bc -l) )); then STATUS="${RED}CRITICAL${NC}"
  elif (( $(echo "$SUCCESS_RATE < 75" | bc -l) )); then STATUS="${YELLOW}WARNING${NC}"
  else STATUS="${GREEN}HEALTHY${NC}"; fi
fi

echo -e "\n${CYAN}=== Summary ===${NC}"
[[ $EXEC_OK -eq 1 ]] && echo -e "Execution RPC: ${GREEN}OK${NC}" || echo -e "Execution RPC: ${RED}FAIL${NC}"
[[ $BEACON_OK -eq 1 ]] && echo -e "Beacon RPC: ${GREEN}OK${NC}" || echo -e "Beacon RPC: ${RED}FAIL${NC}"
if [[ "$HEAD" =~ ^[0-9]+$ ]]; then
  echo -e "Blob Success: ${SLOTS_WITH_BLOBS}/${TOTAL} slots (${SUCCESS_RATE}%) -> $STATUS"
  echo -e "Total Blobs Found: ${TOTAL_BLOBS} (Errors: ${ERRORS})"
fi
echo -e "\n${CYAN}Threshold Guide:${NC}"
echo -e "${GREEN}HEALTHY: ≥75%${NC} | ${YELLOW}WARNING: 25%-75%${NC} | ${RED}CRITICAL: <25%${NC}"
