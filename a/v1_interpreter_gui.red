Red [
Needs: 'View
]

do %v1_interpreter.red

execute_code: func [input_code [string!]][
    tokens: parser input_code
    gui_vm tokens
]

original_code: {a Z
Z b
Z Z
b -2

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
        vm_result: execute_code source/text
        vm_output: select vm_result 'output
        vm_memory: select vm_result 'memory
        
        formatted_output: form f_map lambda [append ? newline]  vm_output
        memory_field/text: form vm_memory
        output_field/text: formatted_output
    ]
    text #2C3339 white "Source"
    source: area #13181E 100x300 no-border original_code font source_font
    
    return  
    
    text #2C3339 white "Memory"    
    memory_field: area #13181E 300x100 font source_font
  
    text #2C3339 white "Output"
    output_field: area #13181E 300x300 font source_font
]	
