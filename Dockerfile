FROM nginx:alpine

RUN printf '%s\n' '<h1>Application Web - TP DevOps</h1>' > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
