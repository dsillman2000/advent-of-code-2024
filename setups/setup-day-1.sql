create schema day1;
create table day1.input (
    line_content text
);
copy day1.input (line_content)
from '/inputs/day-1.txt';