#!/bin/bash
export REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region)
sudo yum install -y https://s3.$REGION.amazonaws.com/amazon-ssm-$REGION/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# temp config to sate the LB
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
docker run --detach -p 25565:80 nginx
