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
                append memory add length? memory 2
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
        some [
            [label | command] opt thru newline
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
    while [lesser? pc length? memory] [
        ask ""
        if error? err: try [
            a: pick memory add pc 1
            b: pick memory add pc 2
            c: pick memory add pc 3
            
            print copy ""
            print append copy "pc: " pc
            print append copy "a: " a
            print append copy "b: " b
            print append copy "c: " c
            
            either (equal? b -1) [
                if error? poke memory a to-int input [
                    poke memory (add a 1) to-int to-string input
                ]
            ] [
                either (equal? b -2) [
                    print pick memory (add a 1)
                    attempt print to-string pick memory (add a 1)
                ] [
                    poke memory (add b 1) subtract pick memory (add b 1) pick memory (add a 1)
                ]
            ]
            
            if (lesser? c -1) [
                print "c < -1" break
            ]
            
            either all [ (lesser-or-equal? (pick memory (add b 1)) 0) (greater-or-equal? c 0) ] [
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

;;;;;;;;;;;;;;;;;;;;;;;;;

reload: does [do system/options/script]

parser-demo: {
base 200x200 transparent rate 1 now draw [
    scale 2 2
    fill-pen #0B79CE pen off
    circle 50x50 45
    line-width 2
    hour: rotate 0 50x50 [pen #023963 line 50x50 50x20]
    min:  rotate 0 50x50 [pen #023963 line 50x50 50x10]
    sec:  rotate 0 50x50 [pen #CE0B46 line 50x50 50x10]
] on-time [
    time: now/time
    hour/2: 30 * time/hour
    min/2:  6  * time/minute
    sec/2:  6  * time/second
]
}

execute-code: func [input_code [string!]][
    return input_code
]

system/view/silent?: yes

view [
	title "Red subleq parser demo"
	backdrop #2C3339
	across
	
	source: area #13181E 410x300 no-border parser-demo font [
		name: font-fixed
		size: 9
		color: hex-to-rgb #9EBACB
	]
	
	panel 200x300 #2C3339 react [
		attempt/safer [face/pane: layout/tight/only load source/text]
	]
]	
