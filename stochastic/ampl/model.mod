set V;
set warehouse;
set K;
set SCEN;

# First Stage Parameters

param Tmax;
param M;

param U{K};
param CV{K};

param t{V,V};
param C{V,V};
param a{V};
param b{V};
param s{V};

# Second Stage Parameters

param dB{V, SCEN};
param dL{V, SCEN};

param n;

# First Stage Variables
var x{V,V,K} binary;

# Second Stage Variables
var W{V,K,SCEN} >= 0;
var I{V,K,SCEN} >= 0;
var J{V,K,SCEN} >= 0;
var y{V,K,SCEN} binary;

minimize cost:
    sum {i in V, j in V, k in K} (C[i,j] * x[i,j,k]) +  sum {j in V, k in K} CV[k] * x[0,j,k]
    + sum{w in SCEN} ( sum{i in V diff warehouse} ((C[i,0]+C[0,i]) * sum{k in K} y[i,k,w] ) ) / n;

subject to con1{i in V diff warehouse, j in V diff warehouse, k in K, w in SCEN}: M * (1 - x[i,j,k]) + I[j,k,w] - dL[j,w] + U[k] * y[i,k,w] >= 0;
subject to con2a{i in V diff warehouse, j in V, k in K, w in SCEN}: M * (1 - x[i,j,k]) + M*y[i,k,w] + I[j,k,w] - (I[i,k,w] - dL[i,w]) >= 0;
subject to con2b{i in V diff warehouse, j in V, k in K, w in SCEN}: -M * (1 - x[i,j,k])-M*y[i,k,w] + I[j,k,w] - (I[i,k,w] - dL[i,w]) <= 0;
subject to con2c{i in V diff warehouse, j in V, k in K, w in SCEN}: -M * (1 - x[i,j,k]) - M * (1-y[i,k,w]) + I[j,k,w] - (I[i,k,w]+U[k]-dL[i,w]) <= 0;
subject to con4a{i in V diff warehouse, j in V, k in K, w in SCEN}: M * (1 - x[i,j,k]) + M* y[i,k,w] + J[j,k,w] - (J[i,k,w] + dB[i,w]) >= 0;
subject to con4b{i in V diff warehouse, j in V, k in K, w in SCEN}: -M * (1 - x[i,j,k]) - M * y[i,k,w] + J[j,k,w] - (J[i,k,w] + dB[i,w]) <= 0;
subject to con4c{i in V diff warehouse, j in V, k in K, w in SCEN}: M * (1 - x[i,j,k]) + M * (1-y[i,k,w]) + (U[k]-I[i,k,w]-J[i,k,w])+J[j,k,w]-dB[i,w] >= 0;
subject to con5{i in V, j in V, k in K, w in SCEN}: M * (1 - x[i,j,k]) + U[k] - (J[i,k,w] + I[i,k,w]) >= 0;
subject to con6{k in K}: sum {j in V} x[0,j,k] <= 1;
subject to con7{k in K}: sum {i in V} x[i,0,k] <= 1;
subject to con8{j in V diff warehouse}: sum {i in V, k in K} x[i,j,k] = 1;
subject to con9{i in V diff warehouse}: sum {j in V, k in K} x[i,j,k] = 1;
subject to con10{j in V diff warehouse, k in K}: sum {i in V} x[i,j,k] = sum {i in V} x[j,i,k];
subject to con11{j in V diff warehouse, k in K, w in SCEN}: W[j,k,w] >= t[0,j] - M * (1-x[0,j,k]);
subject to con12{i in V diff warehouse, k in K, w in SCEN}: W[0,k,w] >= t[i,0]+s[i]+W[i,k,w] - M * (1- x [i,0,k]);
subject to con13{i in V diff warehouse, j in V diff warehouse, k in K, w in SCEN}: W[j,k,w] >= t[i,j]+s[i]+W[i,k,w] + (t[i,0]+t[0,i])*y[i,k,w] - M * (1- x [i,j,k]);
subject to con14a{i in V diff warehouse, k in K, w in SCEN}: a[i] <= W[i,k,w];
subject to con14b{i in V diff warehouse, k in K, w in SCEN}: b[i] >= W[i,k,w];
subject to con15{k in K, w in SCEN}: W[0,k,w] <= Tmax;