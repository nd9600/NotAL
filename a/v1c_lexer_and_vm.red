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

apply: func [f block [block!]] [   
    while [not tail? block] [
        block: change block f first block 
    ]   
]

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
        any [":" any space some alphanum] 
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
    
    apply :to-integer memory
    memory
]


vm: func [memory [block!]][
    probe memory
    
    pc: 0
    while [lesser? (add pc 3) length? memory] [
        ;ask ""
        if error? err: try [
            a: pick memory add pc 1
            b: pick memory add pc 2
            c: pick memory add pc 3
            real_a: add a 1
            real_b: add b 1
            
            if (none? c) [
                print "c is none" break
            ]
            
            print copy ""
            print append copy "pc: " pc
            print append copy "a: " a
            print append copy "b: " b
            print append copy "c: " c
            
            either (equal? b -1) [
                if error? poke memory a to-integer input [
                    poke memory real_a to-integer to-string input
                ]
            ] [
                either (equal? b -2) [
                    print pick memory real_a
                    attempt print to-string pick memory real_a
                ] [
                    poke memory real_b (subtract (pick memory real_b) (pick memory real_a))
                ]
            ]
            
            if (lesser? c -1) [
                print "c < -1" break
            ]
            
            either all [ (lesser-or-equal? (pick memory real_b) 0) (greater-or-equal? c 0) ] [
                pc: c                
            ] [
                pc: add pc 3
            ]
        ] [
            print append "error: " err break
        ]
        probe memory
        
    ]  
    memory
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
    
    source: area #13181E 100x300 no-border original_code font source_font
    
    below
    
    run_button: button black "Run" [
        memory_text: form execute_code source/text
        memory_field/text: memory_text
        output_field/text: memory_text
    ]
    
    text #2C3339 white "Memory"
    memory_field: area #13181E 200x100 font source_font
    
    text #2C3339 white "Output"
    output_field: area #13181E 200x200 font source_font
]	
