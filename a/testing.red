Red []

assert: function [
    conditions [block!]
] [
    any [
        all conditions
        do make error! rejoin ["assertion failed for: " mold conditions ", conditions: [" compose/only conditions "]"]
    ]
]