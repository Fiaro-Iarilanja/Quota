#!/bin/bash

echo "Content-Type: text/html"
echo ""
path_to_deb="/var/cache/apt/archives/"
ls $path_to_deb | grep ".deb" > $list
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
    echo "<p>- $i</p>"
done
echo "</body>" 
echo "</html>"