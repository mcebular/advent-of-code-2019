from strutils import parseInt, split
import intcode
import tables
import sequtils
import strformat

###
### The program
###

type Screen = TableRef[int, TableRef[int, int]]

proc size(screen: Screen): (int, int, int, int) =
    # find the "borders" of the screen
    let minx = max(min(toSeq(screen.keys)), 0) # ignore -1 key
    let maxx = max(toSeq(screen.keys))
    var miny = 5000
    var maxy = -5000

    for px in screen.values:
        miny = min(miny, min(toSeq(px.keys)))
        maxy = max(maxy, max(toSeq(px.keys)))

    return (minx, maxx, miny, maxy)

proc countBlocks(screen: Screen): int =
    let (minx, maxx, miny, maxy) = screen.size

    var blockCount = 0
    for i in countdown(maxy, miny):
        for j in minx..maxx:
            if screen[j][i] == 2: blockCount += 1
    return blockCount

proc print(screen: Screen) =
    let (minx, maxx, miny, maxy) = screen.size
    # Draw the screen
    for i in countup(miny, maxy):
        for j in minx..maxx:
            let c = screen[j][i]
            case c
            of 0: stdout.write(" ")
            of 1: stdout.write("█")
            of 2: stdout.write("░")
            of 3: stdout.write("+")
            of 4: stdout.write("O")
            else: stdout.write("?")
        stdout.write("\n")

proc paddlePosition(screen: Screen): (int, int) =
    let (minx, maxx, miny, maxy) = screen.size
    for i in countup(miny, maxy):
        for j in minx..maxx:
            if screen[j][i] == 3:
                return (j, i)

proc ballPosition(screen: Screen): (int, int) =
    let (minx, maxx, miny, maxy) = screen.size
    for i in countup(miny, maxy):
        for j in minx..maxx:
            if screen[j][i] == 4:
                return (j, i)

proc outputToScreen(output: seq[int], screen: var Screen) =
    for i in countup(0, output.len-1, 3):
        let
            x = output[i]
            y = output[i + 1]
            t = output[i + 2]

        if not screen.hasKey(x):
            screen[x] = newTable[int, int]()
        screen[x][y] = t

let input = readFile("input/day13.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let arcade = newIntCodeComputer(program)
let (_, output) = arcade.runProgram()

var screen: Screen = newTable[int, TableRef[int, int]]()

outputToScreen(output, screen)

echo screen.countBlocks() # Part 1

# screen.print()

let arcade2 = newIntCodeComputer(program)
arcade2.setMemory(0, 2)
var state = Wait

var score = 0
while state != Halt:
    # Note: print the screen makes it really slow
    # screen.print()
    # echo "-----"

    let (s, output) = arcade2.runProgram()

    outputToScreen(output, screen)
    state = s
    score = screen[-1][0]

    # track ball with the paddle
    let
        paddle = screen.paddlePosition[0]
        ball = screen.ballPosition[0]
    # echo screen.paddlePosition
    # echo screen.ballPosition
    if ball < paddle:
        arcade2.addInput(-1)
    elif ball > paddle:
        arcade2.addInput(+1)
    else:
        arcade2.addInput(0)

echo "Final score: ", score # Part 2