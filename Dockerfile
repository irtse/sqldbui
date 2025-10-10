FROM nginx:1.25.2-alpine

# copy the info of the builded web app to nginx
COPY ./build/web /usr/share/nginx/html


# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Expose and run nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]