from strutils import parseInt

proc fuelCond(fuel: int): int =
  return int(fuel / 3) - 2

proc fuelCondIter(fuel: int): int =
  var res = fuel
  var sum = 0

  while res > 0:
    res = fuelCond(res)
    if res < 0:
      break
    sum += res

  return sum

let f = open("input/day1.txt")

var sum = 0
while not f.endOfFile():
  let line = parseInt(f.readLine())
  let result = fuelCondIter(line)
  sum += result

echo sum

f.close()