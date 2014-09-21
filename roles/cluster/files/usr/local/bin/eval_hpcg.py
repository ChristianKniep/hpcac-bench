#! /usr/bin/env python2.7
# -*- coding: utf-8 -*-
"""
Usage:
    eval_hpcg.py [options] <file>

Options:
  -h --help     Show this screen.
  --version     Show version.
"""

from docopt import docopt
import yaml
import re
import os
from pprint import pprint

def fetch_ele(dic, keys, res_key=None):
    """ fetch val from list of keys
    """
    if res_key is None:
        res_key = []
    key = keys.pop()
    res_key.append(key)
    if len(keys) == 0:
        return (".".join(res_key), dic[key])
    dic = dic[key]
    return fetch_ele(dic, keys, res_key)

def main():
    """ main function """
    # Parameter
    options =  docopt(__doc__, version='0.1')
    with open(options.get("<file>"), "r") as fd:
        lines = fd.readlines()
    reg = "(?P<jobid>\d+//HPCG-Benchmark-\d\.\d_(?P<date>[0-9\.]+\.yaml"
    
    obj = yaml.load("\n".join([line.rstrip() for line in lines if re.match("^\s*\w+.*\:", line)]))
    res_map = {
        "time.total": ['Benchmark Time Summary', 'Total'],
        "problem.dim.x": ['Global Problem Dimensions', 'Global nx'],
        "problem.dim.y": ['Global Problem Dimensions', 'Global ny'],
        "problem.dim.z": ['Global Problem Dimensions', 'Global nz'],
        "gflops": ['DDOT Timing Variations', 'HPCG result is VALID with a GFLOP/s rating of'],
        "local.dim.x": ['Local Domain Dimensions', 'nx'],
        "local.dim.y": ['Local Domain Dimensions', 'ny'],
        "local.dim.z": ['Local Domain Dimensions', 'nz'],
        "mach.num_proc": ['Machine Summary', 'Distributed Processes'],
        "mach.threads_per_proc": ['Machine Summary', 'Threads per processes'],
    }
    res = {}
    for short_key, key_dic in res_map.items():
        key_dic.reverse()
        (key, val) = fetch_ele(obj, key_dic)
        res[short_key] = val
    res['node_list'] = os.environ.get('SLURM_NODELIST', 'unkown')
    res['mpi_ver'] = os.environ.get('MPI_VER', 'unkown')
    msg = []
    msg.append("NODES:%(node_list)-15s" % res)
    msg.append("MPI:%(mpi_ver)-10s" % res)
    msg.append("TIME:%(time.total)-8s" % res)
    msg.append("GFLOP/s:%(gflops)-10s" % res)
    msg.append("#THREADS/PROC:%(mach.threads_per_proc)-3s" % res)
    msg.append("#PROC:%(mach.num_proc)-3s" % res)
    msg.append("Problem:%(problem.dim.x)sx%(problem.dim.y)sx%(problem.dim.z)-12s" % res)
    msg.append("Local:%(local.dim.x)sx%(local.dim.y)sx%(local.dim.z)s" % res)
    print " | ".join(msg)
    
# ein Aufruf von main() ganz unten
if __name__ == "__main__":
    main()
