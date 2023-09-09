# 
# @Author: Haha Chen 
# @Date: 2023-09-09 12:03:25 
# @Last Modified by:   Haha Chen 
# @Last Modified time: 2023-09-09 12:03:25 
# 

import random

def gen_int():
    return random.randint(0, 240-1)

with open(r'D:\Users\ChenHaHa\Documents\MyOwn\project\huffman\FPGA\project_2\project_2.sim\sim_1\behav\questa/random_int.txt', 'w') as f:
    for i in range(500000):
        f.write(str(gen_int()) + '\n')
