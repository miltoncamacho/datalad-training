# Use the official Python image from the Docker Hub
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the Python script into the container
COPY multiply_numbers.py .

# Install any necessary dependencies (none needed for this script)

# Set the entrypoint to the script
ENTRYPOINT ["python", "multiply_numbers.py"]
