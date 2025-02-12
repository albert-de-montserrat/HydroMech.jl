## Performance comparison for mutable & immutable struct for TwoPhaseFlowEquations

Since there is no significant difference between the usage of mutable/immutable class, after the application of Adapt.@adapt_structure. We use the mutable one for its flexibility.

```bash
# using immutable struct
Time stepping: t_tot = 0.0005, dt = 1e-5
┌ Warning: `object_info(obj::Union{File, Object})` is deprecated, use `API.h5o_get_info1(checkvalid(obj))` instead.
│   caller = jldatatype(parent::JLD.JldFile, dtype::HDF5.Datatype) at jld_types.jl:690
└ @ JLD ~/.julia/packages/JLD/S6t6A/src/jld_types.jl:690
┌ Warning: `object_info(obj::Union{File, Object})` is deprecated, use `API.h5o_get_info1(checkvalid(obj))` instead.
│   caller = typeindex(parent::JLD.JldFile, addr::UInt64) at jld_types.jl:812
└ @ JLD ~/.julia/packages/JLD/S6t6A/src/jld_types.jl:812
Animation directory: ./viz2D_out/
it = 1, time = 6.394e+00 sec (@ T_eff = 2.30 GB/s) 
it = 2, time = 2.201e-01 sec (@ T_eff = 11.00 GB/s) 
it = 3, time = 3.723e-01 sec (@ T_eff = 11.00 GB/s) 
it = 4, time = 3.689e-01 sec (@ T_eff = 8.90 GB/s) 
it = 5, time = 2.962e-01 sec (@ T_eff = 11.00 GB/s) 
it = 6, time = 3.768e-01 sec (@ T_eff = 11.00 GB/s) 
it = 7, time = 3.169e-01 sec (@ T_eff = 10.00 GB/s) 
it = 8, time = 3.818e-01 sec (@ T_eff = 11.00 GB/s) 
it = 9, time = 3.818e-01 sec (@ T_eff = 11.00 GB/s) 
it = 10, time = 3.811e-01 sec (@ T_eff = 11.00 GB/s) 
it = 11, time = 3.791e-01 sec (@ T_eff = 11.00 GB/s) 
it = 12, time = 3.820e-01 sec (@ T_eff = 11.00 GB/s) 
it = 13, time = 3.815e-01 sec (@ T_eff = 11.00 GB/s) 
it = 14, time = 3.698e-01 sec (@ T_eff = 11.00 GB/s) 
it = 15, time = 4.921e-01 sec (@ T_eff = 8.30 GB/s) 
[ Info: Saved animation to /home/wyou/misc/git-julia/HydroMech.jl/test/PorosityWave2D_incompressible.gif
Test Summary:                                 | Pass  Total
Reference test: PorosityWave2D_incompressible |    5      5
     Testing HydroMech tests passed 
```


```bash
# using mutable struct
Time stepping: t_tot = 0.0005, dt = 1e-5
┌ Warning: `object_info(obj::Union{File, Object})` is deprecated, use `API.h5o_get_info1(checkvalid(obj))` instead.
│   caller = jldatatype(parent::JLD.JldFile, dtype::HDF5.Datatype) at jld_types.jl:690
└ @ JLD ~/.julia/packages/JLD/S6t6A/src/jld_types.jl:690
┌ Warning: `object_info(obj::Union{File, Object})` is deprecated, use `API.h5o_get_info1(checkvalid(obj))` instead.
│   caller = typeindex(parent::JLD.JldFile, addr::UInt64) at jld_types.jl:812
└ @ JLD ~/.julia/packages/JLD/S6t6A/src/jld_types.jl:812
Animation directory: ./viz2D_out/
it = 1, time = 6.499e+00 sec (@ T_eff = 2.30 GB/s) 
it = 2, time = 2.220e-01 sec (@ T_eff = 11.00 GB/s) 
it = 3, time = 4.500e-01 sec (@ T_eff = 9.10 GB/s) 
it = 4, time = 2.955e-01 sec (@ T_eff = 11.00 GB/s) 
it = 5, time = 3.288e-01 sec (@ T_eff = 10.00 GB/s) 
it = 6, time = 3.869e-01 sec (@ T_eff = 11.00 GB/s) 
it = 7, time = 2.929e-01 sec (@ T_eff = 11.00 GB/s) 
it = 8, time = 3.841e-01 sec (@ T_eff = 11.00 GB/s) 
it = 9, time = 3.793e-01 sec (@ T_eff = 11.00 GB/s) 
it = 10, time = 3.788e-01 sec (@ T_eff = 11.00 GB/s) 
it = 11, time = 3.786e-01 sec (@ T_eff = 11.00 GB/s) 
it = 12, time = 3.795e-01 sec (@ T_eff = 11.00 GB/s) 
it = 13, time = 3.806e-01 sec (@ T_eff = 11.00 GB/s) 
it = 14, time = 3.796e-01 sec (@ T_eff = 11.00 GB/s) 
it = 15, time = 3.676e-01 sec (@ T_eff = 11.00 GB/s) 
[ Info: Saved animation to /home/wyou/misc/git-julia/HydroMech.jl/test/PorosityWave2D_incompressible.gif
Test Summary:                                 | Pass  Total
Reference test: PorosityWave2D_incompressible |    5      5
     Testing HydroMech tests passed 
```


## Benchmarking for GPUs communication

- Goal: find out the best algorithm out of the `tuned` module

### Allreduce

Firstly let's check which algorithms we can choose within the Open MPI source code

```C
/* valid values for coll_tuned_allreduce_forced_algorithm */
static const mca_base_var_enum_value_t allreduce_algorithms[] = {
    {0, "ignore"},
    {1, "basic_linear"},
    {2, "nonoverlapping"},
    {3, "recursive_doubling"},
    {4, "ring"},
    {5, "segmented_ring"},
    {6, "rabenseifner"},
    {0, NULL}
};
```


```bash
# firstly we run a benchmark of allreduce without specifying the wanted algorithm for allreduce
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                188.91            181.70            206.18        1000
200000                340.12            326.85            367.30        1000
400000                653.49            624.81            726.20        1000
800000               1288.01           1237.06           1401.81        1000
1600000              2500.98           2428.03           2685.87        1000
3200000              4835.77           4681.47           5213.42        1000
```




```bash
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 0 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                188.91            181.73            204.79        1000
200000                340.95            329.31            369.09        1000
400000                653.47            625.27            726.33        1000
800000               1287.86           1239.01           1416.19        1000
1600000              2461.00           2388.66           2638.03        1000
3200000              5091.87           4950.36           5581.74        1000


[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 1 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                282.38            234.93            326.64        1000
200000                531.14            437.42            618.39        1000
400000               1785.82           1535.04           1995.28        1000
800000               3124.20           2489.11           3370.94        1000
1600000              6652.87           5687.09           7141.06        1000
3200000             12774.89          11590.45          13431.57        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 2 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                235.63            187.88            279.57        1000
200000                426.25            335.17            512.48        1000
400000                928.40            724.02           1117.93        1000
800000               2028.55           1418.95           2265.75        1000
1600000              4333.00           3402.03           4806.96        1000
3200000              8644.57           7506.92           9277.69        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 3 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                225.09            215.85            242.03        1000
200000                420.43            401.66            455.58        1000
400000                965.17            872.88           1046.27        1000
800000               1840.35           1756.94           1925.51        1000
1600000              3476.31           3229.06           3797.04        1000
3200000              6619.64           6226.03           7271.89        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 4 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                190.26            180.55            204.62        1000
200000                343.24            329.08            363.92        1000
400000                643.02            615.56            681.21        1000
800000               1240.29           1195.60           1309.38        1000
1600000              2379.18           2324.61           2489.97        1000
3200000              5013.59           4896.93           5356.24        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 5 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                189.72            181.01            202.38        1000
200000                343.51            326.18            368.11        1000
400000                644.34            616.66            683.36        1000
800000               1242.93           1198.71           1309.88        1000
1600000              2382.34           2321.88           2502.16        1000
3200000              5042.74           4899.61           5478.59        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_allreduce_algorithm 6 osu_allreduce -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA Allreduce Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                189.19            182.10            205.89        1000
200000                340.91            329.06            371.53        1000
400000                650.34            620.61            727.53        1000
800000               1295.93           1239.08           1422.91        1000
1600000              2485.25           2386.89           2693.46        1000
3200000              4825.75           4705.17           5159.61        1000
```

### All to all

Same idea as above for allreduce, firstly let's check which algorithms we can choose within the Open MPI source code


```C
/* valid values for coll_tuned_alltoall_forced_algorithm */
static const mca_base_var_enum_value_t alltoall_algorithms[] = {
    {0, "ignore"},
    {1, "linear"},
    {2, "pairwise"},
    {3, "modified_bruck"},
    {4, "linear_sync"},
    {5, "two_proc"},
    {0, NULL}
};
```



```bash
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 0 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                425.38            415.71            438.20        1000
200000                581.33            533.73            608.03        1000
400000                984.05            863.74           1042.04        1000
800000               1853.05           1626.89           1954.92        1000
^[[A^[[B1600000              3679.50           3348.85           3887.69        1000
3200000              7477.47           6683.02           7870.87        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 0 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                420.33            406.24            430.64        1000
200000                577.81            526.10            607.41        1000
400000               1000.56            905.46           1062.94        1000
800000               1917.38           1825.38           1981.69        1000
1600000              3655.49           3450.80           3819.48        1000
3200000              7194.83           6974.15           7478.59        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 1 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                419.08            404.52            441.48        1000
200000                572.08            523.91            601.56        1000
400000               1014.65            931.97           1073.41        1000
800000               1911.66           1782.75           1972.40        1000
1600000              3651.50           3410.06           3797.36        1000
3200000              7235.04           6925.96           7401.02        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 2 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                568.08            542.70            591.89        1000
200000                751.72            699.47            797.65        1000
400000               1122.81           1071.18           1180.94        1000
800000               1882.45           1820.97           1953.62        1000
1600000              3414.76           3294.48           3518.95        1000
3200000              6453.58           6211.23           6598.42        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 3 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000              17079.06          14886.58          18710.19        1000
200000              34372.18          30221.50          36966.10        1000
^C^C[wyou@racklette1 ~]$ ^C
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 4 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
100000                424.61            414.48            434.69        1000
200000                601.03            574.16            623.39        1000
400000               1074.30            991.98           1134.93        1000
800000               2026.54           1856.56           2126.15        1000
1600000              3897.18           3565.51           4089.64        1000
3200000              7654.23           6901.72           8030.77        1000
[wyou@racklette1 ~]$ $(which mpirun) -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH -n 8 --hostfile ./4nodes -npernode 640 -mca coll_tuned_use_dynamic_rules 1 -mca coll_tuned_alltoall_algorithm 5 osu_alltoall -f -m 100000:5242880 -i 1000 -M 50000000 -d cuda D D

# OSU MPI-CUDA All-to-All Personalized Exchange Latency Test v5.9
# Size       Avg Latency(us)   Min Latency(us)   Max Latency(us)  Iterations
[racklette1:1216262] *** An error occurred in MPI_Alltoall
[racklette1:1216262] *** reported by process [3756916737,2]
[racklette1:1216262] *** on communicator MPI_COMM_WORLD
[racklette1:1216262] *** MPI_ERR_UNSUPPORTED_OPERATION: operation not supported
[racklette1:1216262] *** MPI_ERRORS_ARE_FATAL (processes in this communicator will now abort,
[racklette1:1216262] ***    and potentially your MPI job)
[racklette1:1216244] 7 more processes have sent help message help-mpi-errors.txt / mpi_errors_are_fatal
[racklette1:1216244] Set MCA parameter "orte_base_help_aggregate" to 0 to see all help / error messages


```




## Improving the source code


```bash
# without visualization
it = 1530, time = 5.027e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1531, time = 4.839e-01 sec (@ T_eff = 24.00 GB/s) 
it = 1532, time = 4.861e-01 sec (@ T_eff = 24.00 GB/s) 
it = 1533, time = 5.011e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1534, time = 4.852e-01 sec (@ T_eff = 24.00 GB/s) 
it = 1535, time = 5.018e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1536, time = 4.849e-01 sec (@ T_eff = 24.00 GB/s) 
```



```bash
# with visualization
it = 1530, time = 5.132e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1531, time = 5.105e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1532, time = 5.286e-01 sec (@ T_eff = 22.00 GB/s) 
it = 1533, time = 5.123e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1534, time = 5.308e-01 sec (@ T_eff = 22.00 GB/s) 
it = 1535, time = 5.107e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1536, time = 5.233e-01 sec (@ T_eff = 22.00 GB/s) 
```


After some basic HPC-driven code improvement while making sure all the reference tests passed, the original 2D code has the following performance

```bash
# without visualization
it = 1530, time = 4.946e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1531, time = 5.352e-01 sec (@ T_eff = 22.00 GB/s) 
it = 1532, time = 4.941e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1533, time = 4.940e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1534, time = 5.163e-01 sec (@ T_eff = 22.00 GB/s) 
it = 1535, time = 4.942e-01 sec (@ T_eff = 23.00 GB/s) 
it = 1536, time = 4.942e-01 sec (@ T_eff = 23.00 GB/s) 
```



```bash
# with visualization
it = 1530, time = 4.619e-01 sec (@ T_eff = 25.00 GB/s) 
it = 1531, time = 4.601e-01 sec (@ T_eff = 25.00 GB/s) 
it = 1532, time = 4.899e-01 sec (@ T_eff = 24.00 GB/s) 
it = 1533, time = 4.594e-01 sec (@ T_eff = 25.00 GB/s) 
it = 1534, time = 4.651e-01 sec (@ T_eff = 25.00 GB/s) 
it = 1535, time = 4.665e-01 sec (@ T_eff = 25.00 GB/s) 
it = 1536, time = 4.837e-01 sec (@ T_eff = 24.00 GB/s) 
```






## Distributed Computing





## Tutorial



### Simple Performance Estimation

We can estimate the performance using the following metrics 

$$T_\text{eff} = \frac{A_\text{eff}}{t_\text{it}} = \frac{2 D_u + D_k}{\Delta t / \text{niter}}$$

TODO: add the example of the effective memory






### Parallelizing a serial code


- STEP 1: Precompute scalars, remove divisions

```julia
# instead of division, we precompute the fractions to be multipled on
_β_dτ_D     = 1. /β_dτ_D
```

- STEP 2: Remove element-wise operators and use loops instead for updating the elements of the arrays, where we introduce the indices like `ix`, `iy`

```julia
# the pressure update using the element-wise arithmetic operations
Pf     .-= ((qDx[2:end, :] - qDx[1:end-1, :]).* _dx .+ (qDy[:, 2:end] - qDy[:, 1:end-1]).* _dy).* _β_dτ_D
```


- STEP 3: Remove the julia functions like `diff(A, dims=1)` and use the indices `ix`, `iy` instead to "manually" compute the differences. Another possibility is to use the macros of the `ParallelStencil` package by `@d_xa`, `@d_ya` etc

```julia
# we manually implemented the macros
macro d_xa(A)  esc(:( $A[ix+1,iy]-$A[ix,iy] )) end
macro d_ya(A)  esc(:( $A[ix,iy+1]-$A[ix,iy] )) end

# and use them for the loop version of differences calculation
Pf[ix,iy]     -= (@d_xa(qDx) * _dx + @d_ya(qDy)* _dy) * _β_dτ_D

```


- STEP 4: After verifying the correctness of the bounds to be iterated on, add the macro `@inbounds` at the needed places

- STEP 5: Move the loops into a compute kernel in the following forms

```julia
function compute_Pf!(Pf,...)
    nx, ny = size(Pf)
    ...
    return nothing
end
```


### Parallelizing using `ParallelStencil.jl`


For the macros that can be used, check the [FiniteDifferences.jl](https://github.com/omlins/ParallelStencil.jl/blob/83c607b2d4fdcc38dceb130b3458ff736ebe9a18/src/FiniteDifferences.jl)

```julia

using Printf, LazyArrays, Plots, BenchmarkTools
using JLD  # for storing testing data


@views av1(A) = 0.5.*(A[1:end-1].+A[2:end])
@views avx(A) = 0.5.*(A[1:end-1,:].+A[2:end,:])
@views avy(A) = 0.5.*(A[:,1:end-1].+A[:,2:end])


macro d_xa(A)  esc(:( $A[ix+1,iy]-$A[ix,iy] )) end
macro d_ya(A)  esc(:( $A[ix,iy+1]-$A[ix,iy] )) end



# Darcy's flux update
function compute_flux_darcy!(Pf, T, qDx, qDy, _dx, _dy, k_ηf, αρgx, αρgy, _1_θ_dτ_D)
    nx, ny = size(Pf)

    for iy = 1:ny
        for ix = 1:nx-1
            # qDx[2:end-1,:] .-= (qDx[2:end-1,:] .+ k_ηf.*((Pf[2:end,:] .- Pf[1:end-1, :]) .* _dx .- αρgx.*avx(T))).* _1_θ_dτ_D
            qDx[ix+1,iy] -= (qDx[ix+1,iy] + k_ηf * (@d_xa(Pf) * _dx - αρgx *  0.5 * (T[ix,iy] + T[ix+1,iy]))) * _1_θ_dτ_D
            
        end
    end
    
    for iy = 1:ny-1
        for ix = 1:nx
            # qDy[:,2:end-1] .-= (qDy[:,2:end-1] .+ k_ηf.*((Pf[:, 2:end] .- Pf[:, 1:end-1]) .* _dy .- αρgy.*avy(T))).* _1_θ_dτ_D
            qDy[ix,iy+1] -= (qDy[ix,iy+1] + k_ηf * (@d_ya(Pf) * _dy - αρgy * 0.5 * (T[ix, iy] + T[ix, iy+1]))) * _1_θ_dτ_D
        end
    end

end


# pressure update
function compute_Pf!(Pf, qDx, qDy, _dx, _dy, _β_dτ_D)
    nx, ny = size(Pf)

    for iy = 1:ny
        for ix = 1:nx
            # Pf     .-= ((qDx[2:end, :] - qDx[1:end-1, :]).* _dx .+ (qDy[:, 2:end] - qDy[:, 1:end-1]).* _dy).* _β_dτ_D
            @inbounds Pf[ix,iy]     -= (@d_xa(qDx) * _dx + @d_ya(qDy)* _dy) * _β_dτ_D
        end
    end

    return nothing
end


function compute_flux_temp!(Pf, T, qTx, qTy, _dx, _dy, λ_ρCp, _1_θ_dτ_T)
    nx, ny = size(Pf)

    for iy = 1:ny-2
        for ix = 1:nx-1
            # qTx            .-= (qTx .+ λ_ρCp.*(Diff(T[:,2:end-1],dims=1)./dx))./(1.0 + θ_dτ_T)
            qTx[ix,iy]  -= (qTx[ix,iy] + λ_ρCp*(@d_xa(T[:,2:end-1])* _dx)) * _1_θ_dτ_T                    
        end
    end
    
    for iy = 1:ny-1
        for ix = 1:nx-2
            # qTy            .-= (qTy .+ λ_ρCp.*(Diff(T[2:end-1,:],dims=2)./dy))./(1.0 + θ_dτ_T)
            qTy[ix,iy]  -= (qTy[ix,iy] + λ_ρCp*(@d_ya(T[2:end-1,:])* _dy)) * _1_θ_dτ_T
        end
    end

end



function compute_T!(T, dTdt, qTx, qTy, _dx, _dy, _dt_β_dτ_T)
    nx, ny = size(T)

    for iy = 1:ny-2
        for ix = 1:nx-2
            # T[2:end-1,2:end-1] .-= (dTdt .+ @d_xa(qTx).* _dx .+ @d_ya(qTy).* _dy).* _dt_β_dτ_T
            T[ix+1,iy+1] -= (dTdt[ix,iy] + @d_xa(qTx)* _dx + @d_ya(qTy)* _dy)* _dt_β_dτ_T                    
        end
    end
end



@views function porous_convection_2D_xpu(ny_, nt_; do_visu=false, do_check=true, test=true)
    # physics
    lx,ly       = 40., 20.
    k_ηf        = 1.0
    αρgx,αρgy   = 0.0,1.0
    αρg         = sqrt(αρgx^2+αρgy^2)
    ΔT          = 200.0
    ϕ           = 0.1
    Ra          = 1000                    # changed from 100
    λ_ρCp       = 1/Ra*(αρg*k_ηf*ΔT*ly/ϕ) # Ra = αρg*k_ηf*ΔT*ly/λ_ρCp/ϕ
  
    # numerics
    ny          = ny_                     # ceil(Int,nx*ly/lx)
    nx          = 2 * (ny+1) - 1          # 127
    nt          = nt_                     # 500
    re_D        = 4π
    cfl         = 1.0/sqrt(2.1)
    maxiter     = 10max(nx,ny)
    ϵtol        = 1e-6
    nvis        = 20
    ncheck      = ceil(max(nx,ny)) # ceil(0.25max(nx,ny))
  
    # preprocessing
    dx,dy       = lx/nx,ly/ny
    xn,yn       = LinRange(-lx/2,lx/2,nx+1),LinRange(-ly,0,ny+1)
    xc,yc       = av1(xn),av1(yn)
    θ_dτ_D      = max(lx,ly)/re_D/cfl/min(dx,dy)
    β_dτ_D      = (re_D*k_ηf)/(cfl*min(dx,dy)*max(lx,ly))
   
    # hpc value precomputation
    _dx, _dy    = 1. /dx, 1. /dy
    _ϕ          = 1. / ϕ
    _1_θ_dτ_D   = 1 ./(1.0 + θ_dτ_D)
    _β_dτ_D     = 1. /β_dτ_D


    # array initialization
    Pf          = zeros(nx,ny)
    r_Pf        = zeros(nx,ny)
    qDx,qDy     = zeros(nx+1,ny),zeros(nx,ny+1)
    qDx_c,qDy_c = zeros(nx,ny),zeros(nx,ny)
    qDmag       = zeros(nx,ny)     
    T           = @. ΔT*exp(-xc^2 - (yc'+ly/2)^2); T[:,1] .= ΔT/2; T[:,end] .= -ΔT/2
    T_old       = copy(T)
    dTdt        = zeros(nx-2,ny-2)
    r_T         = zeros(nx-2,ny-2)
    qTx         = zeros(nx-1,ny-2)
    qTy         = zeros(nx-2,ny-1)
   
    st          = ceil(Int,nx/25)
    Xc, Yc      = [x for x=xc, y=yc], [y for x=xc,y=yc]
    Xp, Yp      = Xc[1:st:end,1:st:end], Yc[1:st:end,1:st:end]

    # visu
    if do_visu
        # needed parameters for plotting

        # plotting environment
        ENV["GKSwstype"]="nul"
        if isdir("viz_out")==false mkdir("viz_out") end
        loadpath = "viz_out/"; anim = Animation(loadpath,String[])
        println("Animation directory: $(anim.dir)")
        iframe = 0
    end



    # action
    t_tic = 0.0; niter = 0
    for it = 1:nt
        T_old .= T

        # time step
        dt = if it == 1 
            0.1*min(dx,dy)/(αρg*ΔT*k_ηf)
        else
            min(5.0*min(dx,dy)/(αρg*ΔT*k_ηf),ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1)
        end

        _dt = 1. /dt   # precomputation
        
        
        re_T    = π + sqrt(π^2 + ly^2/λ_ρCp * _dt)
        θ_dτ_T  = max(lx,ly)/re_T/cfl/min(dx,dy)
        β_dτ_T  = (re_T*λ_ρCp)/(cfl*min(dx,dy)*max(lx,ly))
        
        _1_θ_dτ_T   = 1 ./ (1.0 + θ_dτ_T)
        _dt_β_dτ_T  = 1 ./(_dt + β_dτ_T) # precomputation

        # iteration loop
        iter = 1; err_D = 2ϵtol; err_T = 2ϵtol
        while max(err_D,err_T) >= ϵtol && iter <= maxiter
            if (it==1 && iter == 11) t_tic = Base.time(); niter=0 end

            # hydro            
            compute_flux_darcy!(Pf, T, qDx, qDy, _dx, _dy, k_ηf, αρgx, αρgy, _1_θ_dτ_D)
            compute_Pf!(Pf, qDx, qDy, _dx, _dy, _β_dτ_D)
            
            # thermo
            compute_flux_temp!(Pf, T, qTx, qTy, _dx, _dy, λ_ρCp, _1_θ_dτ_T)
            #     dTdt        = zeros(nx-2,ny-2)
            

            dTdt           .= (T[2:end-1,2:end-1] .- T_old[2:end-1,2:end-1]).* _dt .+
                                (max.(qDx[2:end-2,2:end-1],0.0).*Diff(T[1:end-1,2:end-1],dims=1).* _dx .+
                                 min.(qDx[3:end-1,2:end-1],0.0).*Diff(T[2:end  ,2:end-1],dims=1).* _dx .+
                                 max.(qDy[2:end-1,2:end-2],0.0).*Diff(T[2:end-1,1:end-1],dims=2).* _dy .+
                                 min.(qDy[2:end-1,3:end-1],0.0).*Diff(T[2:end-1,2:end  ],dims=2).* _dy).* _ϕ

            
            # for iy = 1:ny-2
            #     for ix = 1:nx-2
            #         dTdt[ix,iy]           = (T[ix+1,iy+1] - T_old[ix+1,iy+1]) * _dt +
            #         (max(qDx[2:end-2,2:end-1],0.0) * @d_xa(T[1:end-1,2:end-1]) * _dx  +
            #          min(qDx[3:end-1,2:end-1],0.0) * @d_xa(T[2:end  ,2:end-1]) * _dx  +
            #          max(qDy[2:end-1,2:end-2],0.0) * @d_ya(T[2:end-1,1:end-1]) * _dy  +
            #          min(qDy[2:end-1,3:end-1],0.0) * @d_ya(T[2:end-1,2:end  ]) * _dy) * _ϕ

            #     end
            # end
            
            compute_T!(T, dTdt, qTx, qTy, _dx, _dy, _dt_β_dτ_T)


            # TODO: add the boundary condition kernel afterwards
            # Boundary condition
            T[[1,end],:]        .= T[[2,end-1],:]


            if do_check && iter % ncheck == 0
                r_Pf  .= Diff(qDx,dims=1).* _dx .+ Diff(qDy,dims=2).* _dy
                r_T   .= dTdt .+ Diff(qTx,dims=1).* _dx .+ Diff(qTy,dims=2).* _dy
                err_D  = maximum(abs.(r_Pf))
                err_T  = maximum(abs.(r_T))
                # @printf("  iter/nx=%.1f, err_D=%1.3e, err_T=%1.3e\n",iter/nx,err_D,err_T)
            end
            iter += 1; niter += 1
        end
        # @printf("it = %d, iter/nx=%.1f, err_D=%1.3e, err_T=%1.3e\n",it,iter/nx,err_D,err_T)

        if it % nvis == 0
            qDx_c .= avx(qDx)
            qDy_c .= avy(qDy)
            qDmag .= sqrt.(qDx_c.^2 .+ qDy_c.^2)
            qDx_c ./= qDmag
            qDy_c ./= qDmag
            qDx_p = qDx_c[1:st:end,1:st:end]
            qDy_p = qDy_c[1:st:end,1:st:end]
            

            # visualisation
            if do_visu
                heatmap(xc,yc,T';xlims=(xc[1],xc[end]),ylims=(yc[1],yc[end]),aspect_ratio=1,c=:turbo)
                png(quiver!(Xp[:], Yp[:], quiver=(qDx_p[:], qDy_p[:]), lw=0.5, c=:black),
                    @sprintf("viz_out/porous2D_%04d.png",iframe+=1))
            end
        end

    end


    t_toc = Base.time() - t_tic
    # FIXME: change the expression to compute the effective memory throughput!
    A_eff = (3 * 2) / 1e9 * nx * ny * sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it  = t_toc / niter                              # Execution time per iteration [s]
    T_eff = A_eff / t_it                               # Effective memory throughput [GB/s]
    
    @printf("Time = %1.3f sec, T_eff = %1.3f GB/s \n", t_toc, T_eff)


    if test == true
        save("../test/qDx_p_ref_30_2D.jld", "data", qDx_c[1:st:end,1:st:end])  # store case for reference testing
        save("../test/qDy_p_ref_30_2D.jld", "data", qDy_c[1:st:end,1:st:end])
    end
    
    # Return qDx_p and qDy_p at final time
    return [qDx_c[1:st:end,1:st:end], qDy_c[1:st:end,1:st:end]]   
end



if isinteractive()
    porous_convection_2D_xpu(63, 500; do_visu=false, do_check=true,test=false)  # ny = 63
end



```