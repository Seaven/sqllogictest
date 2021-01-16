import glob
from junit_xml import TestSuite, TestCase

file = glob.glob('doris_test.list.split.final.result')
print(file)
for tmp_file in file:
    f = open(tmp_file,"r")
    for line in f.readlines():
        result = line[0:4]
        name_list = line[5:-6].split('/')
        actul_name = name_list[1]
        model_name = '.'.join(name_list)
        #test_cases = TestCase(actul_name, model_name , 123.345, 'I am stdout!', 'I am stderr!')
        test_cases = TestCase('test', model_name , 123.345, 'I am stdout!', 'I am stderr!')
        if result == 'FAIL':
            result_file = 'result/'+line[16:-1]
            print(result_file) 
            failure_info = open(result_file).read()
            test_cases.add_failure_info(failure_info)
        #test_cases = [TestCase(model_name , 123.345, 'I am stdout!', 'I am stderr!')]
        ts = TestSuite("my test suite", [test_cases])
        with open('xml_result/'+model_name+'.xml', 'w') as f2:
            TestSuite.to_file(f2, [ts], prettyprint=False)
        f2.close()
    f.close()
