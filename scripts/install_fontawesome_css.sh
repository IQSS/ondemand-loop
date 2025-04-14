#!/bin/bash
# Create the folder if it doesn't exist
mkdir -p application/app/assets/stylesheets/fontawesome
mkdir -p application/app/assets/fonts/fontawesome

# CSS
curl -o application/app/assets/stylesheets/fontawesome/fontawesome.css \
  https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css

# Fonts (woff2 and woff cover most modern browsers)
curl -o application/app/assets/fonts/fontawesome/fa-solid-900.woff2 \
  https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/webfonts/fa-solid-900.woff2

curl -o application/app/assets/fonts/fontawesome/fa-regular-400.woff2 \
  https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/webfonts/fa-regular-400.woff2

curl -o application/app/assets/fonts/fontawesome/fa-brands-400.woff2 \
  https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/webfonts/fa-brands-400.woff2
