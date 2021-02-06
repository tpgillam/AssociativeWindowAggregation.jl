@testset "WindowedAssociativeOp" begin
    @testset "empty" begin
        for T in [Float64, Bool, Array{Float64, 1}]
            for op in [+, -, *]
                state = WindowedAssociativeOp{T}(op)
                @test state.op == op
                @test state.previous_cumsum == T[]
                @test state.ri_previous_cumsum == 0
                @test state.values == T[]
                @test isnothing(state.sum)
            end
        end
    end
end
