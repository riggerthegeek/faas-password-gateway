FROM nginx:1.13-alpine

COPY gateway.conf /etc/nginx/conf.d/default.conf
