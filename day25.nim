import seq2d
import strformat
import strutils
import intcode
import tables
import math


proc toString(str: seq[int]): string =
    var res = ""
    for ch in str:
        if ch < 255:
            res = res & char(ch)
        else:
            res = res & (&"{ch}")

    return res

let input = readFile("input/day25.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let droid = newIntCodeComputer(program)

# -----
# while true:
#     let (_, output) = droid.runProgram
#     echo output.toString

#     let input = stdin.readLine
#     droid.addInput(input & '\n')
# -----

# Part 1: item (path from start)
# candy cane (west, west)
# coin (west, west, north)
# mouse (south, west)
# semiconductor (north, west, north, west)

droid.addInput("north\neast\nnorth\neast\ntake semiconductor\n")
droid.addInput("west\nsouth\nwest\nsouth\n")
droid.addInput("east\neast\ntake candy cane\n")
droid.addInput("west\nnorth\ntake coin\n")
droid.addInput("south\nwest\n")
droid.addInput("south\neast\ntake mouse\n")
droid.addInput("south\nwest\n")
let (_, output) = droid.runProgram
echo output.toString

