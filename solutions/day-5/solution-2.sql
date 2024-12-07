-- no-auto-create
create or replace function satisfies_rule(acc boolean, pages text, rule_pattern text)
returns boolean
language sql as $$
with args as (
    select
        $2 as pages,
        $3 as both_pattern,
        $1 as acc
),
page_components as (
    select
        acc,
        pages,
        both_pattern,
        '%' || split_part(both_pattern, '%', 3) || 
        '%' || split_part(both_pattern, '%', 2) || '%' 
            as anti_pattern
    from args
)
select
    case
        when pages like both_pattern then acc
        when pages like anti_pattern then false
        else acc
    end
from page_components
$$;
create or replace function make_satisfy_rule(dummy text, pages text, rule_pattern text)
returns text
language sql as $$
with args as (
    select
        coalesce($1, $2) as pages,
        $3 as both_pattern
),
page_components as (
    select
        pages,
        split_part(both_pattern, '%', 2) as first_page,
        split_part(both_pattern, '%', 3) as second_page,
        both_pattern
    from args
)
select
    case
        when satisfies_rule(true, pages, both_pattern) then pages
        else (
            split_part(pages, second_page, 1)
            || first_page
            || split_part(
                split_part(pages, second_page, 2),
                first_page, 1
            )
            || second_page
            || split_part(pages, first_page, 2)
        )
    end
from page_components
$$;
create or replace aggregate satisfies_rules(text, text) (
    sfunc = satisfies_rule,
    stype = boolean,
    initcond = true,
    parallel = restricted
);
create or replace aggregate make_satisfy_rules(text, text) (
    sfunc = make_satisfy_rule,
    stype = text,
    parallel = restricted
);
create or replace function satisfies_rules_array(pages text, rules text[])
returns boolean
language sql as $$
with flattened_args as (
    select
        $1 as pages,
        unnest($2) as rule_pattern
)
select
    satisfies_rules(pages, rule_pattern)
from flattened_args
$$;
create or replace function make_satisfy_rules_array(pages text, rules text[])
returns text
language sql as $$
with flattened_args as (
    select
        $1 as pages,
        unnest($2) as rule_pattern
)
select
    make_satisfy_rules(pages, rule_pattern)
from flattened_args
$$;
create table day5.solution_2 as

with recursive

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

ordering_array as (
    select
        array_agg(both_pattern) as rules
    from ordering_patterns
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

original_updates_with_rules as (
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
        both_pattern,
        bool_or(not is_satisfied) over (partition by update_id) as is_unsatisfactory
    from original_updates_with_rules
    order by update_id, rule_id
),

original_corrected_updates as (
    select
        update_id,
        make_satisfy_rules(pages, both_pattern)
            as corrected_pages
    from original_unsatisfactory_updates
    where is_unsatisfactory
    group by update_id
    order by update_id
),

corrected_updates as (
    select
        orig.update_id,
        make_satisfy_rules_array(
            orig.corrected_pages,
            rulearr.rules
        ) as corrected_pages,
        1 as revision
    from original_corrected_updates as orig
    cross join ordering_array as rulearr

    union

    select
        corr.update_id,
        make_satisfy_rules_array(
            corr.corrected_pages,
            rulearr.rules
        ) as corrected_pages,
        corr.revision + (
            not satisfies_rules_array(
                corr.corrected_pages,
                rulearr.rules
            )
        ) :: int as revision
    from corrected_updates as corr
    cross join ordering_array as rulearr
),

stripped_corrected_updates as (
    select distinct on (update_id)
        update_id,
        revision,
        replace(corrected_pages, '"', ' ') as stripped_pages
    from corrected_updates
    order by update_id, revision desc
),

flattened_pages as (
    select
        update_id,
        unnest(
            string_to_array(stripped_pages, ',')
        ) as page_num
    from stripped_corrected_updates
),

indexed_flat_pages as (
    select
        update_id,
        row_number() over (partition by update_id) as page_index,
        page_num
    from flattened_pages
    order by update_id, page_index
),

index_flat_pages_with_max as (
    select
        update_id,
        page_index,
        page_num::int,
        max(page_index::int) over (partition by update_id) as max_page_index
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