import strutils
import strformat

###
### Utility procedures
###

proc readInput(): (int, int) =
    let f = open("input/day4.txt")
    defer: f.close()

    let line = f.readLine().split('-')
    return (line[0].parseInt, line[1].parseInt)

proc hasAdjacent(num: int): bool =
    let numstr = &"{num}"
    var hasAdj = false

    for i in 1..<numstr.len:
        if numstr[i-1] == numstr[i]:
            hasAdj = true
            break

    return hasAdj

proc hasIncreasing(num: int): bool =
    let numstr = &"{num}"
    var hasInc = true

    for i in 1..<numstr.len:
        if numstr[i-1] > numstr[i]:
            hasInc = false
            break

    return hasInc

proc getDigitGroups(num: int): seq[string] =
    let numstr = &"{num}x"
    var groups: seq[string] = @["", "", ""]

    var gi = 0
    var g = false
    for i in 1..<numstr.len:
        if numstr[i-1] == numstr[i]:
            g = true
            groups[gi] &= numstr[i-1]
        elif g == true:
            g = false
            groups[gi] &= numstr[i-1]
            gi += 1

    return groups


proc hasDoubleGroup(num: int): bool =
    let groups = getDigitGroups(num)
    var isOk = false

    for group in groups:
        if group.len == 2:
            isOk = true

    return isOk

###
### The program
###

let (in1, in2) = readInput()

var num = in1 + 1
var
    cnt1 = 0
    cnt2 = 0
while num < in2:
    let numstr = &"{num}"

    if (numstr[0]&"").parseInt > (numstr[1]&"").parseInt:
        # i.e. if we are at 500_000 we can skip to 550_000
        num += 10_000
        continue

    if (numstr[1]&"").parseInt > (numstr[2]&"").parseInt:
        # i.e. if we are at 150_000 we can skip to 155_000
        num += 1_000
        continue

    if (numstr[2]&"").parseInt > (numstr[3]&"").parseInt:
        # i.e. if we are at 115_000 we can skip to 115_500
        num += 100
        continue

    if (numstr[3]&"").parseInt > (numstr[4]&"").parseInt:
        # i.e. if we are at 111_500 we can skip to 111_550
        num += 10
        continue

    if num > in1 and num < in2 and hasAdjacent(num) and hasIncreasing(num):
        cnt1 += 1
        if hasDoubleGroup(num):
            cnt2 += 1

    num += 1
    # echo num

echo cnt1 # Part 1
echo cnt2 # Part 2
