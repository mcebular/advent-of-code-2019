import strutils
import intcode
import strformat
import seq2d


###
### The program
###

let input = readFile("input/day19.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

let drone = newIntCodeComputer(program)

proc part1() =
    var space = newSeq2d[int](-1)
    space.width(50)
    var pullCount = 0
    for j in 0..<50:
        for i in 0..<50:
            let drone = drone.clone
            drone.addInput(i)
            drone.addInput(j)
            let (_, output) = drone.runProgram()
            # echo output

            if output[0] == 1: pullCount += 1
            space.put(i, j, output[0])

    proc draw(val: int): string =
        case val
        of 0: return "░"
        of 1: return "▓"
        else: return "?"

    space.print(draw)

    echo pullCount

proc part2() =
    let wantedSize = 100
    var
        checkBeamStart = 0
        checkBeamEnd = 2000 # initially, we don't know where beam stats/ends, so check a wider range
        y = 950 # let's just start somewhere close to the actual answer
    while true:
        y += 1

        var prevOut = 0
        let cbs = checkBeamStart - 5
        let cbe = checkBeamEnd + 5

        for x in max(0, cbs)..<cbe:
            var drone1 = drone.clone
            drone1.addInput(x)
            drone1.addInput(y)
            let (_, output) = drone1.runProgram()

            if prevOut == 0 and output[0] == 1:
                checkBeamStart = x
            if prevOut == 1 and output[0] == 0:
                checkBeamEnd = x

            prevOut = output[0]


        let beamWidth = checkBeamEnd-checkBeamStart
        # echo &"At y={y}, beam starts at {checkBeamStart} and ends at {checkBeamEnd}. Width of the beam is {beamWidth}."

        if beamWidth >= wantedSize:
            for m in checkBeamStart..checkBeamStart + beamWidth - wantedSize:
                let drone2 = drone.clone
                drone2.addInput(m)
                drone2.addInput(y + wantedSize-1)
                let (_, output) = drone2.runProgram
                if output[0] == 1:
                    echo &"At x={m}, y={y}, beam is enough wide and tall."
                    echo m * 10_000 + y
                    return

part1()
part2()