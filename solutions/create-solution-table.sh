input_solution=$1
day_num=$(echo $input_solution | sed -n 's/.*day-\([0-9]*\).*/\1/p')
solution_num=$(echo $input_solution | sed -n 's/.*solution-\([0-9]*\).*/\1/p')
solution_table="day${day_num}.solution_${solution_num}"
solution_logic=$(cat $input_solution)
PGPASSWORD=advent

# if solution_logic contains "-- no-auto-create" then just run the logic without prefixing.
if [[ $solution_logic == *"-- no-auto-create"* ]]; then
    psql -U advent -w advent -c "$solution_logic"
    exit 0
fi

psql -U advent -w advent -c "create table $solution_table as"$'\n\n'"$solution_logic"