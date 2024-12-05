create schema day5;
create table day5.input (
    line_content text
);
copy day5.input (line_content)
from '/advent/inputs/day-5.txt';