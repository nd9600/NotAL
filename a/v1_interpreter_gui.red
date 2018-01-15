Red [
  Needs: 'View
]

do %v1_interpreter.red

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
    
scaling: 1

view compose [
	title "Red subleq parser demo"
	backdrop #2C3339
    below
    
    run_button: button black "Run" [
        interpreter_result: execute_code source/text
        output_memory: interpreter_result/output_memory
        output_string: interpreter_result/output_string

        ; appends a newline to each element in the blocks and forms into a string
        subleq_field/text: form interpreter_result/subleq_code
        memory_field/text: form f_map lambda [append ? newline] output_memory
        output_field/text: form f_map lambda [append ? newline] output_string
    ]
    text #2C3339 white "Source"
    source: area #13181E (200x300 * scaling) no-border original_code font source_font
    
    text #2C3339 white "Subleq code"    
    subleq_field: area #13181E (300x100 * scaling) font source_font wrap
    
    return ;puts the fields below in a new column
    
    text #2C3339 white "Memory"    
    memory_field: area #13181E (300x100 * scaling) font source_font
  
    text #2C3339 white "Output"
    output_field: area #13181E 300x300 font source_font
]
