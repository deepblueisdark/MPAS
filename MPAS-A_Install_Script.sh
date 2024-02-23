#!/bin/bash
start=`date`
START=$(date +"%s")

## Model for Prediction Across Scales (MPAS) Atmosphere (-A) installation
# Download and install required library and data files for MPAS-A.
# Tested in Ubuntu 20.04.4 LTS
# Built in 64-bit system
# Tested with current available libraries on 06/08/2022
# If newer libraries exist edit script paths for changes
#Estimated Run Time

##############################basic package managment#############################
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install gcc gfortran g++ libtool automake autoconf make m4 default-jre default-jdk csh ksh git python3 python3-dev python2 python2-dev mlocate curl cmake

#############################Core Management####################################

export CPU_CORE=$(nproc)                                             #number of available cores on system
export CPU_6CORE="6"
export CPU_HALF=$(($CPU_CORE / 2))                                   #half of availble cores on system
export CPU_HALF_EVEN=$(( $CPU_HALF - ($CPU_HALF % 2) ))              #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

if [ $CPU_CORE -le $CPU_6CORE ]                                  #If statement for low core systems.  Forces computers to only use 2 cores if there are 4 cores or less on the system.
then
  export CPU_HALF_EVEN="2"
else
  export CPU_HALF_EVEN=$(( $CPU_HALF - ($CPU_HALF % 2) ))
fi


echo "##########################################"
echo "Number of cores being used $CPU_HALF_EVEN"
echo "##########################################"

#################################Directory Listing################################
export HOME="/home/modelos/MODELOS/"  ##======================================================>> MUDAR AQUI
export DIR=$HOME/MPAS-A/Libs
mkdir $HOME/MPAS-A
cd $HOME/MPAS-A
mkdir Downloads
mkdir Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH

##############################Downloading Libraries###############################
cd Downloads
wget -c https://github.com/madler/zlib/archive/refs/tags/v1.2.12.tar.gz
wget -c https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_12_2.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.0.tar.gz
wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.0.tar.gz
wget -c https://github.com/pmodels/mpich/releases/download/v4.0.2/mpich-4.0.2.tar.gz
wget -c https://parallel-netcdf.github.io/Release/pnetcdf-1.12.3.tar.gz
wget -c https://github.com/NCAR/ParallelIO/archive/refs/tags/pio2_5_9.tar.gz




####################################Compilers#####################################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran

#IF statement for GNU compiler issue
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]
then
  export fallow_argument=-fallow-argument-mismatch
  export boz_argument=-fallow-invalid-boz
else
  export fallow_argument=
  export boz_argument=
fi


export FFLAGS=$fallow_argument
export FCFLAGS=$fallow_argument



######################################zlib########################################
#Uncalling compilers due to comfigure issue with zlib1.2.12
#With CC & CXX definied ./configure uses different compiler Flags

cd $HOME/MPAS-A/Downloads
tar -xvzf v1.2.12.tar.gz
cd zlib-1.2.12/
CC= CXX= ./configure --prefix=$DIR/grib2 --static
make
make install
#make check

####################################MPICH#########################################
cd $HOME/MPAS-A/Downloads
tar -xvzf mpich-4.0.2.tar.gz
cd mpich-4.0.2/
./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument

make
make install
#make check


export PATH=$DIR/MPICH/bin:$PATH





#############################hdf5 library for netcdf4 functionality###############
#Make file created with half of available cpu cores
#Hard path for MPI added
##################################################################################
cd $HOME/MPAS-A/Downloads
tar -xvzf hdf5-1_12_2.tar.gz
cd hdf5-hdf5-1_12_2


export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib

CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran --enable-parallel --disable-shared
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH


#############################Install Parallel-netCDF##############################
#Make file created with half of available cpu cores
#Hard path for MPI added
##################################################################################

cd $HOME/MPAS-A/Downloads
tar -xvzf pnetcdf-1.12.3.tar.gz
cd pnetcdf-1.12.3
export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx
./configure --prefix=$DIR/grib2
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

export PNETCDF=$DIR/grib2





##############################Install NETCDF C Library############################
# since using parallel cc compiler cc=MPICC
#Make file created with half of available cpu cores
##################################################################################
cd $HOME/MPAS-A/Downloads
tar -xzvf v4.9.0.tar.gz
cd netcdf-c-4.9.0/
export CPPFLAGS=-I$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -ldl"
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-cdf5 --enable-parallel-tests --disable-shared
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF






##############################NetCDF fortran library##############################
# since using parallel cc compiler CC=$MPICC FC=$MPIFC F77=$MPIF77
#Make file created with half of available cpu cores
##################################################################################
cd $HOME/MPAS-A/Downloads
tar -xvzf v4.6.0.tar.gz
cd netcdf-fortran-4.6.0/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz -ldl"
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 ./configure --prefix=$DIR/NETCDF --disable-shared --enable-parallel-tests
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check





#################################PIO##############################################
cd $HOME/MPAS-A/Downloads
tar -xzvf pio2_5_9.tar.gz
cd ParallelIO-pio2_5_9
mkdir pio && cd pio
export PIOSRC=$HOME/MPAS-A/Downloads/ParallelIO-pio2_5_9/


CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 cmake -DNetCDF_C_PATH=$NETCDF -DNetCDF_Fortran_PATH=$NETCDF -DPnetCDF_PATH=$PNETCDF -DHDF5_PATH=$NETCDF -DCMAKE_INSTALL_PREFIX=$DIR/grib2 -DPIO_USE_MALLOC=ON -DCMAKE_VERBOSE_MAKEFILE=1 -DPIO_ENABLE_TIMING=OFF $PIOSRC

make
make install

export PIO=$DIR/grib2

#make check




################################# MPAS-ATMOSPHERE ################################
# USE_PIO2 over PIO1 due to error, shouldn't affect build
##################################################################################
cd $HOME/MPAS-A
git clone https://github.com/MPAS-Dev/MPAS-Model.git
cd MPAS-Model
export MPAS_EXTERNAL_LIBS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I$DIR/NETCDF/include -I$DIR/grib2/include"
make gfortran CORE=init_atmosphere USE_PIO2=true PRECISION=single
make clean CORE=atmosphere USE_PIO2=true PRECISION=single
make gfortran CORE=atmosphere USE_PIO2=true PRECISION=single

##########################  Export PATH and LD_LIBRARY_PATH ######################
cd $HOME

echo "export PATH=$DIR/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc




#####################################BASH Script Finished#########################
end=`date`
END=$(date +"%s")
DIFF=$(($END-$START))
echo "Install Start Time: ${start}"
echo "Install End Time: ${end}"
echo "Install Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
echo "Congratulations! You've successfully installed all required files to run the Model for Prediction Across Scales (MPAS) Atmosphere (-A) installation."
echo "Thank you for using this script"
