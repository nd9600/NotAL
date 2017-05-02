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

def generate_token_stream(lines):
    tokens = []
    patching_dict = {}
    currentPosition = 0
    
    for line in lines:
        if (len(line) == 0):
            continue        
        
        #if label definition found, put label and position in label table
        if (line.lstrip(" ")[0] == "."):
            label_info = line.strip(" ")[1:].strip(" ").split(":")
            label = label_info[0].strip(" ")
            
            label_table[label] = currentPosition
            
            #if the label definition has data, it is a variable
            #otherwise, it's just a position, and we don't need to do anything
            if (len(label_info) > 1):
                label_data = label_info[1].strip(" ")
                
                try: #label_data is an int 
                    tokens.append(int(label_data))
                    currentPosition = currentPosition + 1 
                except ValueError: #label_data is a string   
                    for character in label_data:
                        tokens.append(ord(character))
                        currentPosition = currentPosition + 1 
        else:
            split_line = line.strip(" ").split(" ")
            for item in split_line:
                try: #item is a number, add to token stream
                    tokens.append(int(item))
                    currentPosition = currentPosition + 1 
                except ValueError: #item is a label, put currentPosition in patching_dict
                    tokens.append(0)
                    patching_dict[currentPosition] = item
                    currentPosition = currentPosition + 1  
    
    #patch labels
    #position is the position in the tokens that needs to be patched
    #patching_dict[position] gives the label it needs to patch from
    #label_table[label] gives the position it needs to patch to        
    for position in patching_dict:
        tokens[position] = label_table[patching_dict[position]]
      
    return tokens

def lex(input_file):
    original_lines = input_file.readlines()
    
    #strip newlines from the end of lines
    stripped_lines = [line.rstrip('\n').rstrip('\r') for line in original_lines]
    
    #remove blank lines
    non_blank_lines = [line for line in stripped_lines[:] if (len(line) > 0)]
    
    #
    token_stream = generate_token_stream(non_blank_lines)    
    
    print("\nlexing")
    print("original_lines: {0}".format(original_lines))
    print("stripped_lines: {0}".format(stripped_lines))
    print("non_blank: {0}".format(non_blank_lines))
    print("label_table: {0}".format(label_table))
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
        a = memory[pc]
        b = memory[pc+1]
        c = memory[pc+2]
        
        if number_of_tokens >= 2:
            b = line[1]
            if number_of_tokens == 3:
                c = line[2]
            else:
                c = "?"
        else:
            b = a
        
        print("\na: {0}".format(a))
        print("b: {0}".format(b))
        print("c: {0}".format(c))
        
        if (c == -1):
            print("input")
        elif (c == -2):
            print(memory[a])
        #else:
        #    
        #memory[b] = memory[b] - memory[a]
        #if (memory[b] == 0):
        #    pc = c
        #else:
        #    pc = pc + 1

def execute_file(file_name):
    with open(file_name, 'r') as input_file:
        token_stream = lex(input_file)
        run(token_stream)      
        
if len(argv) > 1:
    execute_file(argv[1])
