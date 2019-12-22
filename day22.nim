import strutils
import strformat
import sequtils
import algorithm

###
### Type definitions and procedures
###

type TechniqueType = enum Deal, Cut, Increment
type Technique = tuple[t: TechniqueType, n: int]

###
### The program
###

proc readInput(): seq[Technique] =
    let f = open("input/day22.txt")
    defer: f.close()

    var lines : seq[Technique] = @[]
    while not f.endOfFile():
        let line = f.readLine()
        if line.startsWith("deal with"):
            lines.add((t: Increment, n: line.split(' ')[3].parseInt))
        elif line.startsWith("deal into"):
            lines.add((t: Deal, n: 0))
        elif line.startsWith("cut"):
            lines.add((t: Cut, n: line.split(' ')[1].parseInt))
        else:
            echo "Not a valid shuffle technique: ", line

    return lines

let input = readInput()
var deck = toSeq(0..<10_007)

for shuf in input:
    echo shuf
    case shuf.t
    of Deal:
        deck = deck.reversed
    of Increment:
        var temp = newSeq[int](deck.len)
        var j = 0
        for i in 0..<deck.len:
            temp[j] = deck[i]
            j += shuf.n
            j = j mod deck.len
        deck = temp
    of Cut:
        if shuf.n >= 0:
            var cut = deck[0..<shuf.n]
            var rest = deck[shuf.n..<deck.len]
            deck = rest & cut
        else:
            let p = deck.len-abs(shuf.n)
            var cut = deck[p..<deck.len]
            var rest = deck[0..<p]
            deck = cut & rest
        discard

for i in 0..<deck.len:
    if deck[i] == 2019:
        echo i
        break