# Use official Nginx image as base
FROM nginx:alpine

# Copy website files to Nginx html directory
COPY . /usr/share/nginx/html/

# Copy custom Nginx configuration (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Nginx runs automatically
CMD ["nginx", "-g", "daemon off;"]
