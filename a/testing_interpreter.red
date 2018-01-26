Red [
]

do %testing.red

adding_test: copy {
a Z
Z b
Z Z

.Z : 0
.a : 3
.b : 4
}

adding_test_interpreter_result: execute_code adding_test
assert [(adding_test_interpreter_result/subleq_code) == [110 9 3 9 11 6 9 9 9 0 3 4]]