# AssociativeWindowAggregation.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tpgillam.github.io/AssociativeWindowAggregation.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tpgillam.github.io/AssociativeWindowAggregation.jl/dev)
[![Build Status](https://github.com/tpgillam/AssociativeWindowAggregation.jl/workflows/CI/badge.svg)](https://github.com/tpgillam/AssociativeWindowAggregation.jl/actions)
[![Codecov](https://codecov.io/gh/tpgillam/AssociativeWindowAggregation.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tpgillam/AssociativeWindowAggregation.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

Accumulate result of applying binary associative operators on rolling windows.

The algorithm is constant time with respect to the window length, and is numerically stable. 
Details can be found in the [documentation](https://tpgillam.github.io/AssociativeWindowAggregation.jl/dev). 
For demonstrations, see the [documentation examples](https://tpgillam.github.io/AssociativeWindowAggregation.jl/dev/examples) as well as the project under `examples/`.

The windowed algorithm is well suited for use with [OnlineStats.jl](https://github.com/joshday/OnlineStats.jl).
An [example](https://tpgillam.github.io/AssociativeWindowAggregation.jl/dev/examples/#OnlineStats.jl) of this combination is in the documentation.
