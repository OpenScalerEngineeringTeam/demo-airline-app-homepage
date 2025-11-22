#!/bin/bash
# -------------------------------------------------------------------------------------------------
#   Install Static Landing Page
# -------------------------------------------------------------------------------------------------
# This script will install the static landing (airliner-demo) with all necessary dependencies.
#
# Usage:
# ./install-static-landing-page.sh
#
# Note: must run from project root directory.
# -------------------------------------------------------------------------------------------------

# check that script is running from project root directory by checking if the page.html file exists
if [ ! -f page.html ]; then
    echo "Error: script must be run from project root directory (where page.html is located)"
    exit 1
fi

# -------------------------------------------------------------------------------------------------
#   I- Prepare the files
# -------------------------------------------------------------------------------------------------
# not that assets and images are copied under .../home/... directory to make load balancer ACL
# easier and avoid conflict with Next.js app.
mkdir -p /var/www/airliner-demo
mkdir -p /var/www/airliner-demo/home/assets
mkdir -p /var/www/airliner-demo/home/img
cp page.html /var/www/airliner-demo/index.html
cp public/logo.svg /var/www/airliner-demo/home/logo.svg
# Copy all carousel images
cp public/img/airplane-landing-page-1.webp /var/www/airliner-demo/home/img/airplane-landing-page-1.webp
cp public/img/airplane-landing-page-2.webp /var/www/airliner-demo/home/img/airplane-landing-page-2.webp
cp public/img/airplane-landing-page-3.webp /var/www/airliner-demo/home/img/airplane-landing-page-3.webp
cp public/img/airplane-landing-page-4.webp /var/www/airliner-demo/home/img/airplane-landing-page-4.webp

# download tailwind CDN file (if not already present)
if [ ! -f /var/www/airliner-demo/home/assets/tailwind.css ]; then
    curl -L https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4 -o /var/www/airliner-demo/home/assets/tailwind.js
fi

# -------------------------------------------------------------------------------------------------
#   II- Configure the web server / if not already configured
# -------------------------------------------------------------------------------------------------
# check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "Error: Nginx is not installed"
    exit 1
fi

# check if Nginx service is running
if ! systemctl is-active --quiet nginx; then
    echo "Error: Nginx service is not running"
    exit 1
fi

# -------------------------------------------------------------------------------------------------
#   Install the landing page for user if not already installed
# -------------------------------------------------------------------------------------------------
if [ ! -f /etc/nginx/sites-available/airliner-demo ]; then
    echo "Nginx configuration file does not exist, do you want to help to set it up? (y/n) (default: y)"
    read -p "Answer: " answer || answer="y"
    if [ "$answer" != "n" ]; then
        echo "Setting up Nginx configuration..."
        cp scripts/nginx.conf /etc/nginx/sites-available/airliner-demo
        read -p "Enter the port to listen on (default: 80): " port
        if [ -n "$port" ]; then
            sed -i "s/listen 80;/listen $port;/" /etc/nginx/sites-available/airliner-demo
        fi
        read -p "Enter the domain to listen on (default: _ to match any domain): " domain
        if [ -n "$domain" ]; then
            sed -i "s/_;/$domain;/" /etc/nginx/sites-available/airliner-demo
        fi
        
        # Create symlink in sites-enabled if it doesn't exist
        if [ ! -L /etc/nginx/sites-enabled/airliner-demo ]; then
            echo "Creating symlink in sites-enabled..."
            ln -s /etc/nginx/sites-available/airliner-demo /etc/nginx/sites-enabled/airliner-demo
        fi

        # Disable default Nginx configuration to allow ours to work
        if [ -f /etc/nginx/sites-enabled/default ]; then
            echo "Removing default Nginx configuration..."
            rm /etc/nginx/sites-enabled/default
        fi
        
        # Test nginx configuration before reloading
        echo "Testing Nginx configuration..."
        if nginx -t; then
            echo "✓ Nginx configuration is valid"
            systemctl reload nginx
            echo "✓ Nginx reloaded successfully"
        else
            echo "Error: Nginx configuration test failed"
            echo "Please check the configuration file: /etc/nginx/sites-available/airliner-demo"
            exit 1
        fi
    else
        echo "Skipping Nginx configuration..."
    fi
else
    echo "Nginx configuration file already exists"
fi

# -------------------------------------------------------------------------------------------------
#   IV- Test the landing page
# -------------------------------------------------------------------------------------------------
# check if the landing page is accessible
TEST_URL="http://localhost/home"

if curl -s "$TEST_URL" | grep -q "Airliner Demo"; then
    echo "✓ Landing page is accessible at $TEST_URL"
else
    echo "Warning: Landing page may not be accessible at $TEST_URL"
    echo "Please check your Nginx configuration to serve files from /var/www/airliner-demo/"
    echo "You can test manually with: curl $TEST_URL"
fi