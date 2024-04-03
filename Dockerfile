FROM nginx:alpine

COPY --chown=nginx . /usr/share/nginx/html