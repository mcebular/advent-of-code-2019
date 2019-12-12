import strutils
import strformat
import regex

###
### Type definitions and procedures
###

type Vector = array[3, int]

proc zeroVector(): Vector = [0, 0, 0]

proc lcm(initial: Vector): int =
    var updated = initial
    while not (updated[0] == updated[1] and updated[1] == updated[2]):
        if updated[0] <= updated[1]:
            if updated[0] <= updated[2]:
                updated[0] += initial[0]
            else:
                updated[2] += initial[2]
        else:
            if updated[1] <= updated[2]:
                updated[1] += initial[1]
            else:
                updated[2] += initial[2]
    return updated[0]

type
    Moon = ref object of RootObj
        position: Vector
        velocity: Vector

proc newMoon(position: Vector): Moon =
    return Moon(position: position, velocity: zeroVector())

proc parseMoon(str: string): Moon =
    let rgx = re("<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>")
    var match: RegexMatch
    discard match(str, rgx, match)

    let x = str[match.group(0)[0]].parseInt
    let y = str[match.group(1)[0]].parseInt
    let z = str[match.group(2)[0]].parseInt

    return newMoon([x, y, z])

proc `$`(moon: Moon): string =
    echo &"pos=<x={moon.position[0]}, y={moon.position[1]}, z={moon.position[2]}>, vel=<x={moon.velocity[0]}, y={moon.velocity[1]}, z={moon.velocity[2]}>"

proc potEnergy(moon: Moon): int =
    abs(moon.position[0]) + abs(moon.position[1]) + abs(moon.position[2])

proc kinEnergy(moon: Moon): int =
    abs(moon.velocity[0]) + abs(moon.velocity[1]) + abs(moon.velocity[2])

proc equalDimension(moons1: seq[Moon], moons2: seq[Moon], dimension: int): bool =
    var equalCount = 0
    for i in 0..<moons1.len:
        if moons1[i].position[dimension] == moons2[i].position[dimension] and moons1[i].velocity[dimension] == moons2[i].velocity[dimension]:
            equalCount += 1
    return equalCount == moons1.len

proc copy(moons: seq[Moon]): seq[Moon] =
    var ret: seq[Moon] = @[]
    for m in moons:
        ret.add(Moon(
            position: [m.position[0], m.position[1], m.position[2]],
            velocity: [m.velocity[0], m.velocity[1], m.velocity[2]]
        ))
    return ret

###
### The program
###

var moons: seq[Moon] = @[]

let f = open("input/day12.txt")
while not f.endOfFile():
    let line = f.readLine()
    let moon = parseMoon(line)
    moons.add(moon)
f.close()

# echo moons

let moonsCopy = moons.copy()

var repeats: Vector = zeroVector()
var steps = 0
while true:
    # echo &"After {steps} steps"
    # echo moons

    # ---------------
    # Part 1
    var sumEnergy = 0
    for moon in moons:
        sumEnergy += (moon.potEnergy * moon.kinEnergy)
    if steps == 1000:
        echo &"Total energy in the system after {steps} steps: {sumEnergy}"
        # break
    # ---------------

    # ---------------
    # Part 2
    for j in 0..2:
        if repeats[j] == 0:
            if equalDimension(moons, moonsCopy, j) and steps > 0:
                repeats[j] = steps
                echo &"Positions and velocities of dimension {j} repeat after {steps} steps."

    if repeats[0] != 0 and repeats[1] != 0 and repeats[2] != 0:
        echo "Got all dimension repeats, calculating least common multiple..."
        echo &"Complete state of all moons will repeat after {lcm(repeats)} steps!"
        break
    # ---------------

    for m1 in moons:
        for m2 in moons:
            if m1 == m2: continue
            for i in 0..2:
                if m1.position[i] > m2.position[i]:
                    m1.velocity[i] -= 1
                    m2.velocity[i] += 1

    for m in moons:
        for i in 0..2:
            m.position[i] += m.velocity[i]

    steps += 1