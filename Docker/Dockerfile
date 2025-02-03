FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and install dependencies
COPY ../src/package.json .  
RUN npm install

# Copy the source code from the src folder
COPY ../src .  

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
