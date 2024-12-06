create or replace function make_satisfy_rule(dummy text, pages text, rule_pattern text, flag boolean)
returns text
language sql as $$
with args as (
    select
        coalesce($1, $2) as pages,
        $3 as both_pattern,
        $4 as is_satisfied
),
page_components as (
    select
        pages,
        split_part(both_pattern, '%', 2) as first_page,
        split_part(both_pattern, '%', 3) as second_page,
        both_pattern,
        is_satisfied
    from args
),
components as (
    select
        pages,
        first_page,
        second_page,
        '%' || first_page || '%' as first_pattern,
        '%' || second_page || '%' as second_pattern,
        both_pattern,
        '%' || second_page || '%' || first_page || '%' as anti_pattern,
        is_satisfied
    from page_components
)
select
    case
        when pages like both_pattern then pages
        when pages like anti_pattern then (
            split_part(pages, second_page, 1)
            || first_page
            || split_part(
                split_part(pages, second_page, 2),
                first_page, 1
            )
            || second_page
            || split_part(pages, first_page, 2)
        )
        else pages
    end
from components
$$;
create or replace aggregate make_satisfy_rules(text, text, boolean) (
    sfunc = make_satisfy_rule,
    stype = text
);
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

updates_with_rules_1 as (
    select
        page.update_id,
        page.pages,
        rule.rule_id,
        rule.first_pattern,
        rule.second_pattern,
        rule.both_pattern,
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

original_unsatisfactory_updates as (
    select
        update_id,
        pages,
        rule_id,
        is_satisfied,
        both_pattern
    from updates_with_rules_1
    where not is_satisfied
    order by update_id, rule_id
),

corrected_updates as (
    select
        update_id,
        make_satisfy_rules(pages, both_pattern, is_satisfied)
            as corrected_pages
    from original_unsatisfactory_updates
    group by update_id
    order by update_id
),

stripped_corrected_updates as (
    select
        update_id,
        replace(corrected_pages, '"', ' ') as stripped_pages
    from corrected_updates
),

flattened_pages as (
    select
        update_id,
        unnest(
            string_to_array(
                stripped_pages,
                ','
            )
        ) as page_num
    from stripped_corrected_updates
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
