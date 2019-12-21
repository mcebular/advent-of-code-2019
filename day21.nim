import strutils
import intcode
import strformat

###
### The program
###

let input = readFile("input/day21.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let droid = newIntCodeComputer(program)

proc toString(str: seq[int]): string =
    var res = ""
    for ch in str:
        if ch < 255:
            res = res & char(ch)
        else:
            res = res & (&"{ch}")

    return res

proc part1(droid: IntCodeComputer) =
    droid.addInput("OR D T\nAND C T\nNOT T J\nAND J T\nAND D J\nNOT A T\nOR T J\n")
    droid.addInput("WALK\n")

    let (_, output) = droid.runProgram
    echo output.toString

proc part2(droid: IntCodeComputer) =
    droid.addInput("NOT T J\nAND A J\nAND B J\nAND C J\nNOT J J\nAND D J\n")
    droid.addInput("OR E T\nOR H T\nAND T J\n")
    droid.addInput("RUN\n")

    let (_, output) = droid.runProgram
    echo output.toString

part1(droid.clone)
part2(droid.clone)
