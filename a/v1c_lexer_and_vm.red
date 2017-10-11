Red [
Needs: 'View
]

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

parser: func [lines [string!]][    
    memory: copy []
    label-table: make map! []
    patching-table: make map! []
    
    space:      charset " "
    minus:      charset "-"
    digit:      charset "0123456789"
    letters:    charset [#"A" - #"Z" #"a" - #"z" ]
    alphanum:   union letters digit
    
    number:     [some digit]
    address:    [number | minus number]
    variable:   [some alphanum]
    thing:      [address | variable]
    
    label-left: [
        copy data 
        some alphanum
        (label-table/(data): length? memory)
    ]
                
    label-right: [
        copy data 
        any [":" any space opt minus some alphanum] 
        (
            label-data: trim pick split data ":" 2
            append memory label-data
        )
    ]
    
    label: [
        any space "." any space label-left any space label-right
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
    
    three: [thing space thing space thing]
    two: [thing space thing]
    one: [thing]
    
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
            newline
        ]
        some [
            [label | command]
            any [
                newline
            ]
        ]
    ]
    
    parse lines rules  
    foreach key keys-of patching-table [
        poke memory key label-table/(patching-table/(key))
    ]
    
    memory: f_map lambda [to-integer ?] memory
    memory
]


vm: func [memory [block!]][
    pc: 0
    output: copy []
    
    append/only output copy memory
    
    while [lesser? (add pc 3) length? memory] [
        ;ask ""
        if error? err: try [
            a: pick memory add pc 1
            b: pick memory add pc 2
            c: pick memory add pc 3
            real_a: add a 1
            real_b: add b 1
            
            if (none? c) [
                append output "c is none"
                break
            ]
            
            append output (copy "")
            append output (append copy "pc: " pc)
            append output (append copy "a: " a)
            append output (append copy "b: " b)
            append output (append copy "c: " c)
            
            either (equal? b -1) [
                if error? poke memory a to-integer input [
                    poke memory real_a to-integer to-string input
                ]
            ] [
                either (equal? b -2) [
                    output_character: to-string pick memory real_a
                    attempt append output output_character
                ] [
                    poke memory real_b (subtract (pick memory real_b) (pick memory real_a))
                ]
            ]
            
            if (lesser? c -1) [
                append output "c < -1"
                break
            ]
            
            either all [ 
            (greater-or-equal? b 0)
            (lesser-or-equal? (pick memory real_b) 0)
            (greater-or-equal? c 0) ] [
                pc: c                
            ] [
                pc: add pc 3
            ]
        ] [
            append output (append "error: " err)
            break
        ]
        append/only output copy memory
    ]  
    
    result: make map! []
    put result 'memory memory
    put result 'output output
    result
]

;;;;;;;;;;;;;;;;;;;;;;;;;

execute_code: func [input_code [string!]][
    tokens: parser input_code
    vm tokens
]

;system/view/silent?: yes

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
