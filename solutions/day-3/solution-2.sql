/*

Note: there's probably a way to do what I'm trying to do here without needing
to define my own aggregate function. But it was a cool way to learn how it's
done using state types and state transition functions.

*/

create or replace function enable_transition(int, int)
returns int
language sql
as 'select coalesce($2, $1, 1)';

create or replace aggregate enabled_agg (int)
(
    sfunc = enable_transition,
    stype = int,
    initcond = 1
);

create table day3.solution_2 as

with

recognized_directives as (
    select 
        unnest(
            regexp_matches(line_content, '(mul\(\d+,\d+\)|do\(\)|don''t\(\))', 'g')
        ) as directive
    from day3.input
),

indexed_directives as (
    select
        row_number() over () as directive_index,
        directive
    from recognized_directives
),

enabled_boundary_signals as (
    select
        directive_index,
        directive,
        case
            when directive = 'do()' then 1
            when directive = 'don''t()' then 0
            else null
        end as boundary_signal
    from indexed_directives
),

enabled_windows as (
    select
        directive_index,
        directive,
        enabled_agg(boundary_signal)
            over (order by directive_index rows unbounded preceding)
            as enabled
    from enabled_boundary_signals
),

muls_with_enabled_flag as (
    select
        (regexp_match(directive, 'mul\((\d+),(\d+)\)'))[1] :: int
            as left_operand,
        (regexp_match(directive, 'mul\((\d+),(\d+)\)'))[2] :: int
            as right_operand,
        enabled
    from
        enabled_windows
    where directive like 'mul(%,%)'
)

select sum(left_operand * right_operand * enabled) as answer
from muls_with_enabled_flag;