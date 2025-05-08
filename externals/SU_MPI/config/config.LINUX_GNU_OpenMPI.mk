#      ******************************************************************
#      *                                                                *
#      * File:          config.LINUX_GNU_OpenMPI.mk                     *
#      * Author:        Edwin van der Weide                             *
#      * Starting date: 05-08-2025                                      *
#      * Last modified: 05-08-2025                                      *
#      *                                                                *
#      ******************************************************************

#      ******************************************************************
#      *                                                                *
#      * Description: Defines the compiler settings and other commands  *
#      *              to have "make" function correctly. This file      *
#      *              defines the settings for a parallel Linux         *
#      *              executable in combination with OpenMPI. Assumed   *
#      *              is that mpif90 and mpicc are based on the         *
#      *              gfortran and gcc compilers, respectively.         *
#      *                                                                *
#      ******************************************************************

#      ==================================================================

#      ******************************************************************
#      *                                                                *
#      * Possibly overrule the make command to allow for parallel make. *
#      *                                                                *
#      ******************************************************************

MAKE = make -j 2

#      ******************************************************************
#      *                                                                *
#      * F90 and C compiler definitions.                                *
#      *                                                                *
#      ******************************************************************

FF90 = mpif90
CC   = mpicc

#      ******************************************************************
#      *                                                                *
#      * Compiler flags. It is assumed that mpif90 is based on the      *
#      * gfortran compiler and mpicc on the gcc compiler.               *
#      *                                                                *
#      ******************************************************************

COMMAND_SEARCH_PATH_MODULES = -I

FF90_GEN_FLAGS = -DUSE_MPI_INCLUDE_FILE
CC_GEN_FLAGS   =

FF90_OPTFLAGS   = -O2
CC_OPTFLAGS = -O2

#F90_DEBUGFLAGS = -g -implicitnone -DDEBUG_MODE
#CC_DEBUGFLAGS   = -g -Wall -pedantic -DDEBUG_MODE

FF90_FLAGS = $(FF90_GEN_FLAGS) $(FF90_OPTFLAGS) $(FF90_DEBUGFLAGS)
CC_FLAGS   = $(CC_GEN_FLAGS)   $(CC_OPTFLAGS)   $(CC_DEBUGFLAGS)

#      ******************************************************************
#      *                                                                *
#      * Archiver and archiver flags.                                   *
#      *                                                                *
#      ******************************************************************

AR       = ar
AR_FLAGS = -rvs
