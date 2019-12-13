from strutils import parseInt, split
import strformat
import algorithm

###
### Type definitions
###

type Operation = int
type ParMode = int
type State = bool

const
    Halt = true
    Wait = false

const
    opAdd = 1
    opMul = 2
    opInp = 3
    opOut = 4
    opJit = 5 # jump-if-true
    opJif = 6 # jump-if-false
    opLt  = 7 # less-than
    opEq  = 8 # equals
    opEnd = 99

const
    pmPos = 0
    pmImm = 1

###
### Type procedures
###

proc opSize(op: Operation): int =
    case op
    of opAdd: return 4
    of opMul: return 4
    of opInp: return 2
    of opOut: return 2
    of opJit: return 3
    of opJif: return 3
    of opLt : return 4
    of opEq : return 4
    else: return 0

###
### Utility procedures
###

proc charToInt(c: char): int =
    return (c&"").parseInt

# Split the operation into parameter modes and operation itself
proc disassembleOperation(op: int): (ParMode, ParMode, ParMode, Operation) =
    let ops = &"{op:05}"

    return (ops[2].charToInt, ops[1].charToInt, ops[0].charToInt, ops.substr(3, 4).parseInt)

# Returns value in the program memory based on parameter mode
proc value(program: seq[int], inptr: int, mode: ParMode): int =
    case mode
    of pmImm:
        return program[inptr]
    else: # of pmPos:
        return program[program[inptr]]

proc runProgram(program: var seq[int], ip: var int, inputs: seq[int], debug: bool = false): (State, seq[int]) =
    if debug: echo ip, ", ", program
    var inpp = 0 # input array pointer
    var outputs: seq[int] = @[]
    var state: State

    while program[ip] != opEnd:
        let (pm1, pm2, pm3, op) = disassembleOperation(program[ip])
        var modifiedIp = false
        case op
        of opAdd:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(Add) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            program[program[ip+3]] = program.value(ip+2, pm2) + program.value(ip+1, pm1)
        of opMul:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(Mul) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            program[program[ip+3]] = program.value(ip+2, pm2) * program.value(ip+1, pm1)
        of opInp:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(Inp) {program[ip+1]}"
            if inpp >= inputs.len:
                if debug: echo &"Program paused due to no input."
                state = Wait
                break
            program[program[ip+1]] = inputs[inpp]
            inpp += 1
        of opOut:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(Out) {program[ip+1]}"
            outputs.add(program.value(ip+1, pm1))
        of opJit:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(JiT) {program[ip+1]} {program[ip+2]}"
            if program.value(ip+1, pm1) != 0:
                ip = program.value(ip+2, pm2)
                modifiedIp = true
        of opJif:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(JiF) {program[ip+1]} {program[ip+2]}"
            if program.value(ip+1, pm1) == 0:
                ip = program.value(ip+2, pm2)
                modifiedIp = true
        of opLt:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(Lt ) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            if program.value(ip+1, pm1) < program.value(ip+2, pm2):
                program[program[ip+3]] = 1
            else:
                program[program[ip+3]] = 0
        of opEq:
            if debug: echo &"{pm1}{pm2}{pm3} {op}(Eq ) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            if program.value(ip+1, pm1) == program.value(ip+2, pm2):
                program[program[ip+3]] = 1
            else:
                program[program[ip+3]] = 0
        else:
            echo program
            echo &"Program suprisingly terminated at op {op}."
            break

        if not modifiedIp:
            ip += op.opSize
        # echo program

    if program[ip] == opEnd:
        if debug: echo "Program halted."
        state = Halt

    if debug: echo ip, ", ", program
    return (state, outputs)

###
### The program
###

let input = readFile("input/day7.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

###
### Above: code from Day 5 + modifications
### Below: new code
###

###
### Type definitions
###
type Amplifier = ref object of RootObj
    program: seq[int]
    ip: int

###
### Type procedures
###

proc newAmplifier(pprogram: seq[int]): Amplifier =
    Amplifier(program: pprogram, ip: 0)

proc process(amp: var Amplifier, input: int): (State, seq[int]) =
    return runProgram(amp.program, amp.ip, @[input])

###
### The program: Part 1
###

proc part1() =
    var amplifiers: array[5, Amplifier]

    var phases: array[5, int] = [0,1,2,3,4]
    var maxData: int = 0
    while true:
        # initialize amplifiers
        for i in 0..<amplifiers.len:
            amplifiers[i] = newAmplifier(program)

        # initialize data
        var
            currentData: int = 0
            currentState: State = Wait

        for i in 0..<amplifiers.len:
            # echo &"Thruster {i} starting..."
            discard amplifiers[i].process(phases[i])
            let (state, outputs) = amplifiers[i].process(currentData)
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
    var amplifiers: array[5, Amplifier]

    var phases: array[5, int] = [5,6,7,8,9]
    var maxData: int = 0
    while true:
        # initialize amplifiers
        for i in 0..<amplifiers.len:
            amplifiers[i] = newAmplifier(program)

        # initialize data
        var
            currentData: int = 0
            currentState: State = Wait
            isFirstIter = true

        # loop until amplifiers halt
        while true:
            for i in 0..<amplifiers.len:
                # echo &"Thruster {i} starting..."
                if isFirstIter:
                    discard amplifiers[i].process(phases[i])

                let (state, outputs) = amplifiers[i].process(currentData)

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