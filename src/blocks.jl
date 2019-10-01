using YaoBlocks, LuxurySparse, LinearAlgebra
using .Simplify: normalize

YaoBlocks.RotationGate(block::GT, theta::T) where {N, T <: SymReal, GT<:AbstractBlock{N}} = RotationGate{N, T, GT}(block, theta)

YaoBlocks.phase(θ::SymReal) = PhaseGate(θ)
YaoBlocks.shift(θ::SymReal) = ShiftGate(θ)

YaoBlocks.mat(::Type{SymComplex}, ::HGate) = 1/sqrt(SymComplex(2)) * SymComplex[1 1;1 -1]
YaoBlocks.mat(::Type{SymComplex}, ::XGate) = SymComplex[0 1;1 0]
YaoBlocks.mat(::Type{SymComplex}, ::YGate) = SymComplex[0 -1im;1im 0]
YaoBlocks.mat(::Type{SymComplex}, ::ZGate) = SymComplex[1 0;0 -1]

YaoBlocks.mat(gate::ShiftGate{<:SymReal}) =
    Diagonal([1.0, exp(im * gate.theta)])
YaoBlocks.mat(gate::PhaseGate{<:SymReal}) =
    exp(im * gate.theta) * IMatrix{2}()
function YaoBlocks.mat(R::RotationGate{N, <:SymReal}) where N
    I = IMatrix{1<<N}()
    return I * cos(R.theta / 2) - im * sin(R.theta / 2) * mat(SymComplex, R.block)
end

YaoBlocks.mat(::Type{<:Any}, gate::PhaseGate{<:SymReal}) = mat(gate)
YaoBlocks.mat(::Type{<:Any}, gate::ShiftGate{<:SymReal}) = mat(gate)
YaoBlocks.mat(::Type{<:Any}, gate::RotationGate{N, <:SymReal}) where N = mat(gate)

YaoBlocks.PSwap{N}(locs::Tuple{Int, Int}, θ::SymReal) where N = YaoBlocks.PutBlock{N}(rot(ConstGate.SWAPGate(), θ), locs)

YaoBlocks.pswap(n::Int, i::Int, j::Int, α::SymReal) = PSwap{n}((i,j), α)
YaoBlocks.pswap(i::Int, j::Int, α::SymReal) = n->pswap(n,i,j,α)


function YaoBlocks.mat(::Type{SymComplex}, c::ChainBlock)
    M = mat(SymComplex, c.blocks[end])
    L = length(c.blocks)
    for k in L-1:-1:1
        M = mat(SymComplex, c.blocks[k]) * M
    end
    return M
end
