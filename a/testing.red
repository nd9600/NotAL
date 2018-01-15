Red []

assert: function [
    "Raises an error if every value in 'conditions doesn't evaluate to true. Inclose variables in brackets to compose them"
    conditions [block!]
] [
    any [
        all conditions
        do make error! rejoin ["assertion failed for: " mold conditions ", conditions: [" compose/only conditions "]"]
    ]
]