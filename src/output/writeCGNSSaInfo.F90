!
!      ******************************************************************
!      *                                                                *
!      * File:          writeCGNSSaInfo.F90                             *
!      * Author:        Edwin van der Weide                             *
!      * Starting date: 04-11-2003                                      *
!      * Last modified: 06-29-2005                                      *
!      *                                                                *
!      ******************************************************************
!
       subroutine writeCGNSSaInfo(cgnsInd, cgnsBase)
!
!      ******************************************************************
!      *                                                                *
!      * WriteCGNSSaInfo writes information about the Spalart           *
!      * Allmaras turbulence model to the cgns file.                    *
!      *                                                                *
!      ******************************************************************
!
       use inputPhysics
       use cgnsNames
       use su_cgns
       implicit none
!
!      Subroutine arguments
!
       integer, intent(in) :: cgnsInd, cgnsBase
!
!      Local variables.
!
       integer :: realTypeCGNS, ierr

       real(kind=cgnsRealType) :: val
!
!      Function definition.
!
       integer :: setCGNSRealType
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
#ifdef USE_NO_CGNS

       call terminate("writeCGNSMenterSaInfo", &
                      "Routine should not be called if no cgns support &
                      &is selected.")

#else
       ! Set the cgns real type.

       realTypeCGNS = setCGNSRealType()

       ! Write the info of the turbulence model under the flow equation
       ! set. So move to this location first.

       call cg_goto_f(cgnsInd, cgnsBase, ierr, &
                      "FlowEquationSet_t", 1, "end")
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling cg_goto_f")

       ! Write that the spalart-allmaras model is used.

       call cg_model_write_f("TurbulenceModel_t", &
                             OneEquation_SpalartAllmaras, ierr)
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling cg_model_write_f")

       ! Write the turbulent closure type.

       call cg_model_write_f("TurbulenceClosure_t", EddyViscosity, ierr)
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling cg_model_write_f")

       ! Write the details of the turbulence model under the turbulent
       ! closure type.

       call cg_goto_f(cgnsInd, cgnsBase, ierr, "FlowEquationSet_t", 1,&
                      "TurbulenceClosure_t", 1, "end")
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling cg_goto_f")

       ! Write the value of the turbulent prandtl number.

       val = prandtlTurb
       call cg_array_write_f(cgnsPrandtlTurb, realTypeCGNS, &
                             1, 1, val, ierr)
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling cg_array_write_f")

       ! Indicate that this is a nonDimensional parameter.

       call cg_goto_f(cgnsInd, cgnsBase, ierr, "FlowEquationSet_t", 1,&
                      "TurbulenceClosure_t", 1, "DataArray_t", 1,"end")
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling cg_goto_f")

       call cg_dataclass_write_f(NonDimensionalParameter,ierr)
       if(ierr /= all_ok)                  &
         call terminate("writeCGNSSaInfo", &
                        "Something wrong when calling &
                        &cg_dataclass_write_f")

#endif

       end subroutine writeCGNSSaInfo
