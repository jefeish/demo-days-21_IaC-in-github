#! /bin/bash

# --- Some support tools -------------------------------------------------------
apt install -y jq
apt install -y git

# --- Install AWS CLI ----------------------------------------------------------
apt-get update
apt-get install -y python python-pip
pip install awscli

# --- Install SSM Agent --------------------------------------------------------
mkdir -p /tmp/ssm
cd /tmp/ssm
# download the ssm-agent
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
# install the ssm-agent
dpkg -i amazon-ssm-agent.deb
# determine if SSM Agent is running
systemctl status amazon-ssm-agent

# ------------------------------------------------------------------------------
aws configure set region ${region}

# ------------------------------------------------------------------------------
# Install the license (enterprise.ghl)
# ------------------------------------------------------------------------------
# aws s3 cp s3://ghes-license-bucket/license/license.ghl /tmp/license.ghl

# ------------------------------------------------------------------------------
# Wait for admin port to open
# ------------------------------------------------------------------------------
while ! nc -z localhost 8443; do   
  sleep 30 # wait for 30 seconds before checking again
done

# ------------------------------------------------------------------------------
# Initial GHE instance config
# ------------------------------------------------------------------------------
cat > /tmp/settings.json <<EOF
{
  "private_mode": false,
  "signup_enabled": true,
  "github_ssl": {
    "enabled": false,
    "cert": null,
    "key": null
  },
  "auth_mode": "default"
}
EOF

# open the database port
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

curl --fail -Lk \      
      -X POST "https://localhost:8443/setup/api/start" \
      -F "license=@/tmp/license.ghl" \
      -F "password=P@ssw0rd" \
      -F "settings=</tmp/settings.json"

# ------------------------------------------------------------------------------
# Safe the Management console settings (this usually takes a while)
# ------------------------------------------------------------------------------
ghe-config-apply
