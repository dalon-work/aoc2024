package main

import "core:strings"
import "core:slice"
import "core:strconv"

split_to_int :: proc(s : string) -> [dynamic]int
{
  
  fields := strings.fields(s)

  ret := make([dynamic]int, len(fields))

  for i := 0; i < len(fields); i+=1 {
    j, ok := strconv.parse_int(fields[i])
    if !ok {
       delete(ret)
       return nil
    }
    ret[i] = j
  }

  return ret

}

