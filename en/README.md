# 🛰️ Sepolia Node Installer

🇷🇺 [for Russian](https://github.com/pittpv/sepolia-auto-install/blob/main/ "Russian version of description")

![First screen](https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/other/img-en-2025-05-22-15-29-52.png)

An interactive bash script for installing, managing, and monitoring an Ethereum Sepolia node with support for consensus client selection (Prysm (recommended), Lighthouse, Teku), sync monitoring, Telegram integration, and an optional cron-based monitoring agent. Geth is used as the execution client.

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
* 🔥 Firewall Management

## ⚙️ Requirements

* `docker` and `docker-compose`
* `curl`, `jq`
* `bash` ≥ 4.0

**Update from 21.05.2025**: All prerequisites can now be installed automatically by selecting option 1 in the menu. This will update the system and current applications, install Docker, Docker Compose, and other required utilities. After installation, the system will be cleaned of installation cache and unused packages.

> I recommend using step 1 even if you have Docker. The script will skip installing the components you have. After upgrading your system, **check** if your old containers and other nodes are still running.

### 🖥️ System Requirements

| Component          | Requirement                              |
|--------------------|-------------------------------------------|
| **OS**             | Ubuntu 20.04 or later                     |
| **RAM**            | 8–16 GB                                   |
| **CPU**            | 4–6 cores                                 |
| **Disk**           | 550 GB SSD (can grow up to 1.5 TB)        |

## 🚀 Installation & Run

```bash
curl -o install_sepolia.sh https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/install_sepolia.sh
chmod +x install_sepolia.sh
./install_sepolia.sh
````

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
11. Check disk usage
12. Firewall management
13. Exit

## 🔐 Telegram Notifications

The script includes a cron-agent that monitors node status and sends alerts via Telegram.

### Setup:

1. Get a Telegram bot token from [BotFather](https://t.me/BotFather)
2. Find your `chat_id` using [IDBot](https://t.me/myidbot) or similar
3. Enter the token and chat\_id during cron-agent setup

Choose the notification interval:

* Every 5, 10, 15, 30 minutes, or hourly

## 🧠 Supported Consensus Clients

* **Prysm** (Recommended)
* **Lighthouse**
* **Teku**

## 📡 Sync Monitoring

The script displays:

* Current and target block
* Sync progress (%)
* Sync speed (blocks/sec)
* Estimated time remaining
* Completion status

## 🔗 RPC links

* RPC URL: `http://localhost:8545`
* BEACON RPC URL: `http://localhost:5052`

replace localhost with the IP address of your server.

Вот блок с описанием функционала настройки файрволла в формате **Markdown**, с описанием **на английском** и **на русском** языках:

---

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

### Example Prompts

* ✅ Confirmation message when UFW is already enabled.
* ❌ Message when enabling is cancelled by the user.
* 🔒 Only enables UFW if not already active.

## 🗑️ Removal

The removal option completely wipes all node data and containers. Confirmation is required.

## 📄 License

MIT License. Use at your own risk.

## ✍️ Feedback

Any questions, bug report or feedback:

https://t.me/+DLsyG6ol3SFjM2Vk
