#!/bin/bash

DIRNAME=$(dirname ${0})
MPI_VER=$(echo ${DIRNAME}|egrep -o "omp\-(sys|[0-9\.]+)")
DIR_TUP=$(echo ${DIRNAME}|egrep -o "[0-9\.]+"|xargs)
OS_VER=$(echo ${DIR_TUP}|awk '{print $1}')
OS_BASE=$(echo ${DIRNAME}|egrep -o "(centos|fedora|ubuntu)")
MPI_RELEASE="NONE"


if [ "${MPI_VER}" = "omp-sys" ];then
    PROB_SIZE=$(echo ${DIR_TUP}|awk '{print $2}')
    JOB_TIME=$(echo ${DIR_TUP}|awk '{print $3}')
else
    MPI_RELEASE=$(echo ${DIR_TUP}|awk '{print $2}')
    PROB_SIZE=$(echo ${DIR_TUP}|awk '{print $3}')
    JOB_TIME=$(echo ${DIR_TUP}|awk '{print $4}')
fi
PROC=8

if [ "X${OS_BASE}" = "Xcentos" ];then
    SLURM_PARTITION="cos${OS_VER}"
elif [ "X${OS_BASE}" = "Xubuntu" ];then
    SLURM_PARTITION="u${OS_VER}"
fi

for x in $*;do
   key=$(echo $x|awk -F\: '{print $1}')
   val=$(echo $x|awk -F\: '{print $2}')
   declare $key=$val
done
JOB_PATH=${HOME}/${OS_BASE}/${OS_VER}/${PROB_SIZE}/${JOB_TIME}/$(date +"%F_%H-%M-%S")

#echo """
#MPI_VER=${MPI_VER}
#DIRNAME=${DIRNAME}
#OS_VER=${OS_VER}
#OS_BASE=${OS_BASE}
#PROB_SIZE=${PROB_SIZE}
#JOB_TIME=${JOB_TIME}
#SLURM_PARTITION=${SLURM_PARTITION}
#JOB_PATH=${JOB_PATH}
#"""


mkdir -p ${JOB_PATH}
cat << EOF > ${JOB_PATH}/job.cfg
MPI_VER=${MPI_VER}
DIRNAME=${DIRNAME}
OS_VER=${OS_VER}
OS_BASE=${OS_BASE}
PROB_SIZE=${PROB_SIZE}
JOB_TIME=${JOB_TIME}
SLURM_PARTITION=${SLURM_PARTITION}
EOF

cat << EOF > ${JOB_PATH}/hpcg.dat
HPCG benchmark input file
Sandia National Laboratories; University of Tennessee, Knoxville
${PROB_SIZE} ${PROB_SIZE} ${PROB_SIZE}
${JOB_TIME}
EOF

cp ${HOME}/scripts/run.sh ${JOB_PATH}/
sed -i -e "s#SED_SLURM_PARTITION#${SLURM_PARTITION}#" ${JOB_PATH}/run.sh
sed -i -e "s#SED_JOB_NAME#${PROB_SIZE}_${JOB_TIME}_${MPI_VER}#" ${JOB_PATH}/run.sh
sed -i -e "s#SED_WORKDIR#${JOB_PATH}#" ${JOB_PATH}/run.sh

if [ "X${after}" != "X" ];then
   SLURM_AFTER=" --dependency=afterany:${after}"
fi
echo "sbatch -N ${PROC} ${SLURM_AFTER} ${JOB_PATH}/run.sh"
#sbatch -N ${PROC} ${SLURM_AFTER} ${JOB_PATH}/run.sh
