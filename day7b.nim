from strutils import parseInt, split
import algorithm
import intcode


let input = readFile("input/day7.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

proc part1() =
    var amplifiers: array[5, IntCodeComputer]

    var phases: array[5, int] = [0,1,2,3,4]
    var maxData: int = 0
    while true:
        # initialize amplifiers
        for i in 0..<amplifiers.len:
            amplifiers[i] = newIntCodeComputer(program)

        # initialize data
        var
            currentData: int = 0
            currentState: EndState = Wait

        for i in 0..<amplifiers.len:
            # echo &"Thruster {i} starting..."
            amplifiers[i].addInput(phases[i])
            discard amplifiers[i].runProgram()

            amplifiers[i].addInput(currentData)
            let (state, outputs) = amplifiers[i].runProgram()

            currentState = state
            if outputs.len > 0:
                currentData = outputs[0]
            # echo &"Thruster {i} stopped"

        if currentData > maxData:
            maxData = currentData

        if not nextPermutation(phases):
            break

    echo maxData

###
### The program: Part 2
###

proc part2() =
    var amplifiers: array[5, IntCodeComputer]

    var phases: array[5, int] = [5,6,7,8,9]
    var maxData: int = 0
    while true:
        # initialize amplifiers
        for i in 0..<amplifiers.len:
            amplifiers[i] = newIntCodeComputer(program)

        # initialize data
        var
            currentData: int = 0
            currentState: EndState = Wait
            isFirstIter = true

        # loop until amplifiers halt
        while true:
            for i in 0..<amplifiers.len:
                # echo &"Thruster {i} starting..."
                if isFirstIter:
                    amplifiers[i].addInput(phases[i])
                    discard amplifiers[i].runProgram()

                amplifiers[i].addInput(currentData)
                let (state, outputs) = amplifiers[i].runProgram()

                currentState = state
                if outputs.len > 0:
                    currentData = outputs[0]
                # echo &"Thruster {i} stopped"

            isFirstIter = false
            if currentState == Halt:
                break

        if currentData > maxData:
            maxData = currentData

        if not nextPermutation(phases):
            break

    echo maxData


part1()
part2()