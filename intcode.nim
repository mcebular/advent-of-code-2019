from strutils import parseInt, split
import strformat
import tables

###
### Type definitions
###

type Operation* = enum
    Add = 1,
    Mul = 2,
    Inp = 3,
    Out = 4,
    Jit = 5, # jump-if-true
    Jif = 6, # jump-if-false
    Lt  = 7, # less-than
    Eq  = 8, # equals
    Rbo = 9, # set relative base offset
    Hlt = 99

proc size(op: Operation): int =
    case op
    of Add: return 4
    of Mul: return 4
    of Inp: return 2
    of Out: return 2
    of Jit: return 3
    of Jif: return 3
    of Lt : return 4
    of Eq : return 4
    of Rbo: return 2
    of Hlt: return 0

type EndState* = enum
    Halt = 0,
    Wait = 1

type ParameterMode = enum
    Pos = 0,
    Imm = 1,
    Rel = 2

type Program = TableRef[int, int]

###
### Computer object
###

type IntCodeComputer* = ref object of RootObj
    programMemory: Program
    instructionPointer: int
    relativeBase: int
    inputs: seq[int]

###
### Private procedures
###

proc charToInt(c: char): int =
    return (c&"").parseInt

# Split the operation into parameter modes and operation itself
proc disassembleOperation(op: int): (ParameterMode, ParameterMode, ParameterMode, Operation) =
    let ops = &"{op:05}"
    return (
        ParameterMode(ops[2].charToInt),
        ParameterMode(ops[1].charToInt),
        ParameterMode(ops[0].charToInt),
        Operation(ops.substr(3, 4).parseInt)
        )

# Returns value in the program memory based on parameter mode
proc read(icc: IntCodeComputer, inPtr: int, mode: ParameterMode): int =
    case mode
    of Imm:
        return icc.programMemory.getOrDefault(inPtr, 0)
    of Pos:
        return icc.programMemory.getOrDefault(icc.programMemory.getOrDefault(inPtr, 0), 0)
    of Rel:
        let p = icc.relativeBase + icc.programMemory.getOrDefault(inPtr, 0)
        return icc.programMemory.getOrDefault(p, 0)

proc write(icc: IntCodeComputer, inPtr: int, mode: ParameterMode, value: int) =
    case mode
    of Pos:
        icc.programMemory[icc.programMemory.getOrDefault(inPtr, 0)] = value
    of Rel:
        let p = icc.relativeBase + icc.programMemory.getOrDefault(inPtr, 0)
        icc.programMemory[p] = value
    of Imm:
        echo "write() ParameterMode is Immediate, invalid!"

###
### Constructor and public procedures
###

proc newIntCodeComputer*(program: seq[int]): IntCodeComputer =
    var icc = IntCodeComputer()

    icc.programMemory = newTable[int, int]()

    for i, p in program:
        icc.programMemory[i] = p

    icc.instructionPointer = 0
    icc.relativeBase = 0

    return icc


proc addInput*(icc: IntCodeComputer, newInput: int) =
    icc.inputs.add(newInput)

proc readMemory*(icc: IntCodeComputer, position: int): int =
    return icc.programMemory[position]

proc setMemory*(icc: IntCodeComputer, position: int, value: int) =
    icc.programMemory[position] = value

proc runProgram*(icc: IntCodeComputer, debug: bool = false): (EndState, seq[int]) =
    # if debug: echo icc.instructionPointer, ", ", icc.programMemory
    var outputs: seq[int] = @[]
    var state: EndState

    var ip = icc.instructionPointer
    var program = icc.programMemory

    while true:
        let (pm1, pm2, pm3, op) = disassembleOperation(program[ip])
        var modifiedIp = false
        case op
        of Add:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            icc.write(ip+3, pm3, icc.read(ip+2, pm2) + icc.read(ip+1, pm1))
        of Mul:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            icc.write(ip+3, pm3, icc.read(ip+2, pm2) * icc.read(ip+1, pm1))
        of Inp:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]}"
            if icc.inputs.len <= 0:
                if debug: echo &"Program paused due to no input."
                state = Wait
                break
            # Read input and remove it from inputs array
            icc.write(ip+1, pm1, icc.inputs[0])
            icc.inputs.delete(0)
        of Out:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]}"
            outputs.add(icc.read(ip+1, pm1))
        of Jit:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]} {program[ip+2]}"
            if icc.read(ip+1, pm1) != 0:
                ip = icc.read(ip+2, pm2)
                modifiedIp = true
        of Jif:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]} {program[ip+2]}"
            if icc.read(ip+1, pm1) == 0:
                ip = icc.read(ip+2, pm2)
                modifiedIp = true
        of Lt:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            if icc.read(ip+1, pm1) < icc.read(ip+2, pm2):
                icc.write(ip+3, pm3, 1)
            else:
                icc.write(ip+3, pm3, 0)
        of Eq:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]} {program[ip+2]} {program[ip+3]}"
            if icc.read(ip+1, pm1) == icc.read(ip+2, pm2):
                icc.write(ip+3, pm3, 1)
            else:
                icc.write(ip+3, pm3, 0)
        of Hlt:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op})"
            state = Halt
            break
        of Rbo:
            if debug: echo &"{pm1.ord}{pm2.ord}{pm3.ord} {op.ord}({op}) {program[ip+1]}"
            icc.relativeBase += icc.read(ip+1, pm1)
        #else:
        #    echo program
        #    echo &"Program suprisingly terminated at op {op}."
        #    break

        if not modifiedIp:
            ip += op.size
        # echo program

    icc.instructionPointer = ip
    # if debug: echo ip, ", ", program
    return (state, outputs)