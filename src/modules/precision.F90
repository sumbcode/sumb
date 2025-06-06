!
!      ******************************************************************
!      *                                                                *
!      * File:          precision.F90                                   *
!      * Author:        Edwin van der Weide                             *
!      * Starting date: 12-09-2002                                      *
!      * Last modified: 06-25-2005                                      *
!      *                                                                *
!      ******************************************************************
!
       module precision
!
!      ******************************************************************
!      *                                                                *
!      * Definition of the kinds used for the integer and real types.   *
!      * Due to MPI, it is a bit messy to use the compiler options -r8  *
!      * and -r4 and therefore the kind construction is used here,      *
!      * where the precision is set using compiler flags of -d type.    *
!      *                                                                *
!      * This is the only file of the code that should be changed when  *
!      * a user wants single precision instead of double precision. All *
!      * other routines use the definitions in this file whenever       *
!      * possible. If other definitions are used, there is a good       *
!      * reason to do so, e.g. when calling the cgns or MPI functions.  *
!      *                                                                *
!      * The actual types used are determined by compiler flags like    *
!      * -DUSE_LONG_INT and -DUSE_SINGLE_PRECISION. If these are        *
!      * omitted the default integer and double precision are used.     *
!      *                                                                *
!      ******************************************************************
!
!      ******************************************************************
!      *                                                                *
!      * Include the su_mpi module; inside this module it is            *
!      * controlled whether a sequential or a parallel executable is    *
!      * built. For the SUmb sources this is completely transparent,    *
!      * although a completely new build must be performed when a       *
!      * change is made from sequential to parallel and vice versa.     *
!      *                                                                *
!      ******************************************************************
!
       use su_mpi
       implicit none
       save
!
!      ******************************************************************
!      *                                                                *
!      * Definition of the integer type used in the entire code. There  *
!      * might be a more elegant solution to do this, but be sure that  *
!      * compatability with MPI must be guaranteed. Note that dummyInt  *
!      * is a private variable, only used for the definition of the     *
!      * integer type. Note furthermore that the parameters defining    *
!      * the MPI types are integers. This is because of the definition  *
!      * in MPI.                                                        *
!      *                                                                *
!      ******************************************************************
!

#ifdef USE_LONG_INT

       ! Long, i.e. 8 byte, integers are used as default integers

       integer(kind=8), private :: dummyInt
       integer, parameter       :: sumb_integer  = mpi_integer8
       integer, parameter       :: sizeOfInteger = 8

#else

       ! Standard 4 byte integer types are used as default integers.

       integer(kind=4), private :: dummyInt
       integer, parameter       :: sumb_integer  = mpi_integer4
       integer, parameter       :: sizeOfInteger = 4

#endif

!
!      ******************************************************************
!      *                                                                *
!      * Definition of the float type used in the entire code. The      *
!      * remarks mentioned before the integer type definition also      *
!      * apply here.                                                    *
!      *                                                                *
!      ******************************************************************
!

#ifdef USE_SINGLE_PRECISION

       ! Single precision reals are used as default real types.

       real(kind=4), private :: dummyReal
       integer, parameter    :: sumb_real  = mpi_real4
       integer, parameter    :: sizeOfReal = 4

       real(kind=4), private :: dummyCGNSReal

#elif USE_QUADRUPLE_PRECISION

       ! Quadrupole precision reals are used as default real types.
       ! This may not be supported on all platforms.
       ! As cgns does not support quadrupole precision, double
       ! precision is used instead.

       real(kind=16), private :: dummyReal
       integer, parameter     :: sumb_real  = mpi_real16
       integer, parameter     :: sizeOfReal = 16

       real(kind=8), private :: dummyCGNSReal

#else

       ! Double precision reals are used as default real types.

       real(kind=8), private :: dummyReal
       integer, parameter    :: sumb_real   = mpi_real8
       integer, parameter    :: sizeOfReal = 8

       real(kind=8), private :: dummyCGNSReal

#endif

!
!      ******************************************************************
!      *                                                                *
!      * Definition of the porosity type. As this is only a flag to     *
!      * indicate whether or not fluxes must be computed, an integer1   *
!      * is perfectly okay.                                             *
!      *                                                                *
!      ******************************************************************
!
       integer(kind=1), private :: dummyPor
!
!      ******************************************************************
!      *                                                                *
!      * Definition of the cgns periodic type.                          *
!      *                                                                *
!      ******************************************************************
!
       real, private :: dummyCGNSPer
!
!      ******************************************************************
!      *                                                                *
!      * Definition of the kind parameters for the integer and real     *
!      * types.                                                         *
!      *                                                                *
!      ******************************************************************
!
       integer, parameter :: intType      = kind(dummyInt)
       integer, parameter :: porType      = kind(dummyPor)
       integer, parameter :: realType     = kind(dummyReal)
       integer, parameter :: cgnsRealType = kind(dummyCGNSReal)
       integer, parameter :: cgnsPerType  = kind(dummyCGNSPer)
!
!      ******************************************************************
!      *                                                                *
!      * Definition of the reals use by the visualization package PV3.  *
!      * Note that PV3 expects all of its information to be passed back *
!      * as 4-byte (float) reals.                                       *
!      *                                                                *
!      ******************************************************************
!
       integer(kind=4), private :: dummyIntPV3
       real(kind=4),    private :: dummyRealPV3
       integer, parameter       :: intPV3Type  = kind(dummyIntPV3)
       integer, parameter       :: realPV3Type = kind(dummyRealPV3)
!
!      ******************************************************************
!      *                                                                *
!      * Definition of the integer types and their corresponding sizes  *
!      * in a PLOT3D file and corresponding solution file.              *
!      *                                                                *
!      ******************************************************************
!
       integer(kind=4), private :: dummyIntPLOT3D
       integer(kind=4), private :: dummyRecordIntPLOT3D

       integer, parameter :: intPLOT3DType       = kind(dummyIntPLOT3D)
       integer, parameter :: intRecordPLOT3DType = kind(dummyRecordIntPLOT3D)

       integer(kind=intType), parameter :: nBytesPerIntPLOT3D       = 4
       integer(kind=intType), parameter :: nBytesPerRecordIntPLOT3D = 4

       integer, parameter :: sumb_integerPLOT3D       = mpi_integer4
       integer, parameter :: sumb_integerRecordPLOT3D = mpi_integer4
!
!      ******************************************************************
!      *                                                                *
!      * Set the parameter debug, depending on the compiler option.     *
!      *                                                                *
!      ******************************************************************
!
#ifdef DEBUG_MODE
       logical, parameter :: debug = .true.
#else
       logical, parameter :: debug = .false.
#endif

       end module precision
