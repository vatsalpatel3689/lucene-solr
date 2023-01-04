# dynamic inventory script -> [CH],[HYD]

import urllib.request, json
import sys
import re


batches = 10

filename = "host_{collectionName}_{solrInstanceType}"

def populateHost(l,f,hosts):
    if l%batches == 0:
      batchSize = int(l/batches)
    else:
      batchSize = int(1+l/batches)
    print("****** updating in batch size of : "+str(batchSize)+"**************************")
    f.write("[batch0]\n")
    ctr = 1
    i = 0
    for ip in hosts:
      if (i == batchSize*ctr):
        f.write("\n[batch"+str(ctr)+"]\n")
        ctr = ctr+1
      f.write(ip+"\n")
      i = i+1

print("starting ip discovery and host files population")

# port forward 8983 to a live solr instance : ssh -N -L localhost:8983:10.33.210.125:8983 10.33.139.212 (ch)
# ssh -N -L localhost:8983:10.51.56.89:8983 10.33.139.212 (hyd)
# NOTE: port forward to an instance in ch for CH deployment, or to an instance in hyd for HYD deployment.
# TODO: can figure out master among tlog m/cs using  "leader": "true" field.

with urllib.request.urlopen("http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS") as url:
    data = json.load(url)
    hosts = []
    collectionsMeta = data["cluster"]["collections"]
    collectionList = collectionsMeta.keys()
    for collection,meta in collectionsMeta.items():
        tlogList = []
        pullList = []
        print("ip discovery for collection:"+collection)
#       parse values to segregate a list of tlog ips and pull ips.
        for values in meta["shards"]["shard1"]["replicas"].values():
            unparsedIP = values["node_name"]
            parsedIP = ""
            for ch in unparsedIP:
              if ch != ':':
                parsedIP = parsedIP + ch
              elif ch == ':':
                break
            if (values["type"] == "PULL"):
              pullList.append(parsedIP)
            elif (values["type"] == "TLOG"):
              tlogList.append(parsedIP)
#       make a host file for tlog, and another for pull. suffix collectionName in host file name.
        fPULL = open(filename.format(collectionName= collection,solrInstanceType="PULL"),"w")
        fTLOG = open(filename.format(collectionName= collection,solrInstanceType="TLOG"),"w")
        lPULL = len(pullList)
        lTLOG = len(tlogList)
        larr = []
        larr.append(lPULL)
        larr.append(lTLOG)
        print("****** total pull m/cs : "+str(lPULL)+" and tlog m/cs : "+str(lTLOG)+"***************")
        populateHost(lPULL,fPULL,pullList)
        populateHost(lTLOG,fTLOG,tlogList)

# ###################################    EOF #################################### #