#!/bin/bash
sudo apt-get update
sudo apt-get install software-properties-common -y
sudo apt-get install python-pip -y
pip install --upgrade pip
pip install ansible
ansible-galaxy install PaloAltoNetworks.paloaltonetworks
wget https://pypi.python.org/packages/12/f8/63bcaa57be2c6c9b1c18035316463ae211e1d6b0ec98146eebe48af4f80f/pan-python-0.12.0.tar.gz
sudo tar xzf pan-python*.tar.gz
wget https://pypi.python.org/packages/da/63/ebb7c707ecea80454384983c9c0eaf718667a7e9f72bc453efe00ffa3536/pandevice-0.5.0.tar.gz
sudo tar xzf pandevice*.tar.gz
pip install xmltodict
