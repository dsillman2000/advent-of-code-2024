input_solution=$1
day_num=$(echo $input_solution | sed -n 's/.*day-\([0-9]*\).*/\1/p')
solution_num=$(echo $input_solution | sed -n 's/.*solution-\([0-9]*\).*/\1/p')
solution_table="day${day_num}.solution_${solution_num}"
PGPASSWORD=advent
psql -U advent -w advent -c "select * from $solution_table;"