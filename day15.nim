from strutils import parseInt, split
import intcode
import tables
import sequtils
import strformat

###
### Type definitions and procedures
###

type Move = enum
    North = 1
    South = 2
    West  = 3
    East  = 4

type Square = enum
    Wall    = 0
    Empty   = 1
    System  = 2
    DeadEnd = 3
    Oxygen  = 4
    Unknown = 5

type Room = TableRef[int, TableRef[int, int]]
type Position = tuple[x: int, y: int]

proc getSquare(room: Room, pos: Position): Square =
    if not room.hasKey(pos.x):
        room[pos.x] = newTable[int, int]()

    return Square(room[pos.x].getOrDefault(pos.y, Unknown.ord))

proc setSquare(room: Room, pos: Position, square: Square) =
    if not room.hasKey(pos.x):
        room[pos.x] = newTable[int, int]()
    room[pos.x][pos.y] = square.ord

proc size(room: Room): (int, int, int, int) =
    # find the discovered "borders" of the room
    let minx = min(toSeq(room.keys))
    let maxx = max(toSeq(room.keys))
    var miny = 5000
    var maxy = -5000

    for px in room.values:
        miny = min(miny, min(toSeq(px.keys)))
        maxy = max(maxy, max(toSeq(px.keys)))

    return (minx, maxx, miny, maxy)

proc hasUnknownNeighbours(room: Room, position: Position): bool =
    for (i, j) in [(+1, 0), (-1, 0), (0, +1), (0, -1)]:
        if room.getSquare((x: position.x + i, y: position.y + j)) == Unknown:
            return true

proc isDeadEnd(room: Room, position: Position): bool =
    var walls = 0
    for (i, j) in [(+1, 0), (-1, 0), (0, +1), (0, -1)]:
        let sq = room.getSquare((x: position.x + i, y: position.y + j))
        if sq == Wall or sq == DeadEnd: walls += 1
    return walls >= 3

proc hasEmptySquares(room: Room): bool =
    let (minx, maxx, miny, maxy) = room.size
    for i in countdown(maxy, miny):
        for j in countup(minx, maxx):
            case room.getSquare((x: j, y: i))
            of Empty, DeadEnd: return true
            else: discard
    return false

proc fillDeadEnds(room: Room) =
    let (minx, maxx, miny, maxy) = room.size
    # Draw the discovered part of room
    for i in countdown(maxy, miny):
        for j in countup(minx, maxx):
            if i == 0 and j == 0: continue

            case room.getSquare((x: j, y: i))
            of Empty:
                if isDeadEnd(room, (x: j, y: i)):
                    room[j][i] = DeadEnd.ord
            of Unknown:
                room[j][i] = Wall.ord
            else: discard

proc vent(room: Room) =
    let (minx, maxx, miny, maxy) = room.size
    var oxyPositions: seq[Position] = @[]
    for i in countdown(maxy, miny):
        for j in countup(minx, maxx):
            case room.getSquare((x: j, y: i))
            of System, Oxygen:
                oxyPositions.add((x: j+1, y: i))
                oxyPositions.add((x: j-1, y: i))
                oxyPositions.add((x: j, y: i+1))
                oxyPositions.add((x: j, y: i-1))
            else: discard

    for pos in oxyPositions:
        case room.getSquare(pos)
        of Empty, DeadEnd:
            room[pos.x][pos.y] = Oxygen.ord
        else:
            discard

proc draw(room: Room, dronePosition: Position) =
    let (minx, maxx, miny, maxy) = room.size
    # Draw the discovered part of room
    for i in countdown(maxy, miny):
        for j in countup(minx, maxx):
            if dronePosition.x == j and dronePosition.y == i:
                stdout.write("D")
            else:
                case room.getSquare((x: j, y: i))
                of Wall:    stdout.write("█")
                of Empty:   stdout.write(".")
                of System:  stdout.write("Ø")
                of Oxygen:  stdout.write("O")
                of Unknown: stdout.write("░")
                of DeadEnd: stdout.write("▓")
        stdout.write("\n")

###
### The program
###

let input = readFile("input/day15.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))


var room = Room()
room.setSquare((x: 0, y: 0), Empty)

var next: seq[(IntCodeComputer, Position)] = @[]
next.add((newIntCodeComputer(program), (x: 0, y: 0)))

while next.len > 0:
    let (popDrone, position) = next.pop()
    # echo position, "   ", next.len

    for input in [North, South, West, East]:
        let drone = popDrone.clone
        drone.addInput(input.ord)
        let (_, output) = drone.runProgram()

        var potentialPosition: Position
        case Move(input):
        of North: potentialPosition = (x: position.x, y: position.y+1)
        of South: potentialPosition = (x: position.x, y: position.y-1)
        of East:  potentialPosition = (x: position.x+1, y: position.y)
        of West:  potentialPosition = (x: position.x-1, y: position.y)

        case Square(output[0])
        of Wall:
            room.setSquare(potentialPosition, Wall)
            # echo &"At position {potentialPosition} is Wall."
        of Empty:
            room.setSquare(potentialPosition, Empty)
            if room.hasUnknownNeighbours(potentialPosition):
                next.add((drone, potentialPosition))
                # echo &"Adding position {potentialPosition} to queue."
            # echo &"At position {potentialPosition} is nothing."
        of System:
            room.setSquare(potentialPosition, System)
            # echo &"At position {potentialPosition} is Oxygen tank."
        else:
            discard

echo "-------------- EXPLORED ROOM --------------"
room.draw((x: 0, y: 0))
echo "-------------- ------------- --------------"

# Let's fill dead-ends!
for runs in 1..100:
    room.fillDeadEnds

echo "------------ NO-DEAD-ENDS ROOM ------------"
room.draw((x: 0, y: 0))
echo "------------ ----------------- ------------"

# With dead-end paths filled, simply count all the empty
# squares (the path from drone to system).
var count = 0
let (minx, maxx, miny, maxy) = room.size
for i in countdown(maxy, miny):
    for j in countup(minx, maxx):
            case room.getSquare((x: j, y: i))
            of Empty  : count += 1
            else: discard

# Fill empty space with oxygen, taking only neighbours
# of current oxygen squares each step.
# Note: since this is all happening in the same room, also
# fill with oxygen squares that are marked "dead-end" from
# part 1.
var minutes = 0
while room.hasEmptySquares:
    room.vent
    minutes += 1

echo "----------- OXYGEN-VENTED ROOM ------------"
room.draw((x: 0, y: 0))
echo "----------- ------------------ ------------"

echo "Steps count: ", count # Part 1
echo "Minutes taken: ", minutes # Part 2