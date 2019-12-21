import strutils
import strformat
import seq2d
import tables
import heapqueue

###
### The program
###

let f = open("input/day20.txt")
var donut: Seq2d[char] = newSeq2d[char](' ')

while not f.endOfFile():
  let line = f.readLine()
  for i, c in line:
    if donut.width() == 0: donut.width(line.len)
    donut.add(c)
f.close()

proc isDeadEndAt(s: Seq2d, x, y: int): bool =
    var walls = 0
    for (i, j) in [(+1, 0), (-1, 0), (0, +1), (0, -1)]:
        let sq = s.get(x + i, y + j)
        if sq == '#' or sq == '%': walls += 1
    return walls >= 3

proc fillDeadEnds(s: var Seq2d) =
    var countPrev = 0
    while true:
        var count = s.count('.')

        if count == countPrev:
            break

        for i in 0..<s.width():
            for j in 0..<s.height():
                case s.get(i, j)
                of '.':
                    if s.isDeadEndAt(i, j):
                        s.put(i, j, '%')
                else: discard

        countPrev = count

donut.print
donut.fillDeadEnds
donut.print

proc getTeleportPositions(donut: Seq2d): Table[string, (int, int)] =
    var teles = initTable[string, (int, int)]()
    # echo &"w={donut.width()}, h={donut.height()}"
    # outer top and bottom rows
    for i in 2..donut.width()-2:
        if donut.get(i, 2) == '.':
            let name = donut.get(i, 0) & donut.get(i, 1)
            # echo &"Teleport {name} at x={i-2}, y={2-2}"
            teles[name&'o'] = (i-2, 0)
        if donut.get(i, donut.height()-3) == '.':
            let name = donut.get(i, donut.height()-2) & donut.get(i, donut.height()-1)
            # echo &"Teleport {name} at x={i-2}, y={donut.height()-3-2}"
            teles[name&'o'] = (i-2, donut.height()-5)

    # outer left and right columns
    for i in 2..donut.height()-2:
        if donut.get(2, i) == '.':
            let name = donut.get(0, i) & donut.get(1, i)
            # echo &"Teleport {name} at x={2-2}, y={i-2}"
            teles[name&'o'] = (0, i-2)
        if donut.get(donut.width()-3, i) == '.':
            let name = donut.get(donut.width()-2, i) & donut.get(donut.width()-1, i)
            # echo &"Teleport {name} at x={donut.width()-3-2}, y={i-2}"
            teles[name&'o'] = (donut.width()-5, i-2)

    # find inner corners
    var
        donutWidth = 0
        donutHeight = 0
    for i in 2..donut.height():
        if not (donut.get(int(donut.width()/2), i) in {'.', '#', '%'}): break
        donutHeight += 1
    for i in 2..donut.width():
        if not (donut.get(int(donut.height()/2), i) in {'.', '#', '%'}): break
        donutWidth += 1

    # echo &"Donut size is w={donutWidth}, h={donutHeight}"
    let innerTop = donutHeight
    let innerBottom = donut.height()-3-donutHeight-2
    let innerRight = donut.width()-3-donutWidth-2
    let innerLeft = donutWidth
    # echo &"Inner top is at {innerTop}"
    # echo &"Inner bottom is at {innerBottom}"
    # echo &"Inner right is at {innerRight}"
    # echo &"Inner left is at {innerLeft}"

    # inner top and bottom rows
    for i in innerLeft..innerRight:
        if donut.get(i+2, innerTop-1+2) == '.':
            let name = donut.get(i+2, innerTop-1+2+1) & donut.get(i+2, innerTop-1+2+2)
            # echo &"Teleport {name} at x={i+2-2}, y={innerTop-1+2-2}"
            teles[name&'i'] = (i, innerTop-1)
        if donut.get(i+2, innerBottom+1+2) == '.':
            let name = donut.get(i+2, innerBottom+1+2-2) & donut.get(i+2, innerBottom+1+2-1)
            # echo &"Teleport {name} at x={i+2-2}, y={innerBottom+1+2-2}"
            teles[name&'i'] = (i, innerBottom+1)

    # inner left and right columns
    for i in innerTop..innerBottom:
        if donut.get(innerLeft+2-1, i+2) == '.':
            let name = donut.get(innerLeft+2-1+1, i+2) & donut.get(innerLeft+2-1+2, i+2)
            # echo &"Teleport {name} at x={innerLeft+2-1-2}, y={i+2-2}"
            teles[name&'i'] = (innerLeft-1, i)
        if donut.get(innerRight+2+1, i+2) == '.':
            let name = donut.get(innerRight+2+1-2, i+2) & donut.get(innerRight+2+1-1, i+2)
            # echo &"Teleport {name} at x={innerRight+2+1-2}, y={i+2-2}"
            teles[name&'i'] = (innerRight+1, i)

    return teles

proc traverse(donut: Seq2d, start: (int, int)): Table[(int, int), int] =
    var distances = initTable[(int, int), int]()
    var queue: seq[(int, int, int)] = @[]
    queue.add((start[0], start[1], 0))
    while queue.len > 0:
        var current = queue.pop()
        distances[(current[0], current[1])] = current[2]

        for (i, j) in [(+1, 0), (-1, 0), (0, +1), (0, -1)]:
            if not distances.hasKey((current[0]+i, current[1]+j)):
                let c = donut.get(current[0]+i+2, current[1]+j+2)
                if c == '.':
                    let next = (current[0]+i, current[1]+j, current[2]+1)
                    queue.add(next)

    return distances


type TeleTravel = tuple[name: string, d: int]
proc `<`(tele1, tele2: TeleTravel): bool = tele1.d < tele2.d

proc travelDistance(donut: Seq2d, teleDists: Table[string, Table[string, int]], startTele, endTele: string): int =
    var shortestDists: Table[string, int] = initTable[string, int]()
    var queue = initHeapQueue[TeleTravel]()
    let start = (name: startTele, d: 0)
    queue.push(start)
    while queue.len > 0:
        echo queue
        echo "------------"
        let current: TeleTravel = queue.pop()

        if shortestDists.hasKey(current.name) and shortestDists[current.name] <= current.d:
            continue

        shortestDists[current.name] = current.d

        for (rName, rDist) in teleDists[current.name].pairs:
            let newDist = current.d + rDist + 1
            if shortestDists.hasKey(rName) and shortestDists[rName] <= newDist:
                continue

            queue.push((rName, newDist))

    return shortestDists[endTele]

# When fetching teleport positions, their names are marked XXi for inner tele and
# XXo for outer teleport
let teleports = getTeleportPositions(donut)
echo teleports

# In the teleport distance matrix, we don't care if the teleport is outer or
# inner, thus interested in only first two letters (the actual teleport name)
var teleportDistanceMatrix: Table[string, Table[string, int]] = initTable[string, Table[string, int]]()
for tele in teleports.keys:
    if not teleportDistanceMatrix.hasKey(tele[0..1]):
        teleportDistanceMatrix[tele[0..1]] = initTable[string, int]()

    for (pos, dist) in donut.traverse(teleports[tele]).pairs:
        for (telName, telPos) in teleports.pairs:
            if pos == telPos and dist != 0:
                # echo &"Distance from {tele[0..1]} to {telName[0..1]} is {dist}."
                teleportDistanceMatrix[tele[0..1]][telName[0..1]] = dist

# echo teleportDistanceMatrix["AA"]
# echo teleportDistanceMatrix["AS"]
# echo teleportDistanceMatrix["QG"]
# echo teleportDistanceMatrix["BU"]
# echo teleportDistanceMatrix["JO"]

echo donut.travelDistance(teleportDistanceMatrix, "AA", "ZZ") - 1 # Part 1
