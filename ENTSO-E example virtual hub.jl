# Home directory
const home_dir = @__DIR__

using JuMP
using HiGHS
using XLSX
using DataFrames, CSV

# Data
A_buy = CSV.read(joinpath(home_dir,"Input","ZoneA_BUY.csv"),delim=";",DataFrame)
A_sell = CSV.read(joinpath(home_dir,"Input","ZoneA_SELL.csv"),delim=";",DataFrame)
B_buy = CSV.read(joinpath(home_dir,"Input","ZoneB_BUY.csv"),delim=";",DataFrame)
B_sell = CSV.read(joinpath(home_dir,"Input","ZoneB_SELL.csv"),delim=";",DataFrame)
C_buy = CSV.read(joinpath(home_dir,"Input","ZoneC_BUY.csv"),delim=";",DataFrame)
C_sell = CSV.read(joinpath(home_dir,"Input","ZoneC_SELL.csv"),delim=";",DataFrame)

matched_orders_A = DataFrame(BUY_PRICE_A = Int[], BUY_A = Int[], SELL_PRICE_A = Int[], SELL_A = Int[])

F = [120,100,50]

n_doublet = 3;
n_triplet = 6;

model = Model(HiGHS.Optimizer)

@variable(model, X_d1[1:size(A_buy, 1)] >= 0)
@variable(model, X_p1[1:size(A_sell, 1)] >= 0)
@variable(model, X_d2[1:size(B_buy, 1)] >= 0)
@variable(model, X_p2[1:size(B_sell, 1)] >= 0)
@variable(model, X_d3[1:size(C_buy, 1)] >= 0)
@variable(model, X_p3[1:size(C_sell, 1)] >= 0)

@variable(model, NP_1[1:(size(A_sell, 1) - size(A_buy, 1))] )
@variable(model, NP_2[1:(size(B_sell, 1) - size(B_buy, 1))] )
@variable(model, NP_3[1:(size(C_sell, 1) - size(C_buy, 1))] )

# @variable(model, NP_1[1:(X_p1 - X_d1)] >= 0)
# @variable(model, NP_2[1:(X_p2 - X_d2)] >= 0)
# @variable(model, NP_3[1:(X_p3 - X_d3)] >= 0)

@variable(model, F_12[1:(size(NP_1, 1) - size(NP_2, 1))] )
@variable(model, F_13[1:(size(NP_1, 1) - size(NP_3, 1))] )
@variable(model, F_23[1:(size(NP_2, 1) - size(NP_3, 1))] )

# @variable(model, F_12[1:(NP_1-NP_2)] >= 0)
# @variable(model, F_13[1:(NP_1-NP_3)] >= 0)
# @variable(model, F_23[1:(NP_2-NP_3)] >= 0)

for l = 1 : size(F_12, 1)
    @constraint(model, F_12[l] == F[1])
end

for l = 1 : size(F_13, 1)
    @constraint(model, F_13[l] == F[2])
end

for l = 1 : size(F_23, 1)
    @constraint(model, F_23[l] == F[3])
end

@objective(model, Max,
    (sum(BUY_A .* BUY_PRICE_A .* X_d1) +
    sum(BUY_B .* BUY_PRICE_B .* X_d2) +
    sum(BUY_C .* BUY_PRICE_C .* X_d3)) -
    (sum(SELL_A .* SELL_PRICE_A .* X_p1) +
    sum(SELL_B .* SELL_PRICE_B .* X_p2) +
    sum(SELL_C .* SELL_PRICE_C .* X_p3))
)

optimize!(model)

F_12_value = JuMP.value.(F_12)
F_13_value = JuMP.value.(F_13)
F_23_value = JuMP.value.(F_23)

print(F_12_value)
print(F_13_value)
print(F_23_value)
