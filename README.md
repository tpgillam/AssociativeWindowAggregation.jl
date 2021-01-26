# Rolling.jl

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

Computate aggregation of operators over rolling windows incrementally.

Supports aggregation of any binary associative operator, with potentially variable window size. 
Runs in amortized `O(1)` time, and uses `O(L)` space, where `L` is the typical window length.

## Notes

- No attempts to optimise or otherwise benchmark the algorithms has been done (yet)!

## TODO
- Fixed window for simple types would benefit from statically allocated buffers that could be reused.