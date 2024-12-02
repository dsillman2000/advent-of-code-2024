CREATE SCHEMA day1;
CREATE TABLE day1.input (
    line_content TEXT
);
COPY day1.input (line_content)
FROM '/inputs/day-1.txt';