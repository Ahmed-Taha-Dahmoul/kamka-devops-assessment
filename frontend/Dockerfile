# STAGE 1: Build the React application
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files and install dependencies (Caching)
COPY package.json package-lock.json* ./
RUN npm install

# Copy source code
COPY . .

# Pass the API URL as a build argument (no secrets baked in)
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Build the Vite project
RUN npm run build

# STAGE 2: Serve the application using Nginx
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy the build artifacts from Stage 1
COPY --from=build /app/dist /usr/share/nginx/html

# Copy our custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]