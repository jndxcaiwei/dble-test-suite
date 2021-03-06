#!/bin/bash
dble_version=$1

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}/../../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
ssh root@behave "cd /var/lib/go-agent/pipelines/autotest-dble-${dble_version}/behave_dble;behave --stop -D dble_conf=sql_cover_sharding features/setup.feature;chown -R go:go dble_conf/sql_cover_sharding;chown -R go:go logs"

#compile multiquery code
cd ${DIR} && make clean && make

#run multiquery cases
cd ${DIR} && ./multiQuery.o > curr.output 2>&1

#do result compare
echo "compare multiQuery's output with stand: diff -wy curr.output multiQuery.output"
asExpect=$( diff -wq curr.output multiQuery.output )
if [[ $? -eq 0 ]]; then
    echo "test result is same with std_result, case pass !"
else
    echo ${asExpect}
fi

#save logs for ci artifacts
scp -r root@dble-1:/opt/dble/logs ${DIR}/dble_logs
mv ${DIR}/curr.output ${DIR}/dble_logs/
