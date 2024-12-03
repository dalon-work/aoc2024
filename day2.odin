package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"

is_safe :: proc(vals : []int) -> bool {

  up := (vals[1] - vals[0]) > 0
  for i in 0..<len(vals)-1 {
    a := vals[i+1]-vals[i]
    if a == 0 || abs(a) > 3 || (up ~ (a > 0)) {
      return false
    }
  }
    
  return true
}

problem_damper :: proc(vals : []int) -> bool {

  removed := false
  up := (vals[1] - vals[0]) > 0
  for i in 0..<len(vals) {
    new_vals := slice.clone_to_dynamic(vals)
    defer delete(new_vals)
    ordered_remove(&new_vals, i)
    if is_safe(new_vals[:]) {
      return true
    }
  }
    
  return false
}

day2 :: proc() {

  data := #load("data/day2.txt", string)

  lines := strings.split_lines(data)
  defer delete(lines)

  lines = lines[:len(lines)-1]

  rows := make([dynamic][dynamic]int, len(lines))
  defer delete(rows)

  safe_count_part1 := 0
  safe_count_part2 := 0
  for l, i in lines {
    rows[i] = split_to_int(l)
    // assert( rows[i] != nil )
    if is_safe(rows[i][:]) {
      safe_count_part1 += 1 
    } else if problem_damper(rows[i][:]) {
      safe_count_part2 += 1
    }
  }

  fmt.println("Day 2, Part 1:", safe_count_part1)
  fmt.println("Day 2, Part 2:", safe_count_part1 + safe_count_part2)
}


