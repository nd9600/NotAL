#!/usr/bin/python

# subleq a, b, c   ; Mem[b] = Mem[b] - Mem[a]
#                  ; if (Mem[b] = 0) goto c

# . at start means it's not an instruction
# a:b defines a label a to be b
# z always = 0

# ? ; next line
# a ; same as a a ?
# a b ; same as a b ?

# a = 0
# a a  => a = a - a = 0
# a a

# jmp c
# Z Z c ; 0-0=0, jmp c

# add a, b
# a Z ; Z = Z - a = -a
# Z b ; b = b - z = b - -a = b + a
# Z Z ; Z = Z - Z = 0

# mov a, b
# b b ; b = 0
# a Z ; Z = -a
# Z b ; b = a + 0 = a
# Z Z ; Z = 0

from sys import argv

label_table = {}

def resolve_labels(lines):
    for line in lines:
        if (len(line) == 0):
            continue
        
        line = line.lstrip(" ")
        if (line[0] == "."):
            line = line.lstrip(".").lstrip(" ")
            split_line = line.split(":")
            label_table[split_line[0]] = split_line[1]
            
    resolved_lines = []
            
    for index, line in enumerate(lines):
        if (len(line) == 0 or line.lstrip(" ")[0] == "."):
            continue        
        for key in label_table:
            line = line.replace(key, label_table[key])
        
        resolved_lines.append(line)
    return resolved_lines

def lex(input_file):
    original_lines = input_file.readlines()
    
    stripped_lines = [line.rstrip('\n').rstrip('\r') for line in original_lines]
    resolved_lines = resolve_labels(stripped_lines)
    split_lines =  [line.split(" ") for line in resolved_lines]
    token_stream = [map(int, line) for line in split_lines]
    
    print("lexing")
    print("stripped_lines: {0}".format(stripped_lines))
    print("resolved_lines: {0}".format(resolved_lines))
    print("split_lines: {0}".format(split_lines))
    print("token_stream: {0}".format(token_stream))
    
    return token_stream
    
    
# ? ; next line
# a ; same as a a ?
# a b ; same as a b ?
def run(memory):    
    print("\nrunning")
    print("memory: {0}".format(memory))
    
    pc = 0;
    while (pc < len(memory)):
        line = memory[pc]
        number_of_tokens = len(line)
        
        a = line[0]
        
        if number_of_tokens >= 2:
            b = line[1]
        else:
            b = a
        
        print("\na: {0}".format(a))
        print("b: {0}".format(b))
        
        pc = pc + 1

def execute_file(file_name):
    with open(file_name, 'r') as input_file:
        token_stream = lex(input_file)
        run(token_stream)      
        
if len(argv) > 1:
    execute_file(argv[1])
