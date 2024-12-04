with

left_col as (
    select
        split_part(line_content, ' ', 1) :: int as num
    from day1.input
    order by num
),

right_col as (
    select
        split_part(line_content, ' ', 4) :: int as num
    from day1.input
    order by num
),

left_ranked as (
    select
        num,
        row_number() over (order by num) as rank
    from left_col
),

right_ranked as (
    select
        num,
        row_number() over (order by num) as rank
    from right_col
),

ranked_differences as (
    select
        abs(left_ranked.num - right_ranked.num) as diff
    from left_ranked
    join right_ranked
    on left_ranked.rank = right_ranked.rank
)

select sum(diff) as answer
from ranked_differences;