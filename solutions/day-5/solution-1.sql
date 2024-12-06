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
        line_number as rule_id,
        split_part(line_content, '|', 1) as first_page,
        split_part(line_content, '|', 2) as second_page
    from categorized_lines
    where line_category = 'ordering_rule'
),

ordering_patterns as (
    select
        rule_id,
        '%"' || first_page || '"%' as first_pattern,
        '%"' || second_page || '"%' as second_pattern,
        '%"' 
        || first_page || '"%"'
        || second_page || '"%' as both_pattern
    from ordering_rules
),

page_updates as (
    select
        line_number as update_id,
        '"' 
        || replace(line_content, ',', '","')
        || '"' as pages
    from categorized_lines
    where line_category = 'page_updates'
),

updates_with_rules as (
    select
        page.update_id,
        page.pages,
        rule.rule_id,
        (
            page.pages like rule.first_pattern
            and page.pages like rule.second_pattern
            and page.pages like rule.both_pattern
        ) or not (
            page.pages like rule.first_pattern
            and page.pages like rule.second_pattern
            and page.pages not like rule.both_pattern
        ) as is_satisfied
    from page_updates as page
    cross join ordering_patterns as rule
),

satisfactory_updates as (
    select
        update_id,
        replace(pages, '"', ' ') as stripped_pages
    from updates_with_rules
    group by update_id, pages
    having bool_and(is_satisfied)
    order by update_id
),

flattened_pages as (
    select
        update_id,
        unnest(
            string_to_array(stripped_pages, ',')
        ) as page_num
    from satisfactory_updates
),

indexed_flat_pages as (
    select
        update_id,
        row_number() over (partition by update_id) as page_index,
        page_num
    from flattened_pages
),

index_flat_pages_with_max as (
    select
        update_id,
        page_index,
        page_num,
        max(page_index) over (partition by update_id) as max_page_index
    from indexed_flat_pages
),

midpoint_pages as (
    select
        update_id,
        page_index,
        page_num
    from index_flat_pages_with_max
    where page_index = (max_page_index + 1) / 2
)

select sum(page_num::int) as answer
from midpoint_pages;
