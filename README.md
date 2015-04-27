# get-latest-seafile-downloads
This script creates static links for current Seafile downloads which are located at https://bitbucket.org/haiwen/seafile/downloads. It generates the NGINX configuration for rewriting the URLs and updates the index page at https://download.seafile.com.de. It validates the NGINX configuration and reloads NGINX if valid.


### How to run
<pre>
wget --no-check-certificate https://raw.githubusercontent.com/alexanderjackson/get-latest-seafile-downloads/master/get-latest-seafile-downloads.sh
time bash get-latest-seafile-downloads.sh
</pre>

### Bugs, suggestions, you name it...
Please contact me at alexander.jackson@seafile.com.de
