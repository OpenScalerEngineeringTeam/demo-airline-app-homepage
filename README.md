This is a demo application to showcase OpenScaler's computer (virtual machine) features. This part focuses on the homepage only.

## Getting started

1. You'll need to install `nginx`, for example on Debian/Ubuntu:

```bash
sudo apt-get install nginx
```

2. Download the landing page application and copy it to the `/var/www/` directory:

```bash
wget --no-check-certificate 'https://github.com/OpenScalerEngineeringTeam/demo-airline-app-homepage/archive/refs/tags/v1.0.1.tar.gz' -O airline-homepage.tar.gz
mkdir -p airline-homepage
tar -xf airline-homepage.tar.gz --strip-components=1 -C airline-homepage
cd airline-homepage
```

3. Copy the `src` directory to the `/var/www/airliner-demo`

```bash
cp -r src /var/www/airliner-demo
```

4. Copy nginx configuration file to the `/etc/nginx/sites-available/` and disable the default nginx configuration so it doesn't conflict with our own (on port `80`).

```bash
cp nginx.conf /etc/nginx/sites-available/airliner-demo
# disable the default nginx configuration (still available in /etc/nginx/sites-available/default if you need to enable it again)
# if you need to enable it again, simply symlink it with:
#   ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-enabled/default
```

5. Enable the nginx configuration

```bash
ln -s /etc/nginx/sites-available/airliner-demo /etc/nginx/sites-enabled/airliner-demo
```

6. Test the nginx configuration

```bash
nginx -t
```

7. Finally, reload the nginx service

```bash
systemctl reload nginx
```

That's it, your application should now be accessible at `http://localhost/home` (port 80)
