#############################################################################
# JuMP
# An algebraic modelling langauge for Julia
# See http://github.com/JuliaOpt/JuMP.jl
#############################################################################
# corr_sdp.jl
#
# Given three random variables A,B,C and given bounds on two of the three
# correlation coefficients:
# -0.2 <= ρ_AB <= -0.1
#  0.4 <= ρ_BC <=  0.5
# We can use the following property of the correlations:
# [  1    ρ_AB  ρ_AC ]
# [ ρ_AB   1    ρ_BC ]  ≽ 0
# [ ρ_AC  ρ_BC   1   ]
# To determine bounds on ρ_AC by solving a SDP
#############################################################################

using JuMP

m = Model()

@defVar(m, X[1:3,1:3], SDP)

# Diagonal is 1s
@addConstraint(m, X[1,1] == 1)
@addConstraint(m, X[2,2] == 1)
@addConstraint(m, X[3,3] == 1)

# Bounds on the known correlations
@addConstraint(m, X[1,2] >= -0.2)
@addConstraint(m, X[1,2] <= -0.1)
@addConstraint(m, X[2,3] >=  0.4)
@addConstraint(m, X[2,3] <=  0.5)

# Find upper bound
@setObjective(m, Max, X[1,3])
solve(m)
println("Maximum value is ", getValue(X)[1,3])
@assert +0.8719 <= getValue(X)[1,3] <= +0.8720

# Find lower bound
@setObjective(m, Min, X[1,3])
solve(m)
println("Minimum value is ", getValue(X)[1,3])
@assert -0.9779 >= getValue(X)[1,3] >= -0.9799
