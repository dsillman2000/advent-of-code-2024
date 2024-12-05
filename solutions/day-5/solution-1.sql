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

page_updates as (
    select
        line_number as update_id,
        unnest(
            string_to_array(line_content, ',')
        ) as page_num
    from categorized_lines
    where line_category = 'page_updates'
),

indexed_page_updates as (
    select
        update_id,
        row_number() over (partition by update_id) as page_index,
        page_num
    from page_updates
),

ordered_pairs_with_relevance as (
    select
        page_update.update_id,
        page_update.page_index,
        page_update.page_num,
        rule.rule_id,
        rule.first_page,
        rule.second_page,
        count(*) 
            over (partition by update_id, rule_id) = 2 
            as is_relevant
    from indexed_page_updates as page_update
    join ordering_rules as rule
        on page_update.page_num = rule.first_page
        or page_update.page_num = rule.second_page
),

rules_pairs_in_updates as (
    select
        update_id,
        rule_id,
        first_page as rule_first_page,
        second_page as rule_second_page,
        first_value(page_num) 
            over (
                partition by update_id, rule_id
                order by page_index
            ) as update_first_page,
        last_value(page_num) 
            over (
                partition by update_id, rule_id
                order by page_index
            ) as update_second_page
    from ordered_pairs_with_relevance
    where is_relevant
    order by update_id, rule_id
),

rules_in_updates_with_correctness as (
    select
        update_id,
        rule_id,
        rule_first_page,
        rule_second_page,
        update_first_page,
        update_second_page,
        (
            rule_first_page = update_first_page and
            rule_second_page = update_second_page
        ) as is_correct
    from rules_pairs_in_updates
    -- knock out irrelevant member of pair
    where update_first_page != update_second_page
),

completely_correct_update_ids as (
    select
        update_id
    from rules_in_updates_with_correctness
    group by update_id
    having bool_and(is_correct)
),

completely_correct_updates_pages as (
    select
        idx_updates.update_id,
        idx_updates.page_index,
        idx_updates.page_num,
        max(idx_updates.page_index) 
            over (partition by idx_updates.update_id)
            as max_page_index
    from indexed_page_updates as idx_updates
    inner join completely_correct_update_ids
        using (update_id)
),

completely_correct_update_midpoints as (
    select
        update_id,
        page_num as midpoint_page
    from completely_correct_updates_pages
    where page_index = (max_page_index + 1) / 2
)

select sum(midpoint_page :: int) as answer
from completely_correct_update_midpoints
;