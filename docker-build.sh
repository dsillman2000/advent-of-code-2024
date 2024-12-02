days=""
nobuild=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --all)
            shift
            days='*'
            ;;
        --no-build)
            shift
            nobuild=1
            ;;
        --day)
            shift
            days=$1
            shift
            ;;
        --days)
            shift
            days=$1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [[ $days = '*' ]]; then
    days="1 2"
fi

echo "Selected days: $days"

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

echo "Done. Running solutions..."
for day in $days; do

    echo "Day $day"
    solutions=$(ls -1 ./solutions/day-$day/solution-*.sql)
    solution_i=1

    for solution in $solutions; do
        echo "Part $sql_i" 
        docker exec -it advent bash /solutions/exec.sh /solutions/day-$day/solution-$solution_i.sql
        sleep 0.5
        docker exec -it advent bash /solutions/read.sh day$day.solution_$solution_i
        sleep 0.5
        ((solution_i++))
    done

done

echo "Done. Stopping container..."
docker stop advent
