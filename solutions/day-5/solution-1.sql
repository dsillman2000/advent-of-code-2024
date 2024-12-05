with

categorized_lines as (
    select
        line_content,
        row_number() over () as line_number,
        case
            when line_content like '%|%' then 'ordering_rule'
            when line_content like '%,%' then 'page_updates'
            else null
        end as line_category
    from day5.input
    where line_content like '%|%'
        or line_content like '%,%'
),

ordering_rules as (
    select
        split_part(line_content, '|', 1) as first_page,
        split_part(line_content, '|', 2) as second_page
    from categorized_lines
    where line_category = 'ordering_rule'
),

page_updates as (
    select
        line_number,
        unnest(
            string_to_array(line_content, ',')
        ) as page_num
    from categorized_lines
    where line_category = 'page_updates'
),

indexed_page_updates as (
    select
        line_number,
        row_number() over (partition by line_number) as page_index,
        page_num
    from page_updates
),

joint_with_relevant_ordering_rules as (
    select
        page_update.line_number,
        page_update.page_index,
        page_update.page_num,
        rule.first_page,
        rule.second_page
    from indexed_page_updates as page_update
    join ordering_rules as rule
        on page_update.page_num = rule.first_page
        or page_update.page_num = rule.second_page
)

select *
from joint_with_relevant_ordering_rules
limit 10000
;