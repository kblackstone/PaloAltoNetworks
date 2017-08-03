sudo apt-get --assume-yes update
sudo apt-get --assume-yes install apache2
sudo curl https://raw.githubusercontent.com/kblackstone/PaloAltoNetworks/master/Terraform/helloworld.html > /var/www/html/index.html
