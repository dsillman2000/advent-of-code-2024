create schema day2;
create table day2.input (
    line_content text
);
copy day2.input (line_content)
from '/inputs/day-2.txt';