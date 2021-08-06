<VirtualHost *:80>
    ServerName [example.com]
    ServerAlias [www.example.com]
    DocumentRoot "/var/www/html/[example]"
    ErrorLog "/private/var/log/apache2/error.log"
        <Directory "/var/www/html/[example]">
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName [example.com]
    ServerAlias [www.example.com]
    DocumentRoot "/var/www/html/[example]"
    SSLEngine on 
    SSLCertificateFile /etc/ssl/certs/ssl-public.pen
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert.key
</VirtualHost>
