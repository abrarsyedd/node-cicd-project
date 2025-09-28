# Dockerfile
# Stage 1: Build the Node.js application
FROM node:20-alpine AS build

# Create app directory
WORKDIR /usr/src/app

# Install dependencies (use separate steps to leverage Docker cache)
COPY app/package*.json ./
RUN npm install

# Copy application source code
COPY app/ .

# Stage 2: Final minimal image
FROM node:20-alpine

# Set application directory
WORKDIR /usr/src/app

# Copy built code from the build stage (only what's needed for runtime)
COPY --from=build /usr/src/app .

# Expose the application port (3000)
# This is documentation, but it helps Docker networking
EXPOSE 3000

# Set environment variable to ensure Node.js listens on all interfaces (0.0.0.0)
# This is often the fix if the app listens only on 127.0.0.1 by default.
ENV HOST=0.0.0.0 
ENV PORT=3000

# Command to run the application
# Assuming your main script is index.js inside the 'app' directory
CMD [ "node", "index.js" ]
