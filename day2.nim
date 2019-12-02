from strutils import parseInt, split

const 
    OpAdd = 1
    OpMul = 2

proc runProgram(inputProgram: seq[int], noun: int, verb: int): int =
    var program = inputProgram # copy sequence
    program[1] = noun
    program[2] = verb

    var i = 0 # instruction pointer

    while program[i] != 99:
        let opc = program[i]
        case opc
        of OpAdd:
            # echo "Add ", i
            program[program[i+3]] = program[program[i+2]] + program[program[i+1]]
        of OpMul:
            # echo "Mul ", i
            program[program[i+3]] = program[program[i+2]] * program[program[i+1]]
        else:
            discard
            # echo program[i]
        i += 4
        # echo program

    return program[0]


let input = readFile("input/day2.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

block outer:
    for noun in 1..99:
        for verb in 1..99:
            let res = runProgram(program, noun, verb)
            # echo res
            if res == 19690720:
                echo "noun=", noun, " verb=", verb
                echo 100 * noun + verb
                break outer
