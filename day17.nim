from strutils import parseInt, split
import intcode
import tables
import sequtils
import strformat

###
### Type definitions and procedures
###

###
### The program
###

type Seq2d = ref object of RootObj
    field: seq[int]
    width: int
    default: int

proc newSeq2d(defaultValue: int): Seq2d =
    let s = Seq2d()
    s.field = newSeq[int](0)
    s.width = 0
    s.default = defaultValue
    return s

proc getWidth(s: Seq2d): int =
    return s.width

proc setWidth(s: Seq2d, w: int) =
    s.width = w

proc getHeight(s: Seq2d): int =
    return int(s.field.len / s.width)

proc add(s: Seq2d, value: int) =
    s.field.add(value)

proc put(s: Seq2d, x, y: int, value: int) =
    let p = x + y * s.width
    while s.field.len < p:
        s.field.add(s.default)
    s.field[p] = value

proc get(s: Seq2d, x, y: int): int =
    let p = x + y * s.width
    if s.field.len < p:
        return s.default
    else:
        return s.field[p]

proc print(s: Seq2d) =
    for i, v in s.field:
        stdout.write(char(v))
        if i mod s.width == s.width-1:
            stdout.write('\n')

let input = readFile("input/day17.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let system = newIntCodeComputer(program)

let (state, output) = system.runProgram()


var camera = newSeq2d(int('?'))
for i, o in output:
    if o != 10:
        camera.add(o)
    elif camera.width == 0:
        camera.width = i

camera.print

var alignSum = 0
for x in 0..<camera.getWidth():
    for y in 0..<camera.getHeight():
        let t = camera.get(x, y)
        if t != 35: continue
        var neighs = 0
        for i in [(+1, 0),(-1, 0),(0, +1),(0, -1)]:
            if x+i[0] < 0 or x+i[0] > camera.getWidth(): continue
            if y+i[1] < 0 or y+i[1] > camera.getHeight(): continue
            if camera.get(x+i[0], y+i[1]) == 35: neighs += 1
        if neighs == 4:
            alignSum += x * y

echo alignSum # Part 1


# R12L8R6R12L8R6R12L6R6R8R6L8R8R6R12R12L8R6L8R8R6R12R12L8R6R12L6R6R8R6L8R8R6R12R12L6R6R8R6
# M = A,A,B,C,A,C,A,B,C,B  # 19 bytes
# A = R,12,L,8,R,6         # 12 bytes
# B = R,12,L,6,R,6,R,8,R,6 # 20 bytes
# C = L,8,R,8,R,6,R,12     # 16 bytes
let system2 = newIntCodeComputer(program)
system2.setMemory(0, 2)

let routines: seq[seq[int]] = @[
    map("A,A,B,C,A,C,A,B,C,B\n", proc(x: char): int = int(x)),
    map("R,12,L,8,R,6\n", proc(x: char): int = int(x)),
    map("R,12,L,6,R,6,R,8,R,6\n", proc(x: char): int = int(x)),
    map("L,8,R,8,R,6,R,12\n", proc(x: char): int = int(x))
]

for routine in routines:
    for inp in routine:
        system2.addInput(inp)

system2.addInput(int('n'))
system2.addInput(int('\n'))

let (state2, output2) = system2.runProgram()
for i, o in output2:
    if o < 128:
        stdout.write(char(o))

echo output2[output2.len - 1] # Part 2