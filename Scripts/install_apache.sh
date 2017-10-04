until $(curl --output /dev/null --silent --head --fail https://www.google.com); do
    printf '.'
    sleep 10
done
apt-get update -y
apt-get install -y apache2
