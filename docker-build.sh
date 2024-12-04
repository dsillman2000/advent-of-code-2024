echo "Compiling setup scripts..."
bash ./generate-setups.sh
echo "Building image..."
docker build --pull --rm -f "Dockerfile" -t adventofcode2024:latest "."
