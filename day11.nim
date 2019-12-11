from strutils import parseInt, split
import intcode
import tables
import strformat
import sequtils

###
### The program
###

# Turns (2nd output)
const
    Up = 0
    Right = 1
    Down = 2
    Left = 3

type Panel = TableRef[int, TableRef[int, int]]
type Position = tuple[x: int, y: int]


proc getColor(panel: Panel, pos: Position): int = 
    if not panel.hasKey(pos.x):
        panel[pos.x] = newTable[int, int]()
    
    return panel[pos.x].getOrDefault(pos.y, 0)

proc setColor(panel: Panel, pos: Position, color: int) = 
    if not panel.hasKey(pos.x):
        panel[pos.x] = newTable[int, int]()
    panel[pos.x][pos.y] = color


let input = readFile("input/day11.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

proc paint(startColor: int): (int, Panel) =
    let robot = newIntCodeComputer(program)
    var panel: Panel = newTable[int, TableRef[int, int]]() 
    var position: Position = (0, 0)
    var direction: int = Up

    panel.setColor(position, startColor)

    var done = false
    while not done:
        robot.addInput(panel.getColor(position))
        let (stop, output) = robot.runProgram()

        if stop == Halt:
            done = true
            break

        let color = output[0]
        let turn = output[1]

        panel.setColor(position, color)

        if turn == 0: direction -= 1
        if turn == 1: direction += 1
        if direction < 0: direction = 3
        if direction > 3: direction = 0

        case direction
        of Up:
            position.y += 1
        of Down:
            position.y -= 1
        of Left:
            position.x -= 1
        of Right:
            position.x += 1
        else:
            echo &"Unknown direction: {direction}"

        # echo &"{position}: {output}"
        # discard readLine(stdin)

    var 
        count = 0
        countBlack = 0
        countWhite = 0
    for row in panel.values:
        for col in row.values:
            # stdout.write(col)
            count += 1
            if col == 0: countBlack += 1
            else: countWhite += 1
        # stdout.write("\n")
    
    return (count, panel)

let (count1, _) = paint(0) # start with black
echo "Total panels colored: ", count1 # Part 1


let (_, panel2) = paint(1) # start with white

# find the "borders" of the painting
let minx = min(toSeq(panel2.keys))
let maxx = max(toSeq(panel2.keys))
var miny = 5000
var maxy = -5000

for px in panel2.values:
    miny = min(miny, min(toSeq(px.keys)))
    maxy = max(maxy, max(toSeq(px.keys)))

# Part 2: draw the painting
for i in countdown(maxy, miny):
    for j in minx..maxx:
        let c = panel2.getColor((j, i))
        case c
        of 0: stdout.write("█")
        of 1: stdout.write(" ")
        else: stdout.write("░")
    stdout.write("\n")
