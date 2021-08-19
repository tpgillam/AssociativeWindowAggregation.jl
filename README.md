# AssociativeWindowAggregation.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tpgillam.github.io/AssociativeWindowAggregation.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tpgillam.github.io/AssociativeWindowAggregation.jl/dev)
[![Build Status](https://github.com/tpgillam/AssociativeWindowAggregation.jl/workflows/CI/badge.svg)](https://github.com/tpgillam/AssociativeWindowAggregation.jl/actions)
[![Codecov](https://codecov.io/gh/tpgillam/AssociativeWindowAggregation.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tpgillam/AssociativeWindowAggregation.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

Accumulate result of appying binary associative operators on rolling windows.

## Notes
- API is preliminary and liable to change.
- Some optimisation has been performed, however there is likely still room for improvement, especially for the fixed-window case.
