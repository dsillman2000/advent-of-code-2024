create schema day4;
create table day4.input (
    line_content text
);
copy day4.input (line_content)
from '/advent/inputs/day-4.txt';