CREATE SCHEMA day2;
CREATE TABLE day2.input (
    line_content TEXT
);
COPY day2.input (line_content)
FROM '/inputs/day-2.txt';