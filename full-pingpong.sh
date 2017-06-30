#!/bin/bash
# Example usage: ./full-pingpong.sh | grep -e ' 512 ' -e NODES -e usec


mpiversion=`ls /opt/intel/impi/`
source /opt/intel/impi/$mpiversion/bin64/mpivars.sh
for NODE in `cat ~/nodenames.txt`; \
    do for NODE2 in `cat ~/nodenames.txt`; \
        do echo '##################################################' && \
            echo NODES: $NODE, $NODE2 && \
            echo '##################################################' && \
            /opt/intel/impi/$mpiversion/bin64/mpirun \
            -hosts $NODE,$NODE2 -ppn 1 -n 2 \
            -env I_MPI_FABRICS=shm:dapl \
            -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 \
            -env I_MPI_DYNAMIC_CONNECTION=0 /opt/intel/impi/$mpiversion/bin64/IMB-MPI1 pingpong; \
        done; \
    done