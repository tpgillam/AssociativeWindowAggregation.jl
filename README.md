# Rolling.jl
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tpgillam.github.io/Rolling.jl/dev)
[![Build Status](https://github.com/tpgillam/Rolling.jl/workflows/CI/badge.svg)](https://github.com/tpgillam/Rolling.jl/actions)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

Accumulate result of appying binary associative operators on rolling windows.

## Notes
- API is very preliminary and likely to change a lot.
- No attempts to optimise or otherwise benchmark the algorithms has been done (yet)!

## TODO
- Fixed window for simple types would benefit from statically allocated buffers that could be reused.