curl https://releases.hashicorp.com/terraform/0.10.2/terraform_0.10.2_linux_amd64.zip?_ga=2.65112300.312705479.1503001349-2068154971.1493399709 > terraform.zip
yum install -y unzip git
unzip terraform.zip
mv terraform /usr/sbin/
chmod +x /usr/sbin/terraform
rm terraform.zip
git clone https://github.com/PaloAltoNetworks/terraform-templates
(cd /home/terraform-templates/one-click-multi-cloud/one-click-aws; terraform init)
(cd /home/terraform-templates/one-click-multi-cloud/one-click-azure; terraform init)
git clone https://github.com/PaloAltoNetworks/ansible-playbooks
yum install -y ansible
ansible-galaxy install PaloAltoNetworks.paloaltonetworks
yum install -y epel-release
yum -y install python-pip
/usr/bin/pip2 install pan-python
/usr/bin/pip2 install pandevice
/usr/bin/pip2 install xmltodict
pip install --upgrade pip
export PYTHONHTTPSVERIFY=0
wget https://raw.githubusercontent.com/kblackstone/PaloAltoNetworks/master/Ansible/testplaybook.yml
