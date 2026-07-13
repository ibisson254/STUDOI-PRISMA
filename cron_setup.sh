#!/usr/bin/env bash
ssh -i C:/Users/Ibisson/.ssh/id_ed25519_prisma root@161.35.19.139 << 'EOF'
echo "0 3 * * * /root/scripts/backup-n8n.sh >> /var/log/n8n-backup.log 2>&1" > /tmp/cron.txt
crontab /tmp/cron.txt
crontab -l
EOF
