curl https://releases.hashicorp.com/terraform/0.10.2/terraform_0.10.2_linux_amd64.zip?_ga=2.65112300.312705479.1503001349-2068154971.1493399709 > terraform.zip
sudo yum install -y unzip git
sudo unzip terraform.zip
sudo mv terraform /usr/sbin/
sudo chmod +x /usr/sbin/terraform
sudo rm terraform.zip
sudo git clone https://github.com/PaloAltoNetworks/terraform-templates
(cd /home/terraform-templates/one-click-multi-cloud/one-click-aws; terraform init)
(cd /home/terraform-templates/one-click-multi-cloud/one-click-azure; terraform init)
sudo git clone https://github.com/PaloAltoNetworks/ansible-playbooks
sudo yum install -y ansible
sudo ansible-galaxy install PaloAltoNetworks.paloaltonetworks
sudo yum install -y epel-release
sudo yum -y install python-pip
sudo /usr/bin/pip2 install pan-python
sudo /usr/bin/pip2 install pandevice
sudo /usr/bin/pip2 install xmltodict
sudo pip install --upgrade pip
export PYTHONHTTPSVERIFY=0
curl https://raw.githubusercontent.com/kblackstone/PaloAltoNetworks/master/Ansible/testplaybook.yml
