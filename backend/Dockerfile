# Node.js Backend Dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy all files
COPY . .

# Install dependencies
RUN npm install --production

# Expose port
EXPOSE 5000

# Start server
CMD ["npm", "start"]
