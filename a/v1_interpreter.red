Red []

{
subleq a, b, c   ; Mem[b] = Mem[b] - Mem[a]
                 ; if (Mem[b] = 0) goto c

. at start means it's not an instruction
. a:b defines a label a to be b
. a:  defines a label for a position
z always = 0

? ; jump to next line
a ; same as a a ?
a b ; same as a b ?

a = 0
a a  => a = a - a = 0
a a

jmp c
Z Z c ; 0-0=0, jmp c

add a, b (b: a + b)
a Z ; Z = Z - a = -a
Z b ; b = b - z = b - -a = b + a
Z Z ; Z = Z - Z = 0

mov a, b (b: a)
b b ; b = 0
a Z ; Z = -a
Z b ; b = a + 0 = a
Z Z ; Z = 0
}

do %functional.red
do %testing_interpreter.red

low_level_parser: function [lines [string!]][    
    memory: copy []
    label-table: make map! []
    patching-table: make map! []
    
    minus:      charset "-"
    hash:       charset "#"
    semi_colon: charset ";"
    eol:        [semi_colon | newline]
    
    digit:      charset "0123456789"
    letters:    charset [#"A" - #"Z" #"a" - #"z" ]
    alphanum:   union letters digit
    
    number:     [some digit]
    address:    [number | minus number]
    variable:   [some alphanum]
    location:   [address | variable]
    
    label-left: [
        copy data 
        some alphanum
        (label-table/(data): length? memory)
    ]
                
    label-right: [
        copy data 
         [":" any space opt minus some alphanum] 
        (
            label-data: trim (pick split data ":" 2)
            append memory label-data
        )
    ]
    
    label: [
        any space "." any space label-left any space opt label-right
    ]
                
    thing-with-action: [
            copy data
            address
            (append memory data)
        | 
            copy data 
            variable
            (
                append memory 0
                patching-table/(length? memory ): data
            )
    ]
    
    three: [location space location space location]
    two: [location space location]
    one: [location]
    
    ;we need two different matching steps: first is just to match, second is to output the correct instructions
    command: [
            copy data 
            three 
            (
                parse data [thing-with-action space thing-with-action space thing-with-action]
            )
        |
            copy data 
            two 
            (
                parse data [thing-with-action space thing-with-action]
                append memory add length? memory 1
            )
        |
            copy data 
            one
            (   
                loop 2 [parse data [thing-with-action]]
                append memory add length? memory 2
            )
    ]

    rules: [
        any [
                [space | hash thru newline | eol] 
            |
                [label | command]
        ]
    ]
    
    parse lines rules
    
    ;patches in any variables
    foreach key keys-of patching-table [
        poke memory key label-table/(patching-table/(key))
    ]
    
    ;converts all strings like "1"
    memory: f_map lambda [to-integer ?] memory
    memory
]

parser: function [lines [string!]][
    subleq_code: low_level_parser lines
]

step_interpreter: function [
  memory [block!] "the subleq code to execute"
  pc [integer!] "the current program counter"
][
    output_string: copy [] ; each line of output is a new element in the block
    finished: false
    
    append/only output_string copy memory
    
    ;ask ""
    ; will exit from the if block if a throw is evaluated
    ; interpretation is finished if an error is thrown or we are at the end of the memory
    either error? err: try [ catch [
        a: pick memory add pc 1
        b: pick memory add pc 2
        c: pick memory add pc 3
        real_a: add a 1
        real_b: add b 1
        
        if (none? c) [
            append output_string "c is none"
            throw "c is none"
        ]
        
        append output_string (append copy "pc: " pc)
        append output_string (append copy "a: " a)
        append output_string (append copy "b: " b)
        append output_string (append copy "c: " c)

        case [
            c >= -1 [ memory/(real_b): memory/(real_b) - memory/(real_a) ]
            c == -1 [ finished: true ]
            c == -2 [
                if error? memory/(real_a): to-integer input [
                    memory/(real_a): to-string input
                ]
            ]
            c == -3 [ attempt append output_string to-string memory/(real_a) ]
            true    [ append output_string "c < -3"  throw "c < -3" ]
        ]
        
        append output_string (copy "")
        
        either all [ 
            b >= 0
            memory/(real_b) <= 0
            c >= 0 
        ] [
            pc: c                
        ] [
            pc: add pc 3
        ]
    ]] [
        finished: true
    ] [
        finished: finished or (pc + 3 >= length? memory)
    ]
    
    return make map! compose/only [
      finished: (finished)
      memory: (memory)
      pc: (pc)
      output_string: (output_string)
      error: (err)
    ]
]

interpreter: function [
    subleq_code [block!]
    /with "evaluate the interpreter_result map"
    f [function!] "the function to run on the interpreter output"
][
    pc: 0
    memory: copy subleq_code
    output_string: copy []
    output_memory: reduce copy [memory]
    finished: false
        
    while [not finished] [
        interpreter_result: step_interpreter memory pc
        either error? interpreter_result/error [
            append output_string copy interpreter_result/error
            break
        ] [
            ; we must update these variables to step through the interpreter
            finished: interpreter_result/finished
            pc: interpreter_result/pc
            memory: copy interpreter_result/memory
            
            append output_string copy interpreter_result/output_string
            append/only output_memory memory
            if with [f interpreter_result]
        ]
    ]
    return make map! compose/only [
        subleq_code: (subleq_code)
        output_string: (output_string)
        output_memory: (output_memory)
    ]
]

execute_code: function [
    input_code [string!]
    /with "evaluate the interpreter_result map"
    f [function!] "the function to run on the interpreter output"
][
    subleq_code: parser input_code
    either with [interpreter/with subleq_code :f] [interpreter subleq_code]
]