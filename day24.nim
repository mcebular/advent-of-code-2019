import seq2d
import strformat
import tables
import math


proc readInput(): Seq2d[char] =
    let f = open("input/day24.txt")
    defer: f.close()

    var area = newSeq2d[char]('X')
    while not f.endOfFile():
        let line = f.readLine()

        if area.width() == 0: area.width(line.len)

        for c in line:
            area.add(c)

    return area

let inputArea = readInput()

###
### Part 1
###

proc adjacentBugs(s: Seq2d[char], x, y: int): int =
    var bugCount = 0
    for (i, j) in [(1, 0), (0, 1), (-1, 0), (0, -1)]:
        if x + i >= 0 and y + j >= 0 and x + i < s.width and y + j < s.height:
            if s.get(x + i, y + j) == '#':
                bugCount += 1

    return bugCount

proc rating(s: Seq2d[char]): int =
    var acc = 0
    for i in 0..<(s.width * s.height):
        if s.at(i) == '#':
            acc += 2^i
    return acc


proc part1() =

    var area = inputArea.clone
    var ratings = initTable[int, Seq2d[char]]()
    # var steps = 1000
    while true:
        # area.print
        # echo "-----"

        # dec steps
        # if steps < 0:
        #     break

        let prevArea = area.clone
        for i in 0..<area.width:
            for j in 0..<area.height:
                let bugs = prevArea.adjacentBugs(i, j)
                let tile = prevArea.get(i, j)

                if tile == '#' and bugs != 1:
                    area.put(i, j, '.')
                elif tile == '.' and (bugs == 1 or bugs == 2):
                    area.put(i, j, '#')

        let rating = area.rating
        if ratings.hasKey(rating):
            # echo "--!--"
            # ratings[rating].print
            echo rating
            # echo "--!--"
            break
        else:
            ratings[rating] = area

###
### Part 2
###

proc getBugsOnBorder(s: Seq2d[char], x, y: int): int =
    var bugCount = 0
    if x == 1:
        # right border
        for i in 0..<s.height:
            if s.get(0, i) == '#': inc bugCount
    elif x == -1:
        # left border
        for i in 0..<s.height:
            if s.get(s.width-1, i) == '#': inc bugCount
    elif y == 1:
        # top border
        for i in 0..<s.width:
            if s.get(i, 0) == '#': inc bugCount
    elif y == -1:
        # bottom border
        for i in 0..<s.width:
            if s.get(i, s.height-1) == '#': inc bugCount

    return bugCount

proc adjacentBugs2(areas: var Table[int, Seq2d[char]], level, x, y: int): int =
    var bugCount = 0
    let s = areas[level]
    for (i, j) in [(1, 0), (0, 1), (-1, 0), (0, -1)]:
        if x + i < 0 or x + i >= s.width or y + j < 0 or y + j >= s.height:
            # go one level lower (-1)
            if areas.hasKey(level-1):
                if areas[level-1].get(2+i, 2+j) == '#':
                    bugCount += 1
        else:
            if s.get(x + i, y + j) == '#':
                bugCount += 1
            if s.get(x + i, y + j) == '?':
                # go one level higher (+1)
                if areas.hasKey(level+1):
                    bugCount += getBugsOnBorder(areas[level+1], i, j)


    return bugCount

proc emptyLevel(): Seq2d[char] =
    let s = newSeq2d[char]('X')
    s.width(5)
    for i in 0..<25:
        s.add('.')
    s.put(2, 2, '?')
    return s

proc bugCount(s: Seq2d[char]): int =
    var count = 0
    for i in 0..<25:
        if s.at(i) == '#':
            inc count
    return count

proc isEmptyLevel(s: Seq2d[char]): bool =
    s.bugCount == 0

proc totalBugCount(areas: Table[int, Seq2d[char]]): int =
    var count = 0
    for area in areas.values:
        count += area.bugCount
    return count


proc part2() =

    var areas = initTable[int, Seq2d[char]]()
    areas[0] = inputArea.clone
    areas[0].put(2, 2, '?')

    var steps = 200
    while true:
        dec steps
        if steps < 0:
            break

        let lim = int((areas.len - 1) / 2)
        if not areas[lim].isEmptyLevel: areas[lim+1] = emptyLevel()
        if not areas[-lim].isEmptyLevel: areas[-lim-1] = emptyLevel()

        var prevAreas = areas
        for level in areas.keys:
            areas[level] = areas[level].clone

        for level in areas.keys:
            let prevArea = prevAreas[level]
            var area = areas[level]
            for i in 0..<area.width:
                for j in 0..<area.height:
                    let bugs = adjacentBugs2(prevAreas, level, i, j)
                    let tile = prevArea.get(i, j)

                    if tile == '#' and bugs != 1:
                        area.put(i, j, '.')
                    elif tile == '.' and (bugs == 1 or bugs == 2):
                        area.put(i, j, '#')

    echo areas.totalBugCount


part1()
part2()