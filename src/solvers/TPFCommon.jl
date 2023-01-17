# Two-phase flow solvers
# this source file contains the common kernel that is shared by solvers for TPF problem 

# η_ϕ = η_c ⋅ ɸ0/ɸ (1+ 1/2(1/R − 1)(1+tanh(−Pₑ/λₚ)))
# ηc = μˢ/C/φ0

#=============== COMPUTE KERNEL ========================#
@inbounds @parallel function compute_params_∇!(𝞰ɸ::Data.Array, 𝗞ɸ_µᶠ::Data.Array, 𝞀g::Data.Array, ∇V::Data.Array, ∇qD::Data.Array, 𝝫::Data.Array, Pf::Data.Array, Pt::Data.Array, Vx::Data.Array, Vy::Data.Array, qDx::Data.Array, qDy::Data.Array, μˢ::Data.Number, _C::Data.Number, R::Data.Number, λPe::Data.Number, k0::Data.Number, _ϕ0::Data.Number, nₖ::Data.Number, θ_e::Data.Number, θ_k::Data.Number, ρfg::Data.Number, ρsg::Data.Number, ρgBG::Data.Number, _dx::Data.Number, _dy::Data.Number)
    @all(𝞰ɸ)    = (1.0 - θ_e) * @all(𝞰ɸ)    + θ_e * ( μˢ*_C/@all(𝝫)*(1.0+0.5*(1.0/R-1.0)*(1.0+tanh((@all(Pf)-@all(Pt))/λPe))) )
    @all(𝗞ɸ_µᶠ) = (1.0 - θ_k) * @all(𝗞ɸ_µᶠ) + θ_k * ( k0 * (@all(𝝫)* _ϕ0)^nₖ )
    @all(𝞀g)    = ρfg*@all(𝝫) + ρsg*(1.0-@all(𝝫)) - ρgBG
    
    # compute gradient 2D
    @all(∇V)    = @d_xa(Vx)* _dx  + @d_ya(Vy)* _dy
    @all(∇qD)   = @d_xa(qDx)* _dx + @d_ya(qDy)* _dy

    return
end

