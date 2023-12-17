FROM nginx

RUN apt-get install nginx-module-image-filter
COPY ./images /var/www/source_images
COPY ./nginx.conf /etc/nginx/nginx.conf
