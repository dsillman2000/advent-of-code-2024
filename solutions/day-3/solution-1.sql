with

mul_matches as (
    select unnest(
        regexp_matches(line_content, '(mul\(\d+,\d+\))', 'g')
    ) as mul_match
    from day3.input
),

mul_operands as (
    select
        (regexp_match(mul_match, 'mul\((\d+),(\d+)\)'))[1] :: int
            as left_operand,
        (regexp_match(mul_match, 'mul\((\d+),(\d+)\)'))[2] :: int
            as right_operand
    from mul_matches
)

select sum(left_operand * right_operand) as answer
from mul_operands;