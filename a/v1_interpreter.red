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

parser: func [lines [string!]][    
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

cli_vm: func [memory [block!]][
    probe memory
    
    pc: 0
    while [lesser? pc length? memory] [
        ask ""
        if error? err: try [
            a: pick memory add pc 1
            b: pick memory add pc 2
            c: pick memory add pc 3
            
            real_a: add a 1
            real_b: add b 1
            
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
                    print pick memory (add a 1)
                    attempt print to-string pick memory (add a 1)
                ] [
                    poke memory real_b subtract pick memory real_b pick memory real_a
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
        
    ]  
    probe memory
]

gui_vm: func [memory [block!]][
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