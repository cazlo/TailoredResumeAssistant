FROM node:20-alpine AS builder

WORKDIR /opt/app

COPY frontend/package.json frontend/package-lock.json ./

RUN npm install

COPY frontend/ /opt/app

RUN npm run build

FROM nginx:1.27-alpine

COPY --from=builder /opt/app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
#CMD ["nginx", "-g", "daemon off;"] probably dont need to override