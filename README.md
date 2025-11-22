This is a demo application to showcase OpenScaler's computer (virtual machine) features. This part focuses on the homepage only.

## Getting started

1. You'll need to install `nginx`, for example on Debian/Ubuntu:

```bash
sudo apt-get install nginx
```

2. Download the landing page application:

```bash
wget --no-check-certificate 'https://github.com/OpenScalerEngineeringTeam/demo-airline-app-homepage/archive/refs/tags/v1.0.0.tar.gz' -O airline-homepage.tar.gz
mkdir -p airline-homepage
tar -xf airline-homepage.tar.gz --strip-components=1 -C airline-homepage
cd airline-homepage
```

3. Install the landing page application:

To install the static landing page, simply run the [install.sh](scripts/install.sh) script:

```bash
# from the airline-homepage directory
bash scripts/install.sh
```

That's it, your application should now be accessible at `http://localhost/home` (port 80)
