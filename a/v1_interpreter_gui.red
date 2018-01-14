Red [
  Needs: 'View
]

do %v1_interpreter.red

pprobe: function ['var][probe rejoin [mold/only var ": " do var]]

interpreter: function [memory [block!]][
    pc: 0
    output_string: copy []
    output_memory: append/only [] copy memory 

    probe "output_string: " 
    probe output_string
    probe memory
    probe output_memory
    
    steps: 0
    
    while [(pc + 3) < (length? memory)] [
        interpreter_output: step_interpreter memory pc
        print " "
        either error? interpreter_output/error [
            append output_string copy interpreter_output/error
            break
        ] [
            ; we must update these two variables to step through the interpreter
            pc: interpreter_output/pc
            memory: copy interpreter_output/memory
            
            append output_string copy interpreter_output/output_string
            append/only output_memory memory
            
            print "^/#####^/"
            probe interpreter_output
            print "^/"
            pprobe pc
            probe output_string
            either steps == -1 [break][steps: steps + 1]
        ]
    ]
    pprobe pc
    probe output_string
    probe output_memory
    return make map! compose/only [
      output_string: (output_string)
      output_memory: (output_memory)
    ]
]

execute_code: function [input_code [string!]][
    tokens: parser input_code
    interpreter tokens
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
        output_string: interpreter_result/output_string
        output_memory: interpreter_result/output_memory
        
        formatted_output: form f_map lambda [append ? newline] output_string
        formatted_memory: form f_map lambda [append ? newline] output_memory
        memory_field/text: formatted_memory
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
