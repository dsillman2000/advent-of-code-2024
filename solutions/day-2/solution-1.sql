create table day2.solution_1 as

with 

numbered_lines as (
    select
        row_number() over () as report_number,
        line_content
    from day2.input
),

flattened_lines as (
    select
        report_number,
        each.level :: int as level,
        row_number() over (partition by report_number) as level_idx
    from numbered_lines
    cross join lateral string_to_table(line_content, ' ') as each(level)
),

linked_levels as (
    select
        report_number,
        level,
        level - lag(level) over (partition by report_number order by level_idx) as diff
    from flattened_lines
),

safe_reports as (
    select
        report_number
    from linked_levels
    where diff is not null
    group by report_number
    having
        max(abs(diff)) <= 3 and
        min(abs(diff)) >= 1 and
        sign(min(diff)) = sign(max(diff))
)

select count(*)
from safe_reports;