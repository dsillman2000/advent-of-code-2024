nobuild=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --no-build)
            shift
            nobuild=1
            ;;
        --kill)
            shift
            echo "Killing 'advent' container..."
            docker stop advent
            echo "Done."
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [[ $nobuild = 1 ]]; then
    echo "--no-build supplied: skipping build"
else
    echo "Building image..."
    bash ./docker-build.sh
fi

echo "Running container..."
docker run -d -p 5432:5432 --name advent --rm adventofcode2024:latest
echo "Done. Cooling off..."

sleep 3

echo "Done. 'advent' container is running."

docker_ip=$(docker inspect \
  -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' advent)

echo "Docker IP address: $docker_ip"