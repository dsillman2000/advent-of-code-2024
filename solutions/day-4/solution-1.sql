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

xs as (
    select
        x,
        y,
        letter
    from flattened_coordinates
    where letter = 'X'
),


/*

I wish I could have figured out a way to roll this up nicely into a recursive
CTE or other convenient syntactic shorthand. I probably could have, but in the
interest of time and interpretability, I decided to just write out the 8 distinct
scan directions explicitly, though calculating them in a single group-by.

*/


detect_xmases as (
    select
        xs.x,
        xs.y,
        -- Cardinal direction: east (+x, 0)
        sum(
            (
                (   -- "east" is when 0 <= Δx <= 3 and Δy = 0
                    surrounding.y = xs.y and 
                    surrounding.x - xs.x between 0 and 3
                ) and (
                    (   -- We expect Δ(x,y) = (1,0) to be 'M'
                        surrounding.x - xs.x = 1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (2,0) to be 'A'
                        surrounding.x - xs.x = 2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (3,0) to be 'S'
                        surrounding.x - xs.x = 3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as eastward_xmas,
        -- Cardinal direction: northeast (+x, -y)
        sum(
            (
                (   -- "northeast" is when -3 <= Δy <= 0 <= Δx <= 3
                    surrounding.y - xs.y between -3 and 0 and
                    surrounding.x - xs.x between 0 and 3
                ) and (
                    (   -- We expect Δ(x,y) = (1,-1) to be 'M'
                        surrounding.x - xs.x = 1 and
                        surrounding.y - xs.y = -1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (2,-2) to be 'A'
                        surrounding.x - xs.x = 2 and
                        surrounding.y - xs.y = -2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (3,-3) to be 'S'
                        surrounding.x - xs.x = 3 and
                        surrounding.y - xs.y = -3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as northeastward_xmas,
        -- Cardinal direction: north (0, -y)
        sum(
            (
                (   -- "north" is when Δx = 0 and -3 <= Δy <= 0
                    surrounding.x = xs.x and
                    surrounding.y - xs.y between -3 and 0
                ) and (
                    (   -- We expect Δ(x,y) = (0,-1) to be 'M'
                        surrounding.y - xs.y = -1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (0,-2) to be 'A'
                        surrounding.y - xs.y = -2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (0,-3) to be 'S'
                        surrounding.y - xs.y = -3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as northward_xmas,
        -- Cardinal direction: northwest (-x, -y)
        sum(
            (
                (   -- "northwest" is when -3 <= Δx <= 0 and -3 <= Δy <= 0
                    surrounding.x - xs.x between -3 and 0 and
                    surrounding.y - xs.y between -3 and 0
                ) and (
                    (   -- We expect Δ(x,y) = (-1,-1) to be 'M'
                        surrounding.x - xs.x = -1 and
                        surrounding.y - xs.y = -1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (-2,-2) to be 'A'
                        surrounding.x - xs.x = -2 and
                        surrounding.y - xs.y = -2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (-3,-3) to be 'S'
                        surrounding.x - xs.x = -3 and
                        surrounding.y - xs.y = -3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as northwestward_xmas,
        -- Cardinal direction: west (-x, 0)
        sum(
            (
                (   -- "west" is when -3 <= Δx <= 0 and Δy = 0
                    surrounding.y = xs.y and
                    surrounding.x - xs.x between -3 and 0
                ) and (
                    (   -- We expect Δ(x,y) = (-1,0) to be 'M'
                        surrounding.x - xs.x = -1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (-2,0) to be 'A'
                        surrounding.x - xs.x = -2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (-3,0) to be 'S'
                        surrounding.x - xs.x = -3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as westward_xmas,
        -- Cardinal direction: southwest (-x, +y)
        sum(
            (
                (   -- "southwest" is when -3 <= Δx <= 0 and 0 <= Δy <= 3
                    surrounding.x - xs.x between -3 and 0 and
                    surrounding.y - xs.y between 0 and 3
                ) and (
                    (   -- We expect Δ(x,y) = (-1,1) to be 'M'
                        surrounding.x - xs.x = -1 and
                        surrounding.y - xs.y = 1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (-2,2) to be 'A'
                        surrounding.x - xs.x = -2 and
                        surrounding.y - xs.y = 2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (-3,3) to be 'S'
                        surrounding.x - xs.x = -3 and
                        surrounding.y - xs.y = 3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as southwestward_xmas,
        -- Cardinal direction: south (0, +y)
        sum(
            (
                (   -- "south" is when Δx = 0 and 0 <= Δy <= 3
                    surrounding.x = xs.x and
                    surrounding.y - xs.y between 0 and 3
                ) and (
                    (   -- We expect Δ(x,y) = (0,1) to be 'M'
                        surrounding.y - xs.y = 1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (0,2) to be 'A'
                        surrounding.y - xs.y = 2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (0,3) to be 'S'
                        surrounding.y - xs.y = 3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as southward_xmas,
        -- Cardinal direction: southeast (+x, +y)
        sum(
            (
                (   -- "southeast" is when 0 <= Δx <= 3 and 0 <= Δy <= 3
                    surrounding.x - xs.x between 0 and 3 and
                    surrounding.y - xs.y between 0 and 3
                ) and (
                    (   -- We expect Δ(x,y) = (1,1) to be 'M'
                        surrounding.x - xs.x = 1 and
                        surrounding.y - xs.y = 1 and
                        surrounding.letter = 'M'
                    ) or ( -- We expect Δ(x,y) = (2,2) to be 'A'
                        surrounding.x - xs.x = 2 and
                        surrounding.y - xs.y = 2 and
                        surrounding.letter = 'A'
                    ) or ( -- We expect Δ(x,y) = (3,3) to be 'S'
                        surrounding.x - xs.x = 3 and
                        surrounding.y - xs.y = 3 and
                        surrounding.letter = 'S'
                    )
                )
            ) :: int
        ) = 3 as southeastward_xmas
    from xs
    join flattened_coordinates as surrounding
        on surrounding.x - xs.x between -3 and 3
        and surrounding.y - xs.y between -3 and 3
    group by xs.x, xs.y
)

select sum(
    eastward_xmas :: int +
    northeastward_xmas :: int +
    northward_xmas :: int +
    northwestward_xmas :: int +
    westward_xmas :: int +
    southwestward_xmas :: int +
    southward_xmas :: int +
    southeastward_xmas :: int
) as answer 
from detect_xmases;