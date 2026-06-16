# Node.js Backend Dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy backend files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy rest of backend code
COPY . ./

# Expose port
EXPOSE 5000

# Start server
CMD ["npm", "start"]
