create table day1.solution_2 as

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

left_counts as (
    select
        num,
        count(*) as count
    from left_col
    group by num
),

right_counts as (
    select
        num,
        count(*) as count
    from right_col
    group by num
),

left_joint as (
    select
        left_counts.num
            * left_counts.count
            * coalesce(right_counts.count, 0) 
            as similarity_score
    from
        left_counts
    left join right_counts
    on left_counts.num = right_counts.num
)

select sum(similarity_score) as answer
from left_joint;