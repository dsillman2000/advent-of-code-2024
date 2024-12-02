PGPASSWORD=advent
psql -U advent -w advent -c "select * from $1;"