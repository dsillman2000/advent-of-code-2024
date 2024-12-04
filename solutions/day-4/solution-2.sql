with

numbered_lines as (
    select
        row_number() over () as y,
        line_content as row_content
    from day4.input
),

flattened_letters as (
    select
        y,
        unnest(
            regexp_matches(row_content, 'X|M|A|S', 'g')
        ) as letter
    from numbered_lines
),

flattened_coordinates as (
    select
        y,
        row_number() over (partition by y) as x,
        letter
    from flattened_letters
),

"as" as (
    select
        x,
        y,
        letter
    from flattened_coordinates
    where letter = 'A'
),


/*

Same brutishly explicit approach as in part 1, but with 4 "MAS" symmetries
instead of 8 cardinal directions.

Note that, for all cases, we're primarily interested only in the 4 corner
characters of the X's, since the center will always be an 'A'. This is why
I preface all of my sum-conditions with Δ(x,y) != (0,0).

*/


detect_mas_xs as (
    select
        "as".x,
        "as".y,
        /* "MAS" symmetry: "bottom"
            S.S
            .A.
            M.M */
        sum(
            (   -- "bottom" is when M's have Δy = 1 while
                -- S's have Δy = -1.
                (surrounding.y != "as".y) and
                (surrounding.x != "as".x) and
                (
                    (   -- "M" is when Δy = 1
                        surrounding.y - "as".y = 1 and
                        surrounding.letter = 'M'
                    ) or (  -- "S" is when Δy = -1
                        surrounding.y - "as".y = -1 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 4 as bottom_xmas,
        /* "MAS" symmetry: "top"
            M.M
            .A.
            S.S */
        sum(
            (   -- "top" is when M's have Δy = -1 while
                -- S's have Δy = 1.
                (surrounding.y != "as".y) and
                (surrounding.x != "as".x) and
                (
                    (   -- "M" is when Δy = -1
                        surrounding.y - "as".y = -1 and
                        surrounding.letter = 'M'
                    ) or (  -- "S" is when Δy = 1
                        surrounding.y - "as".y = 1 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 4 as top_xmas,
        /* "MAS" symmetry: "left"
            M.S
            .A.
            M.S */
        sum(
            (   -- "left" is when M's have Δx = -1 while
                -- S's have Δx = 1.
                (surrounding.y != "as".y) and
                (surrounding.x != "as".x) and
                (
                    (   -- "M" is when Δx = -1
                        surrounding.x - "as".x = -1 and
                        surrounding.letter = 'M'
                    ) or (  -- "S" is when Δx = 1
                        surrounding.x - "as".x = 1 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 4 as left_xmas,
        /* "MAS" symmetry: "right"
            S.M
            .A.
            S.M */
        sum(
            (   -- "right" is when M's have Δx = 1 while
                -- S's have Δx = -1.
                (surrounding.y != "as".y) and
                (surrounding.x != "as".x) and
                (
                    (   -- "M" is when Δx = 1
                        surrounding.x - "as".x = 1 and
                        surrounding.letter = 'M'
                    ) or (  -- "S" is when Δx = -1
                        surrounding.x - "as".x = -1 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 4 as right_xmas
    from "as"
    join flattened_coordinates as surrounding
        on surrounding.x - "as".x between -1 and 1
        and surrounding.y - "as".y between -1 and 1
    group by "as".x, "as".y
)

select sum(
    bottom_xmas :: int +
    top_xmas :: int +
    left_xmas :: int +
    right_xmas :: int
) as answer
from detect_mas_xs;