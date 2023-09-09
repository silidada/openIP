# 
# @Author: Haha Chen 
# @Date: 2023-09-09 12:03:53 
# @Last Modified by:   Haha Chen 
# @Last Modified time: 2023-09-09 12:03:53 
# 

with open(r"D:\Users\ChenHaHa\Documents\MyOwn\project\huffman\FPGA\project_2\project_2.sim\sim_1\behav\questa\an_result.txt", "r") as f:
    an_result = f.read()
    an_result = an_result.split("\n")
    an_result = [i.strip() for i in an_result]

# print(an_result)

with open(r"D:\Users\ChenHaHa\Documents\MyOwn\project\huffman\FPGA\project_2\project_2.sim\sim_1\behav\questa\huffman_code.txt", "r") as f:
    huffman_code = f.read()
    huffman_code = huffman_code.split("\n")
    huffman_code_len = [len(i)-6 for i in huffman_code]
    # print(huffman_code_len)

error_cnt = 0
print(len(an_result))
print(len(huffman_code_len))

for i in range(256):
    if an_result[i] == "":
        break
    if int(an_result[i]) == 0:
        print("{} is zero".format(i))
    if huffman_code_len[i] != int(an_result[i]):
        print("error at: ", i)
        error_cnt += 1
        # print(huffman_code_len[i])
        # print(an_result[i])

print("error: ", error_cnt)