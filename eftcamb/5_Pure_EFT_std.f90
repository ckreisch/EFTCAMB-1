!----------------------------------------------------------------------------------------
!
! This file is part of EFTCAMB.
!
! Copyright (C) 2013-2016 by the EFTCAMB authors
!
! The EFTCAMB code is free software;
! You can use it, redistribute it, and/or modify it under the terms
! of the GNU General Public License as published by the Free Software Foundation;
! either version 3 of the License, or (at your option) any later version.
! The full text of the license can be found in the file eftcamb/LICENSE at
! the top level of the EFTCAMB distribution.
!
!----------------------------------------------------------------------------------------

!> @file 5_Pure_EFT_std.f90
!! This file contains the definition of the Pure EFT model in which the EFT is described
!! by six functions of time and w_DE. Please refer to the numerical notes for details.


!----------------------------------------------------------------------------------------
!> This module contains the definition of the Pure EFT model in which the EFT is described
!! by six functions of time and w_DE. Please refer to the numerical notes for details.

!> @author Bin Hu, Marco Raveri

module EFTCAMB_pure_EFT_std

    use precision
    use IniFile
    use EFTCAMB_abstract_parametrizations
    use EFTCAMB_constant_parametrization
    use EFTCAMB_linear_parametrizations
    use EFTCAMB_abstract_model

    implicit none

    !----------------------------------------------------------------------------------------
    !> This is the pure EFT model with the six functions of time and w_DE.
    type, extends ( EFTCAMB_model ) :: EFTCAMB_std_pure_EFT

        ! the pure EFT functions model selection flags:
        integer  :: PureEFTmodelOmega   !< Model selection flag for Pure EFT Omega.
        integer  :: EFTwDE              !< Model selection flag for Pure EFT w DE.
        integer  :: PureEFTmodelGamma1  !< Model selection flag for Pure EFT Gamma1.
        integer  :: PureEFTmodelGamma2  !< Model selection flag for Pure EFT Gamma2.
        integer  :: PureEFTmodelGamma3  !< Model selection flag for Pure EFT Gamma3.
        integer  :: PureEFTmodelGamma4  !< Model selection flag for Pure EFT Gamma4.
        integer  :: PureEFTmodelGamma5  !< Model selection flag for Pure EFT Gamma5.
        integer  :: PureEFTmodelGamma6  !< Model selection flag for Pure EFT Gamma6.

        ! the pure EFT functions:
        class( parametrized_function ), allocatable :: PureEFTOmega    !< The pure EFT function Omega.
        class( parametrized_function ), allocatable :: PureEFTwDE      !< The pure EFT function w_DE.
        class( parametrized_function ), allocatable :: PureEFTGamma1   !< The pure EFT function Gamma1.
        class( parametrized_function ), allocatable :: PureEFTGamma2   !< The pure EFT function Gamma2.
        class( parametrized_function ), allocatable :: PureEFTGamma3   !< The pure EFT function Gamma3.
        class( parametrized_function ), allocatable :: PureEFTGamma4   !< The pure EFT function Gamma4.
        class( parametrized_function ), allocatable :: PureEFTGamma5   !< The pure EFT function Gamma5.
        class( parametrized_function ), allocatable :: PureEFTGamma6   !< The pure EFT function Gamma6.

    contains

        ! initialization of the model:
        procedure :: read_model_selection            => EFTCAMBPureEFTstdReadModelSelectionFromFile  !< subroutine that reads the parameters of the model from file
        procedure :: allocate_model_selection        => EFTCAMBPureEFTstdAllocateModelSelection      !< subroutine that allocates the model selection.
        procedure :: init_model_parameters           => EFTCAMBPureEFTstdInitModelParameters         !< subroutine taht initializes the model parameters based on the values found in an input array.
        procedure :: init_model_parameters_from_file => EFTCAMBPureEFTstdInitModelParametersFromFile !< subroutine that reads the parameters of the model from file.
        ! utility functions:
        procedure :: compute_param_number  => EFTCAMBPureEFTstdComputeParametersNumber    !< subroutine that computes the number of parameters of the model.
        procedure :: feedback              => EFTCAMBPureEFTstdFeedback                   !< subroutine that prints on the screen feedback information about the model.
        procedure :: parameter_names       => EFTCAMBPureEFTstdParameterNames             !< subroutine that returns the i-th parameter name of the model.
        procedure :: parameter_names_latex => EFTCAMBPureEFTstdParameterNamesLatex        !< subroutine that returns the i-th parameter name of the model.
        procedure :: parameter_values      => EFTCAMBPureEFTstdParameterValues            !< subroutine that returns the i-th parameter value.

    end type EFTCAMB_std_pure_EFT

    ! ---------------------------------------------------------------------------------------------

contains

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that reads the parameters of the model from file.
    subroutine EFTCAMBPureEFTstdReadModelSelectionFromFile( self, Ini )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self   !< the base class
        type(TIniFile)              :: Ini    !< Input ini file

        self%PureEFTmodelOmega  = Ini_Read_Int_File( Ini, 'PureEFTmodelOmega'  , 0 )
        self%EFTwDE             = Ini_Read_Int_File( Ini, 'EFTwDE'             , 0 )
        self%PureEFTmodelGamma1 = Ini_Read_Int_File( Ini, 'PureEFTmodelGamma1' , 0 )
        self%PureEFTmodelGamma2 = Ini_Read_Int_File( Ini, 'PureEFTmodelGamma2' , 0 )
        self%PureEFTmodelGamma3 = Ini_Read_Int_File( Ini, 'PureEFTmodelGamma3' , 0 )
        self%PureEFTmodelGamma4 = Ini_Read_Int_File( Ini, 'PureEFTmodelGamma4' , 0 )
        self%PureEFTmodelGamma5 = Ini_Read_Int_File( Ini, 'PureEFTmodelGamma5' , 0 )
        self%PureEFTmodelGamma6 = Ini_Read_Int_File( Ini, 'PureEFTmodelGamma6' , 0 )

    end subroutine EFTCAMBPureEFTstdReadModelSelectionFromFile

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that allocates the model selection.
    subroutine EFTCAMBPureEFTstdAllocateModelSelection( self )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self   !< the base class

        ! allocate Omega:
        if ( allocated(self%PureEFTOmega) ) deallocate(self%PureEFTOmega)
        select case ( self%PureEFTmodelOmega )
            case(0)
                allocate( parametrized_function::self%PureEFTOmega )
            case(1)
                allocate( constant_parametrization::self%PureEFTOmega )
            case(2)
                allocate( linear_parametrization::self%PureEFTOmega )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelOmega =', self%PureEFTmodelOmega
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate wDE:
        if ( allocated(self%PureEFTwDE) ) deallocate(self%PureEFTwDE)
        select case ( self%EFTwDE )
            case(0)
                allocate( parametrized_function::self%PureEFTwDE )
            case(1)
                allocate( constant_parametrization::self%PureEFTwDE )
            case default
                write(*,'(a,I3)') 'No model corresponding to EFTwDE =', self%EFTwDE
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate Gamma1:
        if ( allocated(self%PureEFTGamma1) ) deallocate(self%PureEFTGamma1)
        select case ( self%PureEFTmodelGamma1 )
            case(0)
                allocate( parametrized_function::self%PureEFTGamma1 )
            case(1)
                allocate( constant_parametrization::self%PureEFTGamma1 )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelGamma1 =', self%PureEFTmodelGamma1
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate Gamma2:
        if ( allocated(self%PureEFTGamma2) ) deallocate(self%PureEFTGamma2)
        select case ( self%PureEFTmodelGamma2 )
            case(0)
                allocate( parametrized_function::self%PureEFTGamma2 )
            case(1)
                allocate( constant_parametrization::self%PureEFTGamma2 )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelGamma2 =', self%PureEFTmodelGamma2
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate Gamma3:
        if ( allocated(self%PureEFTGamma3) ) deallocate(self%PureEFTGamma3)
        select case ( self%PureEFTmodelGamma3 )
            case(0)
                allocate( parametrized_function::self%PureEFTGamma3 )
            case(1)
                allocate( constant_parametrization::self%PureEFTGamma3 )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelGamma3 =', self%PureEFTmodelGamma3
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate Gamma4:
        if ( allocated(self%PureEFTGamma4) ) deallocate(self%PureEFTGamma4)
        select case ( self%PureEFTmodelGamma4 )
            case(0)
                allocate( parametrized_function::self%PureEFTGamma4 )
            case(1)
                allocate( constant_parametrization::self%PureEFTGamma4 )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelGamma4 =', self%PureEFTmodelGamma4
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate Gamma5:
        if ( allocated(self%PureEFTGamma5) ) deallocate(self%PureEFTGamma5)
        select case ( self%PureEFTmodelGamma5 )
            case(0)
                allocate( parametrized_function::self%PureEFTGamma5 )
            case(1)
                allocate( constant_parametrization::self%PureEFTGamma5 )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelGamma5 =', self%PureEFTmodelGamma5
                write(*,'(a)')    'Please select an appropriate model.'
        end select
        ! allocate Gamma6:
        if ( allocated(self%PureEFTGamma6) ) deallocate(self%PureEFTGamma6)
        select case ( self%PureEFTmodelGamma6 )
            case(0)
                allocate( parametrized_function::self%PureEFTGamma6 )
            case(1)
                allocate( constant_parametrization::self%PureEFTGamma6 )
            case default
                write(*,'(a,I3)') 'No model corresponding to PureEFTmodelGamma6 =', self%PureEFTmodelGamma6
                write(*,'(a)')    'Please select an appropriate model.'
        end select

        ! initialize the names:
        call self%PureEFTOmega%init ( 'EFTOmega' , '\Omega'       )
        call self%PureEFTwDE%init   ( 'EFTw'     , 'w'            )
        call self%PureEFTGamma1%init( 'EFTGamma1', '\gamma^{(1)}' )
        call self%PureEFTGamma2%init( 'EFTGamma2', '\gamma^{(2)}' )
        call self%PureEFTGamma3%init( 'EFTGamma3', '\gamma^{(3)}' )
        call self%PureEFTGamma4%init( 'EFTGamma4', '\gamma^{(4)}' )
        call self%PureEFTGamma5%init( 'EFTGamma5', '\gamma^{(5)}' )
        call self%PureEFTGamma6%init( 'EFTGamma6', '\gamma^{(6)}' )

    end subroutine EFTCAMBPureEFTstdAllocateModelSelection

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine taht initializes the model parameters based on the values found in an input array.
    subroutine EFTCAMBPureEFTstdInitModelParameters( self, array )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self   !< the base class
        real(dl), dimension(self%parameter_number), intent(in) :: array  !< input array with the values of the parameters.

    end subroutine EFTCAMBPureEFTstdInitModelParameters

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that reads the parameters of the model from file.
    subroutine EFTCAMBPureEFTstdInitModelParametersFromFile( self, Ini )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self   !< the base class
        type(TIniFile)              :: Ini    !< Input ini file

        call self%PureEFTOmega%init_from_file ( Ini )
        call self%PureEFTwDE%init_from_file   ( Ini )
        call self%PureEFTGamma1%init_from_file( Ini )
        call self%PureEFTGamma2%init_from_file( Ini )
        call self%PureEFTGamma3%init_from_file( Ini )
        call self%PureEFTGamma4%init_from_file( Ini )
        call self%PureEFTGamma5%init_from_file( Ini )
        call self%PureEFTGamma6%init_from_file( Ini )

    end subroutine EFTCAMBPureEFTstdInitModelParametersFromFile

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that computes the number of parameters of the model.
    subroutine EFTCAMBPureEFTstdComputeParametersNumber( self )

        implicit none

        class(EFTCAMB_std_pure_EFT)  :: self   !< the base class

        self%parameter_number = 0
        self%parameter_number = self%parameter_number +self%PureEFTOmega%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTwDE%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTGamma1%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTGamma2%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTGamma3%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTGamma4%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTGamma5%parameter_number
        self%parameter_number = self%parameter_number +self%PureEFTGamma6%parameter_number

    end subroutine EFTCAMBPureEFTstdComputeParametersNumber

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that prints on the screen feedback information about the model.
    subroutine EFTCAMBPureEFTstdFeedback( self )

        implicit none

        class(EFTCAMB_std_pure_EFT)  :: self   !< the base class

        write(*,*)
        write(*,'(a,a)')    '   Model               =  ', self%name
        write(*,'(a,I3)')   '   Number of params    ='  , self%parameter_number
        ! print model functions informations:
        write(*,*)
        if ( self%PureEFTmodelOmega  /= 0 ) write(*,'(a,I3)') '   PureEFTmodelOmega   =', self%PureEFTmodelOmega
        if ( self%EFTwDE             /= 0 ) write(*,'(a,I3)') '   EFTwDE              =', self%EFTwDE
        if ( self%PureEFTmodelGamma1 /= 0 ) write(*,'(a,I3)') '   PureEFTmodelGamma1  =', self%PureEFTmodelGamma1
        if ( self%PureEFTmodelGamma2 /= 0 ) write(*,'(a,I3)') '   PureEFTmodelGamma2  =', self%PureEFTmodelGamma2
        if ( self%PureEFTmodelGamma3 /= 0 ) write(*,'(a,I3)') '   PureEFTmodelGamma3  =', self%PureEFTmodelGamma3
        if ( self%PureEFTmodelGamma4 /= 0 ) write(*,'(a,I3)') '   PureEFTmodelGamma4  =', self%PureEFTmodelGamma4
        if ( self%PureEFTmodelGamma5 /= 0 ) write(*,'(a,I3)') '   PureEFTmodelGamma5  =', self%PureEFTmodelGamma5
        if ( self%PureEFTmodelGamma6 /= 0 ) write(*,'(a,I3)') '   PureEFTmodelGamma6  =', self%PureEFTmodelGamma6
        write(*,*)

        call self%PureEFTOmega%feedback()
        call self%PureEFTwDE%feedback()
        call self%PureEFTGamma1%feedback()
        call self%PureEFTGamma2%feedback()
        call self%PureEFTGamma3%feedback()
        call self%PureEFTGamma4%feedback()
        call self%PureEFTGamma5%feedback()
        call self%PureEFTGamma6%feedback()

    end subroutine EFTCAMBPureEFTstdFeedback

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that returns the i-th parameter name of the model
    subroutine EFTCAMBPureEFTstdParameterNames( self, i, name )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self   !< the base class
        integer     , intent(in)    :: i      !< the index of the parameter
        character(*), intent(out)   :: name   !< the output name of the i-th parameter

    end subroutine EFTCAMBPureEFTstdParameterNames

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that returns the i-th parameter name of the model
    subroutine EFTCAMBPureEFTstdParameterNamesLatex( self, i, latexname )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self       !< the base class
        integer     , intent(in)    :: i          !< The index of the parameter
        character(*), intent(out)   :: latexname  !< the output latex name of the i-th parameter

    end subroutine EFTCAMBPureEFTstdParameterNamesLatex

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that returns the i-th parameter name of the model
    subroutine EFTCAMBPureEFTstdParameterValues( self, i, value )

        implicit none

        class(EFTCAMB_std_pure_EFT) :: self   !< the base class
        integer , intent(in)        :: i      !< The index of the parameter
        real(dl), intent(out)       :: value  !< the output value of the i-th parameter

    end subroutine EFTCAMBPureEFTstdParameterValues

    ! ---------------------------------------------------------------------------------------------

end module EFTCAMB_pure_EFT_std

!----------------------------------------------------------------------------------------
