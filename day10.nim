import strformat
import math
import algorithm

###
### Type definitions & procedures
###

type Vector = tuple[x: int, y: int]

proc distance(this: Vector, other: Vector): Vector =
    (other.x - this.x, other.y - this.y)

proc gcd(vect: Vector): int =
    if vect.y == 0:
        return vect.x

    return gcd((vect.y, vect.x mod vect.y))

proc `/`(this: Vector, n: int): Vector =
    (int(this.x / n), int(this.y / n))

proc `-`(this: Vector, other: Vector): Vector =
    (this.x - other.x, this.y - other.y)

proc angle(this: Vector, other: Vector): float =
    # make this vector the center of coordinate system
    let point: Vector = this - other

    var at = arctan2(float(point.y), float(point.x)) * (180 / math.PI) - 90.0
    if at < 0: at += 360.0
    return at

###
### The program
###

let f = open("input/day10.txt")

var asteroids: seq[Vector] = @[]

var y = 0
while not f.endOfFile():
    let line = f.readLine()
    for x, c in line:
        if c == '#':
            asteroids.add((x, y))
    y += 1

f.close()

# echo asteroids

proc getVisibleAsteroids(this: Vector, asteroids: seq[Vector]): seq[Vector] =
    var visibles: seq[Vector] = @[]
    for other in asteroids:
        if this == other: continue

        let dist = this.distance(other)
        let fact = dist / abs(gcd(dist))
        #echo &"Line of sight from {this} to {other}, distance factor is {fact}."

        var isVisible = true
        var temp = other - fact

        while temp != this and isVisible:
            #echo &"Checking position {temp} for asteroid..."
            for a in asteroids:
                if temp == a:
                    isVisible = false
                    break
            temp = temp - fact

        if isVisible: visibles.add(other)
    return visibles


var maxAmount: int = 0
var maxAsteroid: Vector
for this in asteroids:
    let amount = this.getVisibleAsteroids(asteroids).len
    # echo &"Asteroid {this} has {amount} other asteroids in line of sight."
    if amount > maxAmount:
        maxAmount = amount
        maxAsteroid = this

# Part 1
echo &"{maxAsteroid} has the most asteroids in line of sight ({maxAmount})."

var count = 1
while asteroids.len > 1:

    var visibles = maxAsteroid.getVisibleAsteroids(asteroids)
    algorithm.sort(visibles, proc (x, y: Vector): int =
        return int(angle(maxAsteroid, x) * 100) - int(angle(maxAsteroid, y) * 100))

    for ast in visibles:
        # echo &"Blasting off {count}. asteroid at {ast} (angle={int(angle(maxAsteroid, ast) * 100 / 100)}))!"
        var index = -1
        for i, a in asteroids:
            if a == ast:
                index = i
        asteroids.delete(index)

        if count == 200:
            # Part 2
            echo &"200th asteroid vaporized is {ast.x * 100 + ast.y}."

        count += 1
    # echo "Remaining asteroids: ", asteroids.len