from amplpy import AMPL, Constraint, DataFrame
from itertools import product
import pandas as pd


def solve_vrptftw(file_path):
    (T_max, VCapacity, VCost, NTimeFrame,
     NServiceTime, NLinehaulDemand, NBackhaulDemand,
     ECost, ETime) = extract_data_from_file(file_path)

    ECost, ETime = unfeasible_default_edges(T_max, NTimeFrame, ECost, ETime)

    ampl = AMPL()

    ampl.read("model.mod")

    ampl.set["V"] = NServiceTime.keys()
    ampl.set["warehouse"] = [0]
    ampl.set["K"] = VCapacity.keys()

    ampl.get_parameter("Tmax").set(T_max)
    ampl.get_parameter("U").set_values(VCapacity)
    ampl.get_parameter("CV").set_values(VCost)
    ampl.get_parameter("t").set_values(ETime)
    ampl.get_parameter("C").set_values(ECost)
    ampl.get_parameter("a").set_values({k: NTimeFrame[k][0] for k in NTimeFrame})
    ampl.get_parameter("b").set_values({k: NTimeFrame[k][1] for k in NTimeFrame})
    ampl.get_parameter("s").set_values(NServiceTime)
    ampl.get_parameter("dB").set_values(NBackhaulDemand)
    ampl.get_parameter("dL").set_values(NLinehaulDemand)
    ampl.get_parameter("M").set(10 ** 6)

    ampl.option["solver"] = "gurobi"
    ampl.solve()

    return ampl

def unfeasible_default_edges(T_max, NTimeFrame, ECost, ETime):
    ECost = {(i,j): ECost.get((i,j),10 ** 6) for i,j in product(NTimeFrame, NTimeFrame)}
    ETime = {(i,j): ETime.get((i,j),2 * T_max) for i,j in product(NTimeFrame, NTimeFrame)}
    return ECost,ETime

def extract_data_from_file(file_path):
    file = open(file_path)

    T_max = 0
    VCapacity = {}
    VCost = {}
    NTimeFrame = {}
    NServiceTime = {}
    NLinehaulDemand = {}
    NBackhaulDemand = {}
    ECost = {}
    ETime = {}

    read_type = ""
    for line in file.readlines():
        line = line.replace("\n","").strip()
        parts = line.split(" ")
        if parts[0] == "MAX_TIME":
            T_max = float(parts[1])
        elif parts[0] == "VEHICLE_SECTION":
            read_type = "VEHICLE_SECTION"
        elif parts[0] == "NODE_SECTION":
            read_type = "NODE_SECTION"
        elif parts[0] == "EDGE_SECTION":
            read_type = "EDGE_SECTION"
        elif read_type == "VEHICLE_SECTION":
            k, U_k, C_k = parts
            VCapacity[int(k)] = float(U_k)
            VCost[int(k)] = float(C_k) 
        elif read_type == "NODE_SECTION":
            i, a_i, b_i, s_i, d_i_B, d_i_L = parts
            NTimeFrame[int(i)] = (float(a_i),float(b_i))
            NServiceTime[int(i)] = float(s_i)
            NLinehaulDemand[int(i)] = float(d_i_L)
            NBackhaulDemand[int(i)] = float(d_i_B)
        elif read_type == "EDGE_SECTION":
            i, j, c_ij, t_ij = parts
            ECost[(int(i),int(j))] = float(c_ij)
            ETime[(int(i),int(j))] = float(t_ij)

    file.close()
    return T_max,VCapacity,VCost,NTimeFrame,NServiceTime,NLinehaulDemand,NBackhaulDemand,ECost,ETime