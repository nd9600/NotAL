Red [
]

do %v1_interpreter.red

execute_code: func [input_code [string!]][
    tokens: parser input_code
    cli_vm tokens
]

input_code: {
a Z
Z b
Z Z

.Z : 0
.a : 3
.b : 4
}

tokens: parser input_code
cli_vm tokens