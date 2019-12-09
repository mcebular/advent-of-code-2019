from strutils import parseInt, split
import intcode

###
### The program
###

let input = readFile("input/day9.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let c1 = newIntCodeComputer(program)
c1.addInput(1)
echo c1.runProgram()

let c2 = newIntCodeComputer(program)
c2.addInput(2)
echo c2.runProgram()
