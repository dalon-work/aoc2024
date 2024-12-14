package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"
import "core:bytes"
import "core:text/regex"
import "base:intrinsics"

create_rules :: proc(rlines: []string) -> map[int]map[int]bool {
  r := make(map[int]map[int]bool)

  for l in rlines {
    s1, _, s2 := strings.partition(l, "|")
    key, _ := strconv.parse_int(s1)
    val, _ := strconv.parse_int(s2)
    if !(key in r) {
      r[key] = make(map[int]bool)
    }
    (&r[key])^[val] = true
  }
  return r
}

create_updates :: proc(ulines: []string) -> [dynamic][dynamic]int {
  u := make([dynamic][dynamic]int, len(ulines))

  for i in 0..<len(u) {
    split := strings.split(ulines[i], ",")
    defer delete(split)
    u[i] = make([dynamic]int,len(split))
    for j in 0..<len(split) {
      val, _ := strconv.parse_int(split[j])
      u[i][j] = val
    }
  }
  return u
}

update_is_correct :: proc(rules: map[int]map[int]bool, u: []int) -> bool {

  for i in 0..<len(u) {
    key := u[i]
    // check all the page numbers before me and make sure they are not in my "must be after me" rule list
    for j in 0..<i {
      to_check, ok := rules[key]
      if ok {
        if to_check[u[j]] {
          return false
        }
      }
    }
  }

  return true

}

fix_update :: proc(rules: map[int]map[int]bool, u: []int) -> int {
  fixed_update := slice.clone(u)
  defer delete(fixed_update)
  dep_count := make([]int, len(u))
  defer delete(dep_count)
  idx_map := make(map[int]int)
  defer delete(idx_map)

  for ui, idx in u {
    idx_map[ui] = idx
  }

  for ui in u {
    after_me_map, ok := rules[ui]
    if ok {
      for after_me in after_me_map {
        if slice.contains(u, after_me) {
          dep_count[ idx_map[ui] ] += 1
        }
      }
    }
  }

  indices := slice.sort_with_indices(dep_count)
  defer delete(indices)

  for old_idx, new_idx in indices {
    fixed_update[new_idx] = u[old_idx]
  }

  return midpoint(fixed_update)
}

midpoint :: proc(u: []int) -> int {
  idx :=  u[len(u)/2]
  return idx
}

day5 :: proc() {

  data := #load("data/day5.txt", string)

  rtmp, _, utmp := strings.partition(data, "\n\n")

  rlines := strings.split_lines(rtmp)
  defer delete(rlines)

  ulines := strings.split_lines(utmp)
  defer delete(ulines)

  rules := create_rules(rlines)
  defer {
    for key, &val in rules {
      delete(val)
    }
    delete(rules)
  }

  updates := create_updates(ulines)
  defer {
    for u in updates {
      delete(u)
    }
    delete(updates)
  }

  part1 := 0
  part2 := 0

  for u in updates {
    if update_is_correct(rules, u[:]) {
      part1 += midpoint(u[:])
    } else {
      part2 += fix_update(rules, u[:])
    }
  }

  fmt.println("Day 5, Part 1:", part1)
  fmt.println("Day 5, Part 2:", part2)

}


