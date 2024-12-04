inputs_dir="./inputs"
setup_days_dir="./setups/days"
setup_tmpl="./setups/setup.sql.tmpl"

inputs=$(ls -1 $inputs_dir)

echo "Performing setup on days:"
echo $inputs

for input in $inputs; do
    echo "Setting up input table for $input..."

    day_num=$(echo $input | cut -d'-' -f2 | cut -d'.' -f1)

    echo "Day number: $day_num"

    sed -e "s/{{ num }}/$day_num/g" $setup_tmpl > $setup_days_dir/setup-day-$day_num.sql

done

echo "Done."