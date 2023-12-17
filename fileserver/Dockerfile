FROM nginx

COPY ./images /var/www/source_images
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN apt-get update -y && apt-get install -y nginx-module-image-filter

