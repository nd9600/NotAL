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

add a, b
a Z ; Z = Z - a = -a
Z b ; b = b - z = b - -a = b + a
Z Z ; Z = Z - Z = 0

mov a, b
b b ; b = 0
a Z ; Z = -a
Z b ; b = a + 0 = a
Z Z ; Z = 0
}

do %functional.red

parser: function [lines [string!]][
] [
 low_level_parser lines
]

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
        
        either (b == -1) [
            if error? memory/(real_a): to-integer input [
                memory/(real_a): to-integer to-string input
            ]
        ] [
            either (b == -2) [
                output_character: to-string pick memory real_a
                attempt append output_string output_character
            ] [
                memory/(real_b): memory/(real_b) - memory/(real_a)
            ]
        ]
        
        if (c < -1) [
            append output_string "c < -1"
            throw "c < -1"
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
        finished: (pc + 3) >= (length? memory)
    
    return make map! compose/only [
      finished: (finished)
      memory: (memory)
      pc: (pc)
      output_string: (output_string)
      error: (err)
    ]
]