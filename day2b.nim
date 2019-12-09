from strutils import parseInt, split
import intcode


let input = readFile("input/day2.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

block outer:
    for noun in 1..99:
        for verb in 1..99:
            let icc = newIntCodeComputer(program)
            icc.setMemory(1, noun)
            icc.setMemory(2, verb)
            discard icc.runProgram()
            # echo icc.readMemory(0)
            if icc.readMemory(0) == 19690720:
                echo "noun=", noun, " verb=", verb
                echo 100 * noun + verb
                break outer
