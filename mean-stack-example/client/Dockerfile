FROM node:20-slim AS build

WORKDIR /usr/src/app
COPY package.json package-lock.json ./

# Install dependencies and copy them to the container
RUN npm ci
COPY . .
ARG URL

# Build the Angular application for production
ENV URL=$URL
RUN npm run build --prod

# Configure the nginx web server
FROM nginx:1.17.1-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/app/dist/client/browser /usr/share/nginx/html

# Run the web service on container startup.
CMD ["nginx", "-g", "daemon off;"]
