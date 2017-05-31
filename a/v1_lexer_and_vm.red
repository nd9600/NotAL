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
    foreach line memory [
        probe line
    ]
]

input_code: {Z Z
.Z:666}

tokens: parser input_code
vm tokens