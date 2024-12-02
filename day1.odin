package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"

day1 :: proc() {

  data := #load("data/day1.txt", string)

  fields := strings.fields(data)

  l, r : [dynamic]int
  r_map := make(map[int]int)
  defer delete(l)
  defer delete(r)
  defer delete(r_map)


  for i := 0; i < len(fields); i += 2 {
    li, _ := strconv.parse_int(fields[i])
    ri, _ := strconv.parse_int(fields[i+1])
    append(&l, li)
    append(&r, ri)
    r_map[ri] = (r_map[ri] + 1)
  }

  slice.sort(l[:])
  slice.sort(r[:])

  assert( len(l) == len(r) )

  part1 : int 
  part2 : int

  for i := 0; i < len(l); i+=1 {
    part1 += abs(l[i] - r[i])
    part2 += l[i] * r_map[l[i]]

  }

  fmt.println("Day 1, Part 1:", part1)
  fmt.println("Day 1, Part 2:", part2)
}


