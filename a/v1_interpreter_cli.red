Red [
]

do %v1_interpreter.red

input_code: copy {
a Z
Z b
Z Z

.Z : 0
.a : 3
.b : 4
}

;execute_code/with input_code function [result] [probe result]
interpreter_result: execute_code input_code