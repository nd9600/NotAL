Red [
  Needs: 'View
]

do %v1_interpreter.red

interpreter: function [
    memory [block!]
    /with "evaluate the interpreter_output map"
    f [function!] "the function to evaluate the interpreter output with"
][
    pc: 0
    output_string: copy []
    output_memory: reduce copy [memory]
    finished: false
        
    while [not finished] [
        interpreter_output: step_interpreter memory pc
        either error? interpreter_output/error [
            append output_string copy interpreter_output/error
            break
        ] [
            ; we must update these variables to step through the interpreter
            finished: interpreter_output/finished
            pc: interpreter_output/pc
            memory: copy interpreter_output/memory
            
            append output_string copy interpreter_output/output_string
            append/only output_memory memory
            if with [f interpreter_output]
        ]
    ]
    return make map! compose/only [
      output_string: (output_string)
      output_memory: (output_memory)
    ]
]

execute_code: function [input_code [string!]][
    memory: parser input_code
    interpreter memory
]

original_code: {a Z
Z b
Z Z

.Z : 0
.a : 3
.b : 4
}

source_font: [
		name: font-fixed
		size: 9
		color: hex-to-rgb #9EBACB
	]

view [
	title "Red subleq parser demo"
	backdrop #2C3339
    below
    
    run_button: button black "Run" [
        interpreter_result: execute_code source/text
        output_memory: interpreter_result/output_memory
        output_string: interpreter_result/output_string

        ; appends a newline to each element in the blocks and forms into a string
        memory_field/text: form f_map lambda [append ? newline] output_memory
        output_field/text: form f_map lambda [append ? newline] output_string
    ]
    text #2C3339 white "Source"
    source: area #13181E 100x300 no-border original_code font source_font
    
    return ;puts the two fields in a new column
    
    text #2C3339 white "Memory"    
    memory_field: area #13181E 300x100 font source_font
  
    text #2C3339 white "Output"
    output_field: area #13181E 300x300 font source_font
]
