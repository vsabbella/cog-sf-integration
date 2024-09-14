#!/usr/bin/env python3

import json

# Open and read the JSON file
with open('resp.json', 'r') as file:
    data = json.load(file)

a=[]
mydict={}
# Iterating through the json list
for i in data:
    #print(i)
    for j in data[i]:
        #print(j)
        for k in j:
            if k in a:
             mydict[k]='yesd'
            else:
             mydict[k]='nod'
             a.append(k)
        




print(mydict)


    