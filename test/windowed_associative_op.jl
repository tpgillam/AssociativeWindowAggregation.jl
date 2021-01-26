@testset "empty" begin
    for T in [Float64, Bool, Array{Float64, 1}]
        for op in [+, -, *]
            state = WindowedAssociativeOpState{T}(op)
            @test state.value_count == 0
            @test state.op == op
            @test state.previous_cumsum == T[]
            @test state.ri_previous_cumsum == 0
            @test state.values == T[]
            @test isnothing(state.sum)
        end
    end
end

@testset "fixed window" begin
    T = Int64
    op = +
    window = 2
    state = FixedWindowAssociativeOp{T}(op, window)
    @test isnothing(update_state!(state, 3))
    @test update_state!(state, 4) == 7
    @test update_state!(state, 4) == 8
    @test update_state!(state, -5) == -1
end
