!
!      ******************************************************************
!      *                                                                *
!      * File:          MPI_Wait.f90                                    *
!      * Author:        Edwin van der Weide                             *
!      * Starting date: 09-07-2021                                      *
!      * Last modified: 09-07-2021                                      *
!      *                                                                *
!      ******************************************************************
!
       subroutine MPI_Wait(request, status, error)
!
!      ******************************************************************
!      *                                                                *
!      * The program should be such that no point to point              *
!      * communication takes place to the processor itself and thus     *
!      * MPI_Wait is never called in sequential mode.                   *
!      *                                                                *
!      ******************************************************************
!
       implicit none
!
!      Subroutine arguments
!
       integer               :: request, error
       integer, dimension(*) :: status
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
       call su_mpi_terminate("MPI_Wait", &
                             "The routine MPI_Wait should not be &
                             &called in sequential mode")

       end subroutine MPI_Wait
