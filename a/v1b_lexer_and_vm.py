Red []

bf: func [prog [string!]][
    size: 30000
    cells: make string! size
    append/dup cells null size

    parse prog [
        some [
              ">" (cells: next cells)
            | "<" (cells: back cells)
            | "+" (cells/1: cells/1 + 1)
            | "-" (cells/1: cells/1 - 1)
            | "." (prin cells/1)
            | "," (cells/1: first input "")
            | "[" [if (cells/1 = null) thru "]" | none]
            | "]" [
               pos: if (cells/1 <> null)
               (pos: find/reverse pos #"[") :pos
               | none
              ]
            | skip
        ]
    ]
]

apply: func [f  block [block!]] [
    repeat i length? block [
        poke block i f pick block i
    ] 
    block
]

{
syntactic: func [prog [string!]][
    lines: split prog newline
    apply :to-block lines
    parser 
]
}
parser: func [lines [string!]][

    
    memory: copy []
    {
    digit:      charset "0123456789"
    minus:      charset "-"
    address:  union digit minus
    rules: [
            thru 1 address copy data (append/dup memory data 2)
        |   thru 2 address copy data (append memory data)
        |   thru 3 address copy data (append memory data)
    ]
    
    parse lines rules
    probe memory
    }
    data: 666
    parse #{FFFFDECAFBAD000000} [
        2 #{FF}
        copy data (print data) 
        to #{00} 
        some #{00}
    ]
    
    memory
]


vm: func [memory [block!]][
    probe memory
    foreach line memory [
        probe line
    ]
]

input_code: {3 4 6
7 7 7
0 0 0}

tokens: parser input_code
vm tokens

; This code will print a Hello World! message
;bf {++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.}

; This one will print a famous quote
;bf {++++++++[>+>++>+++>++++>+++++>++++++>+++++++>++++++++>+++++++++>++++++++++>+++++++++++>++++++++++++>++++++++     +++++>++++++++++++++>+++++++++++++++>++++++++++++++++<<<<<<<<<<<<<<<<-]>>>>>>>>>>>----.++++<<<<<<<<<<<>>>>>>>     >>>>>>.<<<<<<<<<<<<<>>>>>>>>>>>>>---.+++<<<<<<<<<<<<<>>>>>>>>>>>>>>++.--<<<<<<<<<<<<<<>>>>>>>>>>>>>---.+++<<<<     <<<<<<<<<>>>>.<<<<>>>>>>>>>>>>>+.-<<<<<<<<<<<<<>>>>>>>>>>>>>>+++.---<<<<<<<<<<<<<<>>>>.<<<<>>>>>>>>>>>>>>--.++     <<<<<<<<<<<<<<>>>>>>>>>>>>>>-.+<<<<<<<<<<<<<<>>>>.<<<<>>>>>>>>>>>>>>+++.---<<<<<<<<<<<<<<>>>>>>>>>>>>>>.<<<<<<     <<<<<<<<>>>>>>>>>>>>>>-.+<<<<<<<<<<<<<<>>>>>>>>>>>>>>-.+<<<<<<<<<<<<<<>>>>>>>>>>>>>>--.++<<<<<<<<<<<<<<>>>>+.-<<<<.}