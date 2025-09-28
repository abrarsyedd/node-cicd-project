# Stage 1: Build Stage (using a node base image)
FROM node:20-alpine AS build

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY app/package*.json ./
RUN npm install

# Copy application source code
COPY app/ .

# Stage 2: Production Stage (using a smaller base image for production)
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy dependencies from the build stage
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/index.js .

# Expose port and define the command to run the app
EXPOSE 3000
CMD [ "node", "index.js" ]
