FROM nginx:alpine

RUN apk add --no-cache tree

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80