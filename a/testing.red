Red []

assert: function [
    conditions [block!]
] [
    any [
        all conditions
        make error! rejoin ["assertion failed for: " mold conditions ", conditions: [" compose conditions "]"]
    ]
]