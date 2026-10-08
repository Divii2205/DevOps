FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Runtime: unprivileged nginx (runs as user 101 and listens on 8080)
FROM nginxinc/nginx-unprivileged:1.29-alpine
USER root
# pull the latest Alpine security fixes (Trivy gate)
RUN apk upgrade --no-cache
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
USER 101
EXPOSE 8080
