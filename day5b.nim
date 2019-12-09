import strutils
import intcode


let input = readFile("input/day5.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let c1 = newIntCodeComputer(program)
c1.addInput(1)
echo c1.runProgram(debug = true)

let c2 = newIntCodeComputer(program)
c2.addInput(5)
echo c2.runProgram()
