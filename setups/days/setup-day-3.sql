create schema day3;
create table day3.input (
    line_content text
);
copy day3.input (line_content)
from '/advent/inputs/day-3.txt';