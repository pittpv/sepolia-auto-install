# 🛰️ Sepolia Node Installer

🇷🇺 [for Russian](https://github.com/pittpv/sepolia-auto-install/blob/main/ "Russian version of description")

⚠️ [Before running the script, install dependencies](https://github.com/pittpv/sepolia-auto-install/tree/main/en#%EF%B8%8F-requirements)

![First screen](https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/other/img-2025-05-19-20-19-38.png)

An interactive bash script for installing, managing, and monitoring an Ethereum Sepolia node with support for consensus client selection (Prysm (recommended), Lighthouse, Teku), sync monitoring, Telegram integration, and an optional cron-based monitoring agent. Geth is used as the execution client.

## 📦 Features

* 🔧 Install and run Sepolia node with selected consensus client
* 🐳 Automatically generate `docker-compose.yml`
* 📊 Check sync status (execution and consensus)
* 📋 View logs
* 🔄 Update containers
* 🛑 Stop/start containers
* 🧹 Remove the node
* 💽 Analyze disk usage
* 📡 Install cron-agent with Telegram status notifications

## ⚙️ Requirements

* `docker` and `docker-compose`
* `curl`, `jq`
* `bash` ≥ 4.0

Dependency installation guide: [see here](https://github.com/pittpv/sepolia-auto-install/blob/main/en/Install-Dependecies.md "How to install Docker and other dependencies")

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

1. Install node
2. Update containers
3. View logs
4. Check sync status
5. Install cron-agent with Tg notifications
6. Remove cron-agent
7. Stop containers
8. Start containers
9. Remove node
10. Check disk usage
11. Exit

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

## 🗑️ Removal

The removal option completely wipes all node data and containers. Confirmation is required.

## 📄 License

MIT License. Use at your own risk.
