FROM node:20-slim
WORKDIR /usr/app

# Install dependencies and build the project.
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

ENV ATLAS_URI=$ATLAS_URI
# Run the web service on container startup.
CMD ["node", "dist/server.js"]
