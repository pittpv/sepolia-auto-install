# Upgrade Instructions from Version 1.7.4 to Version 1.8.0

## ⚠️ Important Recommendations

**It is strongly recommended to perform a full removal and fresh installation of the node!**
This is the most reliable way to avoid compatibility issues.

If a full removal is not possible, follow the instructions below.

## 🔄 Step-by-Step Upgrade Guide

### 1. Update the script to the latest version

```bash
curl -o install_sepolia.sh https://raw.githubusercontent.com/pittpv/sepolia-auto-install/main/install_sepolia.sh && chmod +x install_sepolia.sh && ./install_sepolia.sh
```

### 2. Go to the node directory

```bash
cd /root/sepolia-node/
```

### 3. Edit docker-compose.yml

It is better to edit this file in an external editor, otherwise use `nano`.

Open the file for editing:

```bash
nano /root/sepolia-node/docker-compose.yml
```

**Delete the following sections:**

**For the execution client (geth/reth/nethermind):**

```yaml
    deploy:
      resources:
        limits:
          memory: 18G
          cpus: '4.0'
        reservations:
          memory: 12G
          cpus: '4.0'
```

**For the consensus client (lighthouse/prysm/teku):**

```yaml
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '2.0'
        reservations:
          memory: 4G
          cpus: '2.0'
```

**Make sure the changes were saved!**

### 4. Remove the resource configuration file

```bash
rm -f /root/sepolia-node/resource_config.env
```

### 5. Delete the consensus client folder

Run the command corresponding to your consensus client:

**For Prysm:**

```bash
rm -rf /root/sepolia-node/prysm/
```

**For Lighthouse:**

```bash
rm -rf /root/sepolia-node/lighthouse/
```

**For Teku:**

```bash
rm -rf /root/sepolia-node/teku/
```

### 6. Check the script version

Run the updated management script and ensure that version **1.8.0** or higher is displayed.

### 7. Configure new resource limits

In the script menu, select option **15** and set the new resource limits.

**When asked, enter:** `yes`

### 8. Update the node (recommended)

If you haven’t updated the node for a long time, run option **3** to update the containers.

### 9. Configure monitoring

Set up Telegram notifications (option 6) and monitor the beacon chain distance in the notifications.

## 📊 Minimum System Requirements

* **RAM:** 24 GB
* **CPU:** 8 cores
* **Storage:** SSD with sufficient free space
