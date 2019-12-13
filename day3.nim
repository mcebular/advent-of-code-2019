import tables
import strutils

###
### Type definitions
###

type PanelY = TableRef[int, set[int16]]
type PanelX = TableRef[int, PanelY]
type Point = tuple[x: int, y: int]
type WireCrossDist = tuple[a: int, b: int]

###
### Type procedures
###

proc addWire(panel: var PanelX, w: int16, x: int, y: int): int =
    discard panel.hasKeyOrPut(x, PanelY())
    discard panel[x].hasKeyOrPut(y, {})
    panel[x][y] = panel[x][y] + {w}
    # echo "Adding wire at ", x, ", ", y, ". Has ", panel[x][y].len, " wire."
    return panel[x][y].len

proc distance(point: Point): int =
    abs(0 - point.x) + abs(0 - point.y)

proc `<`(p1: Point, p2: Point): bool =
    p1.distance < p2.distance

proc sum(wcd: WireCrossDist): int =
    wcd[0] + wcd[1]

###
### Utility procedures
###

proc readInput(): seq[string] =
    let f = open("input/day3.txt")
    defer: f.close()

    var lines : seq[string] = @[]
    while not f.endOfFile():
        let line = f.readLine()
        lines.add(line)

    return lines

var panel = PanelX()

proc walkWire(wid: int16, wire: string, action: proc) =
    var
        x = 0
        y = 0
        t = 0
    for move in wire.split(','):
        let amount = move[1..<move.len].parseInt - 1
        let direction = move[0]

        for i in 0..amount:
            case direction
            of 'R': x += 1
            of 'L': x -= 1
            of 'U': y += 1
            of 'D': y -= 1
            else: discard
            t += 1
            action(wid, x, y, t)

###
### The program
###

let input = readInput()
var w: int16 # wire "id" (either 0 or 1)

# Part 1
var crosses: seq[Point] = @[]

proc saveCrosses(w: int16, x, y, t: int) =
    if panel.addWire(w, x, y) == 2:
        crosses.add((x, y))

w = 0
for line in input:
    walkWire(w, line, saveCrosses)
    w += 1
#[echo crosses
for cross in crosses:
    echo cross, " d=", cross.distance]#
echo min(crosses).distance

# Part 2
var crossDists = newTable[Point, WireCrossDist]()

proc distCrosses(w: int16, x, y, t: int) =
    if panel[x][y].len == 2:
        # echo "wid=", w, ", x=", x, ", y=", y, ", t=", t
        let key = (x, y).Point
        discard crossDists.hasKeyOrPut(key, (-1, -1))

        case w
        of 0: crossDists[key][0] = t
        of 1: crossDists[key][1] = t
        else: discard

w = 0
for line in input:
    walkWire(w, line, distCrosses)
    w += 1

var minsum = -1
for v in crossDists.values:
    if v.sum < minsum or minsum == -1:
        minsum = v.sum
echo minsum