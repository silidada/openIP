# 
# Author: Haha Chen 
# Date: 2023-09-09 12:03:41 
# Last Modified by:   Haha Chen 
# Last Modified time: 2023-09-09 12:03:41 
# 

with open(r"D:\Users\ChenHaHa\Documents\MyOwn\project\huffman\FPGA\project_2\project_2.sim\sim_1\behav\questa\huffman_code.txt", "r") as f:
    huffman_code = f.read()
    huffman_code = huffman_code.split("\n")

with open(r"D:\Users\ChenHaHa\Documents\MyOwn\project\huffman\FPGA\project_2\project_2.sim\sim_1\behav\questa\random_int.txt", "r") as f:
    int_data = f.read()
    int_data = int_data.split("\n")
    int_data = [int(i) for i in int_data[:-1]]

with open(r"D:\Users\ChenHaHa\Documents\MyOwn\project\huffman\FPGA\project_2\project_2.sim\sim_1\behav\questa\encoded.txt", "r") as f:
    encoded_data = f.read()
    encoded_data = encoded_data.split("\n")

def str2hex(str):
    return hex(int(str, 2))

def str2dem(str):
    return int(str, 2)

def hex2bin(h):
    return bin(int(h, 16))

def shift_l(x, n):
    t = str2dem(x) << n
    return bin(t)

# print(huffman_code[202])
# print(bin(huffman_code[202]))3
# print(str2bin("0b" + huffman_code[202]))
# print(str2bin(huffman_code[202][6:]))
# print(len(huffman_code[202])-6)


# concat_data = ""
# for i in int_data:
#     concat_data += huffman_code[i]
#     if(len(concat_data) >= 128) :
#         break
# print(len(concat_data))


# print(len(concat_data[0:128]))
# print(concat_data)
# print(concat_data[0:128])
# print(str2hex(concat_data[0:128]))

concat_data = ''
j = 0
error_n = 0
for i in range(500000):
    concat_data += huffman_code[int_data[i]][6:]
    if(len(concat_data) >= 128):
        if str(str2hex(concat_data[:128]))[2:] != encoded_data[j].lstrip('0'):
            print("error at: ", j)
            print((str2hex(concat_data[:128]))[2:])
            print(encoded_data[j].lstrip('0'))
            error_n += 1
            # break
        concat_data = concat_data[128:]
        j += 1
    # if(j == 2):
    #     print(str2hex(concat_data))
    #     print(len(concat_data))
    # print(str2hex(concat_data))

print("ERROR: ", error_n)
# a = huffman_code[202][6:]
# a_len = len(huffman_code[202])-6

# b = huffman_code[140][6:]
# b_len = len(huffman_code[140])-6

# c = huffman_code[129][6:]

# print(a)
# print(b)
# print(a+b)


# print(str2hex(a))
# print(str2hex(b))
# print(str2hex(a+b+c))

