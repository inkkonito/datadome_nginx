FROM nginx:latest
RUN apt-get update && \
    apt-get -y install wget gcc make nano libpcre3-dev libssl-dev zlib1g zlib1g-dev gnupg2 && \
    apt-get autoremove

# Install DataDome module
COPY ./nginx-module.sh /
RUN chmod +x /nginx-module.sh
RUN ./nginx-module.sh

COPY ./nginx.conf /etc/nginx/nginx.conf
