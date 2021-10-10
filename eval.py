import os
import csv
import subprocess
import sys
import json
# os.system("rm -r logs")

strategy_list = ["none", "linear", "linearExhaustive"]
field_names = ["-sat", "-unsat", "-unknown"]
my_dict = {}
for stg in strategy_list:
    count = 0
    directory = "smt-out-" + stg
    for filename in os.listdir(directory):
        # if (count>2):
        #     break
        if (filename.endswith(".smt")):
            if filename not in my_dict:
                my_dict[filename] = dict()
                for f1 in strategy_list:
                    for f2 in field_names:
                        my_dict[filename][f1+f2] = 0
            count+= 1
            try:
                stng = "z3 smt-out-{}/{}".format(stg, filename, stg)
                output = subprocess.run(stng.split(), timeout=5, stdout=subprocess.PIPE).stdout.decode('utf-8')
            except:
                output = ""
            #print(output.stdout.decode('utf-8'))
            #os.system("z3 smt-out-{}/{} > log-{}.txt".format(stg, filename, stg))
            #f = open("log-{}.txt".format(stg), 'r')
            #lines = output.split('\n')
            quer = "sat"
            p_quer = "unsat"
            u_quer = "unknown"
            count_sat = output.count(quer) - output.count(p_quer)
            count_unsat = output.count(p_quer)
            count_unknown = output.count(u_quer) + output.count("Unknown")
            # for line in lines:
            #     if (line.startswith(quer)):
            #         count_sat+=1
            #     elif (line.startswith(p_quer)):
            #         count_unsat+=1
            #     elif (line.startswith(u_quer)):
            #         count_unknown+=1
            my_dict[filename][stg+"-sat"] = count_sat
            my_dict[filename][stg+"-unsat"]=  count_unsat
            my_dict[filename][stg+"-unknown"] = count_unknown
            #print(my_dict)
            print(filename, count)

headers = ["contract-id"]
for f1 in strategy_list:
    for f2 in field_names:
        headers.append(f1+f2)

print(my_dict)
#sys.exit(0)

#a = json.dumps(my_dict)
#print(a)
#my_dict = a
#out_file = open("out.csv", "w")

def mergedict(a,b):
    a.update(b)
    return a

with open("out.csv", "w") as f:
    w = csv.DictWriter( f, headers )
    w.writeheader()
    for k,d in sorted(my_dict.items()):
        w.writerow(mergedict({'contract-id': k},d))

# with open("out.csv", 'w') as csvfile: 
#     # creating a csv dict writer object 
#     writer = csv.DictWriter(csvfile, fieldnames = headers)
        
#     # writing headers (field names) 
#     writer.writeheader() 
        
#     # writing data rows 
#     writer.writerows(my_dict) 

# csvfile.close()

