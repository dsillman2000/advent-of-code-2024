nobuild=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --no-build)
            shift
            nobuild=1
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
    docker build --pull --rm -f "Dockerfile" -t adventofcode2024:latest "."
fi

echo "Running container..."
docker run --detach --name advent --rm adventofcode2024:latest
echo "Done. Cooling off..."

sleep 1

echo "Done. Running psql..."
docker exec -it advent bash -c "PGPASSWORD=advent psql -U advent -w advent"

echo "Done. Cleaning up..."
docker stop advent
