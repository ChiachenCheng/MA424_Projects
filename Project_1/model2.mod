param N_AGV;
param N_SKU;
param N_racks;
param N_workstation;
param N_moving;

set AGV := 1..N_AGV;
set SKU := 1..N_SKU;
set rack := 1..N_racks;
set workstation := 1..N_workstation;
set moving_SKU := 1..N_moving;
set Axes := {"x","y"};

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
var y{AGV, rack}binary;
var supply{workstation, SKU} >=0, integer;
var total_unfulfill{SKU} >=0, integer;

minimize Total_Cost: 
alpha1 * (sum {a in AGV,r in rack} distar[a,r]*y[a,r]) + 
alpha2 * (sum {w in workstation,r in rack} distwr[w,r]*x[w,r]) + 
alpha3 * (sum {s in SKU} total_unfulfill[s]);

subject to
unfulfilled{s in SKU}: total_unfulfill[s] >= total_demand[s]- sum{w in workstation}supply[w,s];
supplys{w in workstation, s in SKU}: supply[w,s] = sum{r in rack} inventory[r,s]*x[w,r];
knapsack1{r in rack}: sum{w in workstation} x[w,r] <= 1;
knapsack2{w in workstation}: sum{r in rack} x[w,r] <= Berths[w];
y1{a in AGV}: sum{r in rack} y[a,r] <= 1;
y2{r in rack}: sum{a in AGV} y[a,r] = sum{w in workstation} x[w,r];
mov1{m in moving_SKU}: sum{w in workstation} x[w,moving[m,"r"]] = 1;
mov2{m in moving_SKU}: y[moving[m,"a"],moving[m,"r"]] = 1;
