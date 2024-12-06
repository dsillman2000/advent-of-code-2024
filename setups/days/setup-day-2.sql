create schema day2;
create table day2.input (
    line_content text
);
copy day2.input (line_content)
from '/advent/inputs/day-2.txt';