!
!      ******************************************************************
!      *                                                                *
!      * File:          cart1D_InterpolSubface.f90                      *
!      * Author:        Edwin van der Weide                             *
!      * Starting date: 09-23-2004                                      *
!      * Last modified: 03-22-2005                                      *
!      *                                                                *
!      ******************************************************************
!
       subroutine cart1D_InterpolSubface(iBeg, iEnd, jBeg, jEnd, &
                                         nbcVar, cgnsBoco,       &
                                         blockFaceId, coorId,    &
                                         indCoor, ind,           &
                                         bcVarPresent,           &
                                         bcVarArray)
!
!      ******************************************************************
!      *                                                                *
!      * cart1D_InterpolSubface interpolates the prescribed variables   *
!      * in the data set of the given cgns subface onto the subface     *
!      * indicated by iBeg, iEnd, jBeg, jEnd and blockFaceId.           *
!      * This routine performs a 1d cartesian interpolation for the     *
!      * coordinate coorId and it is assumed that there is no           *
!      * variation in the other directions.                             *
!      * The variables in blockPointers are already set.                *
!      *                                                                *
!      ******************************************************************
!
       use BCTypes
       use blockPointers
       use cgnsGrid
       implicit none
!
!      Subroutine arguments
!
       integer(kind=intType), intent(in) :: iBeg, iEnd, jBeg, jEnd
       integer(kind=intType), intent(in) :: nbcVar, cgnsBoco
       integer(kind=intType), intent(in) :: blockFaceId, coorId

       integer(kind=intType), dimension(2,3), intent(in) :: indCoor
       integer(kind=intType), dimension(2,nbcVar), intent(in) :: ind

       real(kind=realType), dimension(iBeg:iEnd,jBeg:jEnd,nbcVar), &
                                            intent(out) :: bcVarArray

       logical, dimension(nbcVar), intent(in) :: bcVarPresent
!
!      Local variables.
!
       integer(kind=intType) :: i, j, k, l, n1, n2, nn, ii
       integer(kind=intType) :: nDim, nPoints, start

       real(kind=realType) :: fact, ww1, ww2, xc

       real(kind=realType), dimension(:),   pointer :: xx
       real(kind=realType), dimension(:,:), pointer :: xf

       character(len=maxStringLen) :: errorMessage

       type(cgnsBcDatasetType), pointer, dimension(:) :: dataSet
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
       ! Set the pointer for dataSet to make the code more readable.

       dataSet => cgnsDoms(nbkGlobal)%bocoInfo(cgnsBoco)%dataSet

       ! Check the number of dimensions of the specified data set.
       ! This should be 1, because a 1d interpolation in radial
       ! direction is performed.

       k    = indCoor(1,coorId)
       l    = indCoor(2,coorId)
       nDim = dataSet(k)%dirichletArrays(l)%nDimensions

       if(nDim > 1) then
         write(errorMessage,101) &
               trim(cgnsDoms(nbkGlobal)%zonename), &
               trim(cgnsDoms(nbkGlobal)%bocoInfo(cgnsBoco)%bocoName)
         call terminate("cart1D_InterpolSubface", errorMessage)
 101     format("Zone",1X,A,", subface",1X,A,": Multidimensional &
                &radially varying data specified. Only 1d data possible")
       endif

       ! Set the pointer for the current coordinate and abbreviate the
       ! number of interpolation points a bit easier.

       xx     => dataSet(k)%dirichletArrays(l)%dataArr
       nPoints = dataSet(k)%dirichletArrays(l)%dataDim(1)

       ! Check if the data is specified for increasing values of
       ! the coordinate.

       do i=2,nPoints
         if(xx(i) < xx(i-1)) exit
       enddo

       if(i <= nPoints) then
         write(errorMessage,102) &
               trim(cgnsDoms(nbkGlobal)%zonename), &
               trim(cgnsDoms(nbkGlobal)%bocoInfo(cgnsBoco)%bocoName)
         call terminate("cart1D_InterpolSubface", errorMessage)
 102     format("Zone",1X,A,", subface",1X,A,": Data should be &
                &specified for increasing coordinate values.")
       endif

       ! Set the pointer for the coordinate of the block face on which
       ! the boundary subface is located.

       select case (blockFaceId)
         case (iMin)
           xf => x(1, :,:,coorId)
         case (iMax)
           xf => x(il,:,:,coorId)
         case (jMin)
           xf => x(:,1, :,coorId)
         case (jMax)
           xf => x(:,jl,:,coorId)
         case (kMin)
           xf => x(:,:,1, coorId)
         case (kMax)
           xf => x(:,:,kl,coorId)
       end select

       ! Compute the factor needed to compute the coordinates in the
       ! original units. The fourth comes from the averaging of the 4
       ! nodal coordinates.

       fact = fourth/cgnsDoms(nbkGlobal)%LRef

       ! Loop over the range of the subface.

       jloop: do j=jBeg,jEnd
         iloop: do i=iBeg,iEnd

           ! Determine the coordinate of the face center. Normally this
           ! is an average of i-1, i, j-1, j, but due to the usage of
           ! the pointer xf and the fact that x originally starts at 0,
           ! an offset of 1 is introduced and thus the average should
           ! be taken of i, i+1, j and j+1.

           xc = fact*(xf(i,j) + xf(i+1,j) + xf(i,j+1) + xf(i+1,j+1))

           ! Determine the interpolation interval and set the
           ! interpolation weights. Take care of the exceptions.

           checkInterpol: if(xc <= xx(1)) then

             ! Coordinate is less than the minimum value specified.
             ! Use constant extrapolation.

             n1  = 1;   n2  = 1
             ww1 = one; ww2 = zero

           else if(xc >= xx(nPoints)) then checkInterpol

             ! Coordinate is larger than the maximum value specified.
             ! Use constant extrapolation.

             n1  = nPoints; n2  = nPoints
             ww1 = one;     ww2 = zero

           else checkInterpol

             ! Coordinate is in the range. Determine the correct
             ! interval using a binary search algorithm.

             ii    = nPoints - 1
             start = 1
             interval: do

               ! Next guess for the interval and determine the new
               ! situation.

               nn = start + ii/2
               if(xc > xx(nn+1)) then

                 ! Coordinate is larger than the upper boundary of the
                 ! current interval. Update the lower boundary.

                 start = nn + 1; ii = ii - 1

               else if(xc >= xx(nn)) then

                 ! This is the correct range. Exit the loop.

                 exit

               endif

               ! Modify ii for the next branch to search.

               ii = ii/2

             enddo interval

             ! xc is in the interval nn, nn+1. Store this and
             ! determine the interpolation weight.

             n1 = nn
             n2 = nn + 1
             ww1 = (xx(nn+1) - xc)/(xx(nn+1) - xx(nn))
             ww2 = one - ww1

           endif checkInterpol

           ! Interpolate the values the values present for this face.

           do nn=1,nbcVar
             if( bcVarPresent(nn) ) then

               ! Easier storage of the indices in the data set.

               k = ind(1,nn)
               l = ind(2,nn)

               ! Interpolate this variable.

               bcVarArray(i,j,nn) =                                 &
                     ww1*dataSet(k)%dirichletArrays(l)%dataArr(n1) &
                   + ww2*dataSet(k)%dirichletArrays(l)%dataArr(n2)
             endif
           enddo

         enddo iloop
       enddo jloop

       end subroutine cart1D_InterpolSubface
