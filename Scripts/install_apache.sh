until $(curl --output /dev/null --silent --head --fail https://www.google.com); do
    printf '.'
    sleep 10
done
sudo apt-get update -y
sudo apt-get install -y apache2
