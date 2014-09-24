#!/bin/bash
#SBATCH --ntasks-per-node=8
#SBATCH --workdir=SED_WORKDIR
#SBATCH --job-name=SED_JOB_NAME
#SBATCH --partition=SED_SLURM_PARTITION

. job.cfg

if [[ ${MPI_VER} =~ omp ]];then
    if [ ${MPI_VER} == omp-sys ];then
        MPI_PATH=/usr/lib64/openmpi
    else
        MPI_NR=$(echo ${MPI_VER} |egrep -o "[0-9\.]+")
        MPI_PATH=/usr/local/openmpi/${MPI_NR}/
    fi
else 
    echo "unrecogniced mpi version '${MPI_VER}'"
    exit 1
fi
echo "MPI_PATH=${MPI_PATH}" >> job.cfg
# ENV
BASE_PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
export PATH=${MPI_PATH}/bin:${BASE_PATH}
export LD_LIBRARY_PATH=${MPI_PATH}/lib:/usr/local/lib
# \ENV


START_TIME=$(date +%s)
echo "## $(date +'%F %H:%M:%S') Start mpirun with '${PROB_SIZE}^3 in ${JOB_TIME}sec'"
mpirun --mca btl "self,openib"  /chome/cluser/hpcg-2.4/cos${OS_VER}_${MPI_VER}/bin/xhpcg
EC=$?
echo "## $(date +'%F %H:%M:%S') Job ends"
if [ ${EC} -eq 0 ];then
    END_TIME=$(date +%s)
    WALL_CLOCK=$((${END_TIME}-${START_TIME}))
    echo "WALL_CLOCK=${WALL_CLOCK}" >> job.cfg
    eval_hpcg.py .
fi

