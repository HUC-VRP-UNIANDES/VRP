set V;
set warehouse;
set K;

param U{K};
param CV{K};

param t{V,V};
param C{V,V};
param a{V};
param b{V};
param s{V};
param dB{V};
param dL{V};

param Tmax;
param M;

var x{V,V,K} binary;
var W{V,K} >= 0;
var I{V,K} >= 0;
var J{V,K} >= 0;

minimize cost:
    sum {i in V, j in V, k in K} (C[i,j] * x[i,j,k]) +  sum {j in V, k in K} CV[k] * x[0,j,k];

subject to con1{i in V diff warehouse, j in V diff warehouse, k in K}: M * (1 - x[i,j,k]) + I[j,k] - dL[j] >= 0;
subject to con2a{i in V diff warehouse, j in V, k in K}: M * (1 - x[i,j,k]) + I[j,k] - (I[i,k] - dL[i]) >= 0;
subject to con2b{i in V diff warehouse, j in V, k in K}: -M * (1 - x[i,j,k]) + I[j,k] - (I[i,k] - dL[i]) <= 0;
subject to con4a{i in V diff warehouse, j in V, k in K}: M * (1 - x[i,j,k]) + J[j,k] - (J[i,k] + dB[i]) >= 0;
subject to con4b{i in V diff warehouse, j in V, k in K}: -M * (1 - x[i,j,k]) + J[j,k] - (J[i,k] + dB[i]) <= 0;
subject to con5{i in V, j in V, k in K}: M * (1 - x[i,j,k]) + U[k] - (J[i,k] + I[i,k]) >= 0;
subject to con6{k in K}: sum {j in V} x[0,j,k] <= 1;
subject to con7{k in K}: sum {i in V} x[i,0,k] <= 1;
subject to con8{j in V diff warehouse}: sum {i in V, k in K} x[i,j,k] = 1;
subject to con9{i in V diff warehouse}: sum {j in V, k in K} x[i,j,k] = 1;
subject to con10{j in V diff warehouse, k in K}: sum {i in V} x[i,j,k] = sum {i in V} x[j,i,k];
subject to con11{j in V diff warehouse, k in K}: W[j,k] >= t[0,j] - M * (1-x[0,j,k]);
subject to con12{i in V diff warehouse, k in K}: W[0,k] >= t[i,0]+s[i]+W[i,k] - M * (1- x [i,0,k]);
subject to con13{i in V diff warehouse, j in V diff warehouse, k in K}: W[j,k] >= t[i,j]+s[i]+W[i,k] - M * (1- x [i,j,k]);
subject to con14a{i in V diff warehouse, k in K}: a[i] <= W[i,k];
subject to con14b{i in V diff warehouse, k in K}: b[i] >= W[i,k];
subject to con15{k in K}: W[0,k] <= Tmax;