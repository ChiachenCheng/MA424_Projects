param N_AGV;
param N_SKU;
param N_racks;
param N_workstation;
param N_moving;
param max_iter := 3;

set AGV := 1..N_AGV;
set SKU := 1..N_SKU;
set rack := 1..N_racks;
set workstation := 1..N_workstation;
set moving_SKU := 1..N_moving;
set Axes := {"x","y"};
set iter := 1..max_iter;

param alpha1;
param alpha2;
param alpha3;
param Berths{workstation};
param moving{moving_SKU, {"r","a"}};
param demand{workstation, SKU};
param inventory{rack, SKU};
param total_demand{s in SKU} := sum{w in workstation} demand[w,s];

param loc_work{workstation, Axes};
param loc_rack{rack, Axes};
param loc_AGV{AGV, Axes};
param distwr{w in workstation, r in rack} := abs(loc_work[w,"x"]-loc_rack[r,"x"])+abs(loc_work[w,"y"]-loc_rack[r,"y"]);
param distar{a in AGV, r in rack} := abs(loc_AGV[a,"x"]-loc_rack[r,"x"])+abs(loc_AGV[a,"y"]-loc_rack[r,"y"]);

var x{workstation, rack}binary;
var y{AGV, rack, iter}binary;
var z{AGV, workstation, iter}binary;
var yz{AGV, workstation, rack, iter}binary;
var supply{workstation, SKU} >=0, integer;
var total_unfulfill{SKU} >=0, integer;

minimize Total_Cost: 
alpha1 * (sum {a in AGV,r in rack} distar[a,r]*y[a,r,1]) + alpha1 * (sum {a in AGV,r in rack, w in workstation, i in 1..max_iter-1} distwr[w,r]*yz[a,w,r,i]) 
+ alpha2 * (sum {w in workstation,r in rack} distwr[w,r]*x[w,r]) + alpha3 * (sum {s in SKU} total_unfulfill[s]);

subject to
unfulfilled{s in SKU}: total_unfulfill[s] >= total_demand[s]- sum{w in workstation}supply[w,s];
supplys{w in workstation, s in SKU}: supply[w,s] = sum {r in rack} inventory[r,s]*x[w,r];
knapsack1{r in rack}: sum{w in workstation} x[w,r] <= 1;
knapsack2{w in workstation}: sum{r in rack} x[w,r] <= Berths[w];
y1{a in AGV, i in iter}: sum{r in rack} y[a,r,i] <= 1;
y2{r in rack}: sum{a in AGV, i in iter} y[a,r,i] = sum{w in workstation} x[w,r];
y3{a in AGV, i in 2..max_iter}: sum{r in rack} y[a,r,i] <= sum{r in rack} y[a,r,i-1];
z1{a in AGV, i in iter, w in workstation, r in rack}: z[a,w,i] >= y[a,r,i] + x[w,r] - 1;
z2{a in AGV, i in iter}: sum{w in workstation} z[a,w,i] = sum{r in rack} y[a,r,i];
zy{a in AGV, i in 2..max_iter, w in workstation, r in rack}: yz[a,w,r,i-1] >= z[a,w,i-1] + y[a,r,i] - 1;
mov1{m in moving_SKU}: sum{w in workstation} x[w,moving[m,"r"]] = 1;
mov2{m in moving_SKU}: y[moving[m,"a"],moving[m,"r"],1] = 1;
