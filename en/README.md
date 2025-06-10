# 🛰️ Sepolia RPC Node Installer All in one

🇷🇺 [for Russian](https://github.com/pittpv/sepolia-auto-install/blob/main/ "Russian version of description")

![First screen](https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/other/img-en-2025-05-22-15-29-52.png)

An interactive bash script for installing, managing and monitoring an Ethereum Sepolia node with support for choosing an execution client (Geth (recommended), Reth, Nethermind) and a consensus client (Prysm (recommended), Lighthouse, Teku), synchronization monitoring and a cron agent with notifications about the node's status in Telegram.

## 📦 Features

* 📦 System update and prerequisites install
* 🔧 Install and run Sepolia node with selected consensus client
* 🐳 Automatically generate `docker-compose.yml`
* 📊 Check sync status (execution and consensus)
* 📋 View logs
* 🔄 Update containers
* 🛑 Stop/start containers
* 🧹 Remove the node
* 💽 Analyze disk usage
* 📡 Install cron-agent with Telegram status notifications
* 🔥 Advanced Firewall Management
* 🌐 RPC and blob data check. Script created by `creed2412` (discord)

## ⚙️ Requirements

* `docker` and `docker-compose`
* `curl`, `jq`
* `bash` ≥ 4.0

All prerequisites can be installed automatically by selecting option 1 in the menu. This will update the system and current applications, install Docker, Docker Compose, and other required utilities. After installation, the system will be cleaned of installation cache and unused packages.

> I recommend using step 1 even if you have Docker. The script will skip installing the components you have. After upgrading your system, **check** if your old containers and other nodes are still running.

### 🖥️ System Requirements

| Component          | Requirement                              |
|--------------------|-------------------------------------------|
| **OS**             | Ubuntu 20.04 or later                     |
| **RAM**            | 8–16 GB                                   |
| **CPU**            | 4–8 cores                                 |
| **Disk**           | 600 GB SSD (can grow up to 1.5 TB)        |

## 📌 Latest Updates 09-06-2025
- Added the ability to select Execution client. Geth, Reth, Nethermind.
- Added ability to assign a port during installation. Default for execution 8545, consensus 5052.
- Added ability to assign a port to previously installed node. 
- Significantly expanded firewall management options.
- For Reth and Nethermind implemented their own mechanisms to control the synchronization process. To get correct data, do the first check 3-5 minutes after clients start.
- When a node is deleted, the cron task is also deleted
- Verification of Telegram token and ChatID is implemented. Notifications are improved.
- Added updated version of Creed RPC verification script
- Improved RPC check script to be compatible with both versions of Sepolia Auto Install, it is also possible to select localhost or external ip check.
- Minor improvements

---

<details>
<summary>📅 Version History</summary>

### 24-05-2025
- Added RPC Check script by Creed 

### 23-05-2025
- Added firewall managment

### 21-05-2025
- Added automatic installation of dependencies

### 20-05-2025
- Language compatibility for welcome message.
- Prysm docker-compose file fix.

### 19-05-2025
- Fix for telegram notofications
</details>

## 🚀 Installation & Run

**Launch or Update**

```bash
curl -o install_sepolia.sh https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/install_sepolia.sh && chmod +x install_sepolia.sh && ./install_sepolia.sh
````

For future runs:

```bash
cd $HOME && ./install_sepolia.sh
```

After installing the node, wait for the full synchronization. The synchronization will be complete only when you see "✅ Execution synchronized" when you query the synchronization status. Otherwise, even if you see 100%, the synchronization is not yet complete.

## 📋 Main Menu

The script offers the following menu (available in English or Russian):

1. Install requirements (Docker, etc.)
2. Install node
3. Update containers
4. View logs
5. Check sync status
6. Set up cron agent with Tg notifications
7. Remove cron agent
8. Stop containers
9. Start containers
10. Delete node
11. Change ports for installed node
12. Check disk usage
13. Firewall management
14. Check RPC server
0. Exit

## 🔐 Telegram Notifications

The script includes a cron-agent that monitors node status and sends alerts via Telegram.

### Setup:

1. Get a Telegram bot token from [BotFather](https://t.me/BotFather)
2. Find your `chat_id` using [IDBot](https://t.me/myidbot) or similar
3. Enter the token and chat\_id during cron-agent setup

Choose the notification interval:

* Every 5, 10, 15, 30 minutes, or hourly

## 🧠 Supported Clients

The following configurations have been tested:

| Execution / Consensus  | Prysm     | Teku      | Lighthouse                                              |
|------------------------|-----------|-----------|---------------------------------------------------------|
| **Geth**               | ✅  | ✅   | ⚠️ |
| **Reth**               | ✅  | ✅   | ✅                                          |
| **Nethermind**         | ✅  | ✅   | ✅                                         |

**Legend:**

* ✅ — works with default ports / works with custom ports
* ⚠️ — works, but requires consensus client P2P port modification, must be changed from 9000

## 📡 Sync Monitoring

Depending on the client, a different algorim is used to display the synchronization status.

### Execution Client Sync Status Capabilities

The script displays:

| Feature                           | Geth | Reth | Nethermind |
|-----------------------------------|------|------|------------|
| Current & Target Block            | ✅   | ✅   | ✅         |
| Sync Progress (%)                 | ✅   | ✅   | ✅         |
| Sync Stage                        | ❌   | ✅   | ✅         |
| Sync Speed (blocks/sec)          | ✅   | ❌   | ❌         |
| Estimated Time to Completion     | ✅   | ❌   | ❌         |
| Sync Completed Status            | ✅   | ✅   | ✅         |

### Consensus Client Sync Status Capabilities

The script displays:

| Feature                       | Prysm | Teku | Lighthouse |
|-------------------------------|-------|------|------------|
| Current & Target Block        | ✅    | ✅   | ✅         |
| Sync In Progress              | ✅    | ✅   | ✅         |
| Sync Completed Status         | ✅    | ✅   | ✅         |

## 🔗 RPC links

* RPC URL: `http://localhost:8545` (default port is `8545`, or another port you set)
* BEACON RPC URL: `http://localhost:5052` (default port is `5052`, or another port you set)

replace localhost with the IP address of your server.

## 🔥 Firewall Management

This feature adds a menu to manage the UFW (Uncomplicated Firewall) on your server. It helps secure your node by controlling access to important ports.

### Menu Options

1. **Enable Firewall**
   Opens SSH ports (22, `ssh`) and enables UFW if it's not already enabled.
   A confirmation prompt (`y/n`) is shown before activation.

2. **Allow Local Ports**
   Useful when your node client (e.g. Aztec Sequencer) is running locally.
   Opens Geth P2P ports and allows access to RPC and Beacon ports from `127.0.0.1`.

3. **Allow Specific IPs**
   Useful when your node client is running on another server.
   Opens Geth ports to the public, blocks sensitive ports (8545, 5052), and allows them **only** from a trusted IP that you input.
   
4. **Remove Rules for Ports**
   Here you can see which ports have been set previously and remove rules. To delete all rules, you need to delete **multiple times** until all necessary rules are deleted. 

5. **View UFW Rules**
   Allows you to view all installed rules.

6. **Disable Firewall**

### Example Prompts

* ✅ Confirmation message when UFW is already enabled.
* ❌ Message when enabling is cancelled by the user.
* 🔒 Only enables UFW if not already active.

## 🌐 RPC and Blob Data Check

The function checks RPC availability and the presence of blob data for the last slots

🔍 What the check does:

* Detects the server's external IP address
* Checks availability of Execution RPC (`:8545`) and Beacon RPC (`:5052`)
* Requests the latest block and client version
* Verifies the presence of blob data for the last 10 slots

✅ Status is determined by the percentage of slots containing blob data:

* `HEALTHY`: ≥75%
* `WARNING`: 25–74%
* `CRITICAL`: <25%

Useful for diagnosing and ensuring that the node correctly processes data with EIP-4844 (blobs).

## 🗑️ Removal

The removal option completely wipes all node data and containers. Confirmation is required.

## 📄 License

MIT License. Use at your own risk.

## ✍️ Feedback

Any questions, bug report or feedback:

https://t.me/+DLsyG6ol3SFjM2Vk
