# Firewall Management Function - User Guide

## Overview

The `firewall_setup` function provides an interactive menu for managing firewall rules using `iptables` (DOCKER-USER chain) and `ufw`. Particularly useful in Docker environments where network access control needs to be managed while maintaining UFW compatibility.

## Capabilities

- Dual management of iptables (DOCKER-USER chain) and UFW
- Port management (open/close/block)
- IP address management (allow/deny)
- Rule viewing and statistics
- Complete rule reset
- Color interface for better visibility

## Initial Setup

Before use:

1. First run **Option 1** to:
    - Check/create DOCKER-USER chain
    - Configure FORWARD -> DOCKER-USER transition
    - Enable and configure UFW with basic SSH access

2. Then use **Option 2 → Block RPC and BEACON ports** to:
    - Protect default RPC ports
    - Configure UFW to block all incoming connections

Don't forget to open the ports required for the node to work. For example, for Aztec: **8080**,**40400**

## Main Menu Options

### 1. System Initialization (`Option 1`)
- **What it does**:
    - Checks and creates special `DOCKER-USER` chain in iptables
    - Configures integration between `FORWARD` and `DOCKER-USER` chains
    - Activates UFW (Uncomplicated Firewall) with basic settings

- **When to use**:
    - On first script run
    - After system reinstallation
    - After rule reset (following option 5)

- **Important**: Automatically allows SSH access (port 22) before UFW activation

### 2. Port Management (`Option 2`)
#### Opening ports:
1. Enter port number (or multiple comma-separated)
2. Select direction:
    - `1` - Incoming connections
    - `2` - Outgoing connections
    - `3` - Both directions
3. Select protocol:
    - `1` - TCP
    - `2` - UDP
    - `3` - Both protocols

#### Closing ports:
- Three removal options:
    1. iptables only
    2. UFW only
    3. Both simultaneously
- Supported formats:
    - Single numbers: `5`
    - Lists: `3,7,12`
    - Ranges: `10-15`
    - Combinations: `1,5-8,12`

#### RPC port blocking:
- Automatically blocks standard RPC ports
- Changes UFW policy to `deny incoming`

### 3. IP Address Management (`Option 3`)
#### Allowing access:
1. Enter IP/subnet (multiple comma-separated allowed)
2. Optionally specify port(s)
3. Select direction and protocol (similar to ports)

#### Rule removal:
- Similar to port rule removal
- Shows IP-bound rules before deletion

### 4. View Rules (`Option 4`)
- Displays in convenient format:
    - All iptables rules in DOCKER-USER chain
    - All active UFW rules
    - Rule type statistics
    - Current default policies

### 5. Reset Rules (`Option 5`)
**Dangerous operation** - requires confirmation:
1. Completely clears DOCKER-USER chain
2. Resets all UFW rules
3. Restarts Docker service

## Workflow

1. **Initial setup**:
    - Always start with `Option 1` (initialization)
    - Then configure required ports via `Option 2`

2. **Regular use**:
    - For temporary access use `Option 3` (IP addresses)
    - For verification - `Option 4` (view rules)

3. **Errors/reset**:
    - For issues use `Option 5` (full reset)
    - Repeat initialization (`Option 1`)

## Interface Features

- **Interrupt support in port and IP management functions**:
    - Pressing Ctrl+C then Enter during port/IP input returns to previous menu
    - Does not terminate script execution
