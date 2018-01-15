Red [
]

do %v1_interpreter.red

adding_test: copy {
a Z
Z b
Z Z

.Z : 0
.a : 3
.b : 4
}

input_code: copy input_code

adding_test_interpreter_result: execute_code adding_test
tests_passed: all [
    assert [adding_test_interpreter_result/subleq_code == [10 9 3 9 11 6 9 9 9 0 3 4]]
]

if tests_passed [
    ;execute_code/with input_code function [result] [probe result]
    interpreter_result: execute_code input_code
]