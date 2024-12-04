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

holdout_indices as (
    select i as level_idx
    from generate_series(
        1, (select max(level_idx) from flattened_lines)
    ) as i
),

linked_levels_with_holdouts as (
    -- Compute differences without holding out any values, like in part 1
    select
        report_number,
        level,
        level_idx,
        null as holdout_idx,
        level - lag(level)
            over (partition by report_number order by level_idx) as diff
    from flattened_lines
    union all
    -- Compute differences after holding out each and every value
    select
        flat.report_number,
        flat.level,
        flat.level_idx,
        hold.level_idx as holdout_idx,
        flat.level - lag(flat.level)
            over (
                partition by flat.report_number, hold.level_idx 
                order by flat.level_idx
            ) as diff
    from flattened_lines as flat
    cross join holdout_indices as hold
    where flat.level_idx != hold.level_idx
),

-- Compute safe reports according to all possible hold-outs, unioned
safe_reports as (
    select
        report_number,
        holdout_idx
    from linked_levels_with_holdouts
    where diff is not null
    group by 
        report_number,
        holdout_idx
    having
        max(abs(diff)) <= 3 and
        min(abs(diff)) >= 1 and
        sign(min(diff)) = sign(max(diff))
)

select count(distinct report_number) as answer
from safe_reports;