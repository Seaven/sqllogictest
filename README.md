## Compile

cd src && make

## Test
1. 查看本机 odbc SYSTEM DATA SOURCES 路径，例如：SYSTEM DATA SOURCES: /etc/odbc.ini，命令：odbcinst -j
2. 在配置中增加 daily 配置，例如：
    [daily]
    Description=MySQL connection to 'daily Doris' database
    DRIVER=MySQL
    DATABASE=information_schema
    SERVER=172.26.92.141
    UID=root
    PWD=
    Port=9032
    Socket=
    charset=UTF8
    OPTION=3
3. 执行测试，命令：bash verify_all_doris.sh daily doris_test 100 /home/disk1/jenkins/workspace/doris_daily_build/doris-sqllogictest/result 。生成Jenkins 报告结果：python3 create_xml.py
