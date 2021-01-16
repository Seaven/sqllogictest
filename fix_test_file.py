import os,glob 

file = glob.glob('wr_fix_all.final.result')
#print(file)
f = open(file[0],"r")
for line in f.readlines():
    result = line[:4]
    if result == 'FAIL':
        path = "result/" + line[16:-1]
        #print(path)
        fix_path = "doris_test/" + line[16:-1]
        f = open(path,'r')
        wrong_line = []
        for line in f.readlines():
            if line.startswith('doris_test'):
                str_list = line.split(':')
                number = str_list[1]
                wrong_line.append(number)
        f.close()
        wrong_line = list(map(int,wrong_line))
        f2 = open(fix_path,'r')
        del_line = []
        test_list = []
        for line in f2.readlines():
            test_list.append(line[:-1])
        for index in wrong_line:
            number = index - 3
            while test_list[number] != '----':
                number = number - 1
            end = number + 1
            while len(test_list[number]):
                number = number - 1
            start = number + 2
            for i in range(start,end+1):
                del_line.append(i)
        #print(del_line)
        tmp_str = ""
        for i in del_line:
            tmp_str = tmp_str + str(i) + 'd;'
        cmd = "sed -i \'" + tmp_str[:-1] + "\' " + fix_path
        if tmp_str != "":
            print(cmd)
            #os.system(cmd)
            print("----------%s fix end-------" %fix_path)
