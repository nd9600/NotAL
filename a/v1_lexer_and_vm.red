Red []

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
        (label-table/(data): add length? memory 1)
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
                patching-table/(add length? memory  1): data
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
        if error? err: try [
        
            ; breaks because of rebol's zero indexed arrays
            a: pick memory add pc 0
            b: pick memory add pc 1
            c: pick memory add pc 2
            
            print ""
            print append copy "pc: " pc
            print append copy "a: " a
            print append copy "b: " b
            print append copy "c: " c
            
            ;input into a if b == -1
            ;output a if b == -2
            ;quit if (c < -1)
            ;jump to c if (memory[b] <= 0) and (c >= 0)
            
            either (equal? b -1) [
                if error? poke memory a to-int input [
                    poke memory a to-int to-string input
                ]
            ] [
                either (equal? b -2) [
                    print pick memory a
                    attempt print to-string pick memory a
                ] [
                    poke memory b subtract pick memory b pick memory a
                ]
            ]
            
            if (lesser? c -1) [
                print "c < -1"
                break
            ]
            
            either ((lesser-or-equal? pick memory b 0) and (greater-or-equal? c 0)) [
                pc: c                
            ] [
                pc: add pc 3
            ]
        ] [
            print append "error: " err
            break
        ]
        
    ]
    ;]
    ;}
    
    probe memory
]

input_code: {3 4 6
7 7 7
0 0 0}

tokens: parser input_code
vm tokens