#!/bin/bash
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello ${name}</h1>" > /var/www/html/index.html
