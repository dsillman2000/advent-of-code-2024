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
    days=$(ls -1 ./solutions | grep day- | cut -d'-' -f2 | sort -n |  tr '\n' ' ')
fi

echo "Selected days: $days"

if [[ $nobuild = 1 ]]; then
    echo "--no-build supplied: skipping build"
else
    bash ./docker-build.sh
fi

echo "Running container..."
docker run -d -p 5432:5432 --name advent --rm adventofcode2024:latest

echo "Done. Cooling off..."
sleep 3

echo "Done. Running solutions..."
for day in $days; do

    echo "Day $day"
    solutions=$(ls -1 ./solutions/day-$day/solution-*.sql)
    solution_i=1

    for solution in $solutions; do
        solution_file="/advent/solutions/day-$day/solution-$solution_i.sql"
        echo "Part $solution_i" 
        docker exec advent bash /advent/solutions/create-solution-table.sh $solution_file
        sleep 0.5
        docker exec advent bash /advent/solutions/select-solution-table.sh $solution_file
        sleep 0.5
        ((solution_i++))
    done

done

echo "Done. Stopping container..."
docker stop advent