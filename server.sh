#!/bin/bash
path_to_server_conf="/etc/apache2/sites-availables"
create_server(){
    cp /var/cache/apt/archives/*.deb /var/www/html/
    if [ -z $(ls $path_to_server_conf |grep -o deb_server.conf) ]; then
        touch $path_to_server_conf/deb_server.conf
        echo -e "<VirtualHost *:80>\nScriptAlias /cgi-bin \"/usr/lib/cgi-bin/\"\nServerName www.deb_package.mg\n</VirtualHost>" > $path_to_server_conf/deb_server.conf
        a2ensite $path_to_server_conf/deb_server.conf
        systemctl reload apache2
    fi
}

echo "Content-Type: text/html"
echo ""

path_to_deb="/var/cache/apt/archives/"
echo "<html>"
echo "<head><title>Deb Package</title></head>" 
echo "<body>" 
echo "<h1>List of Deb Packages Available</h1>" 
echo "<form action=\"/cgi-bin/get_package.sh\" method=\"post\">" 
echo "<input type=\"text\" size=\"75\" name=\"package_name\" placeholder=\"Search packages...\"list=\"packages\" required/>" 
echo "<input type=\"submit\" value=\"Search\">" 
echo "<datalist id="packages">"
    for i in $(ls $path_to_deb | grep ".deb" ); do
        echo "<option value=\"$i\">" 
    done
echo "</datalist>"
echo "</form>"
for i in $(ls $path_to_deb | grep ".deb" ); do
   echo "<p><a href=\"/$i\" download>- $i</a></p>"
done
echo "</body>" 
echo "</html>"
