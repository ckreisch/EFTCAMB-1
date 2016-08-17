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

!> @file 05_abstract_EFTCAMB.f90
!! This file contains the abstract definition of all the places where EFTCAMB interacts
!! with CAMB. All EFTCAMB models should inherit from this class or the two derived
!! classes contained in 05p2_abstract_EFTCAMB_full.f90 or 05p3_abstract_EFTCAMB_designer.f90


!----------------------------------------------------------------------------------------
!> This module contains the abstract definition of all the places where EFTCAMB interacts
!! with CAMB. All EFTCAMB models should inherit from this class or the two derived
!! classes contained in 05p2_abstract_EFTCAMB_full.f90 or 05p3_abstract_EFTCAMB_designer.f90

!> @author Bin Hu, Marco Raveri

module EFTCAMB_abstract_model

    use precision
    use IniFile
    use EFTCAMB_cache

    implicit none

    !----------------------------------------------------------------------------------------
    !> This is the abstract type for EFTCAMB models. As a rule, when there is a
    !! new model it should be declared as a class inheriting from EFTCAMB_model.
    !! This guarantees maximum performances as well as maximum flexibility.
    type, abstract :: EFTCAMB_model

        integer                       :: parameter_number !< number of parameters of the model.
        character(len=:), allocatable :: name             !< name of the model.
        character(len=:), allocatable :: name_latex       !< latex name of the model.

    contains

        ! initialization of the model:
        procedure :: init                            => EFTCAMBModelInitialize                           !< subroutine that initializes the name and latex name of the model.
        procedure(EFTCAMBModelReadModelSelectionFromFile ), deferred :: read_model_selection             !< subroutine that reads the parameters of the model from file.
        procedure(EFTCAMBModelAllocateModelSelection     ), deferred :: allocate_model_selection         !< subroutine that allocates the model selection.
        procedure(EFTCAMBModelInitModelParameters        ), deferred :: init_model_parameters            !< subroutine taht initializes the model parameters based on the values found in an input array.
        procedure(EFTCAMBModelInitModelParametersFromFile), deferred :: init_model_parameters_from_file  !< subroutine that reads the parameters of the model from file.

        ! utility functions:
        procedure(EFTCAMBModelComputeParametersNumber), deferred :: compute_param_number   !< subroutine that computes the number of parameters of the model.
        procedure(EFTCAMBModelFeedback               ), deferred :: feedback               !< subroutine that prints on the screen feedback information about the model.
        procedure(EFTCAMBModelParameterNames         ), deferred :: parameter_names        !< subroutine that returns the i-th parameter name of the model.
        procedure(EFTCAMBModelParameterNamesLatex    ), deferred :: parameter_names_latex  !< subroutine that returns the i-th parameter name of the model.
        procedure(EFTCAMBModelParameterValues        ), deferred :: parameter_values       !< subroutine that returns the i-th parameter value.
        ! background initialization functions:
        procedure :: initialize_background => EFTCAMBModelInitBackground                   !< subroutine that initializes the background of the model, if needed.
        ! CAMB related procedures:
        procedure(EFTCAMBModelBackgroundEFTFunctions ), deferred :: compute_background_EFT_functions  !< subroutine that computes the value of the background EFT functions at a given time.
        procedure(EFTCAMBModelSecondOrderEFTFunctions), deferred :: compute_secondorder_EFT_functions !< subroutine that computes the value of the second order EFT functions at a given time.
        procedure(EFTCAMBModelComputeDtauda          ), deferred :: compute_dtauda                    !< function that computes dtauda = 1/sqrt(a^2H^2).
        procedure(EFTCAMBModelComputeAdotoa          ), deferred :: compute_adotoa                    !< subroutine that computes adotoa = H and its two derivatives wrt conformal time.
        procedure :: compute_rhoQPQ => EFTCAMBModelComputeRhoQPQ                                      !< subroutine that computes \rho_Q and P_Q. For details refer to the numerical notes.

    end type EFTCAMB_model

    ! ---------------------------------------------------------------------------------------------
    ! EFTCAMB abstract interfaces: these are all the model procedures that the user HAS to override
    ! when writing its own model.
    ! ---------------------------------------------------------------------------------------------

    abstract interface

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that computes the number of parameters of the model.
        subroutine EFTCAMBModelComputeParametersNumber( self )
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)       :: self   !< the base class
        end subroutine EFTCAMBModelComputeParametersNumber

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that reads the parameters of the model from file.
        subroutine EFTCAMBModelReadModelSelectionFromFile( self, Ini )
            use IniFile
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)  :: self   !< the base class
            type(TIniFile)        :: Ini    !< Input ini file
        end subroutine EFTCAMBModelReadModelSelectionFromFile

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that reads the parameters of the model from file.
        subroutine EFTCAMBModelAllocateModelSelection( self )
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)  :: self   !< the base class
        end subroutine EFTCAMBModelAllocateModelSelection

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that reads the parameters of the model from file.
        subroutine EFTCAMBModelInitModelParameters( self, array )
            use precision
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)                                   :: self   !< the base class
            real(dl), dimension(self%parameter_number), intent(in) :: array  !< input array with the values of the parameters.
        end subroutine EFTCAMBModelInitModelParameters

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that reads the parameters of the model from file.
        subroutine EFTCAMBModelInitModelParametersFromFile( self, Ini )
            use IniFile
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)  :: self   !< the base class
            type(TIniFile)        :: Ini    !< Input ini file
        end subroutine EFTCAMBModelInitModelParametersFromFile

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that prints on the screen feedback information about the model.
        subroutine EFTCAMBModelFeedback( self )
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)       :: self   !< the base class
        end subroutine EFTCAMBModelFeedback

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that returns the i-th parameter name of the model.
        subroutine EFTCAMBModelParameterNames( self, i, name )
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)      :: self   !< the base class
            integer     , intent(in)  :: i      !< the index of the parameter
            character(*), intent(out) :: name   !< the output name of the i-th parameter
        end subroutine EFTCAMBModelParameterNames

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that returns the i-th parameter name of the model.
        subroutine EFTCAMBModelParameterNamesLatex( self, i, latexname )
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)      :: self       !< the base class
            integer     , intent(in)  :: i          !< The index of the parameter
            character(*), intent(out) :: latexname  !< the output latex name of the i-th parameter
        end subroutine EFTCAMBModelParameterNamesLatex

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that returns the i-th parameter name of the model.
        subroutine EFTCAMBModelParameterValues( self, i, value )
            use precision
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)  :: self   !< the base class
            integer , intent(in)  :: i      !< The index of the parameter
            real(dl), intent(out) :: value  !< the output value of the i-th parameter
        end subroutine EFTCAMBModelParameterValues

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that computes the value of the background EFT functions at a given time.
        subroutine EFTCAMBModelBackgroundEFTFunctions( self, a, eft_par_cache, eft_cache )
            use precision
            use EFTCAMB_cache
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)                         :: self          !< the base class.
            real(dl), intent(in)                         :: a             !< the input scale factor.
            type(EFTCAMB_parameter_cache), intent(inout) :: eft_par_cache !< the EFTCAMB parameter cache that contains all the physical parameters.
            type(EFTCAMB_timestep_cache ), intent(inout) :: eft_cache     !< the EFTCAMB timestep cache that contains all the physical values.
        end subroutine EFTCAMBModelBackgroundEFTFunctions

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that computes the value of the second order EFT functions at a given time.
        subroutine EFTCAMBModelSecondOrderEFTFunctions( self, a, eft_par_cache, eft_cache )
            use precision
            use EFTCAMB_cache
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)                         :: self          !< the base class.
            real(dl), intent(in)                         :: a             !< the input scale factor.
            type(EFTCAMB_parameter_cache), intent(inout) :: eft_par_cache !< the EFTCAMB parameter cache that contains all the physical parameters.
            type(EFTCAMB_timestep_cache ), intent(inout) :: eft_cache     !< the EFTCAMB timestep cache that contains all the physical values.
        end subroutine EFTCAMBModelSecondOrderEFTFunctions

        ! ---------------------------------------------------------------------------------------------
        !> Function that computes dtauda = 1/sqrt(a^2H^2).
        function EFTCAMBModelComputeDtauda( self, a, eft_par_cache, eft_cache )
            use precision
            use EFTCAMB_cache
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)                         :: self          !< the base class.
            real(dl), intent(in)                         :: a             !< the input scale factor.
            type(EFTCAMB_parameter_cache), intent(inout) :: eft_par_cache !< the EFTCAMB parameter cache that contains all the physical parameters.
            type(EFTCAMB_timestep_cache ), intent(inout) :: eft_cache     !< the EFTCAMB timestep cache that contains all the physical values.
            real(dl)                                     :: EFTCAMBModelComputeDtauda !< the output dtauda
        end function EFTCAMBModelComputeDtauda

        ! ---------------------------------------------------------------------------------------------
        !> Subroutine that computes adotoa = H and its two derivatives wrt conformal time.
        !! Again the interface is slightly complicated for performance reasons.
        subroutine EFTCAMBModelComputeAdotoa( self, a, eft_par_cache, eft_cache )
            use precision
            use EFTCAMB_cache
            import EFTCAMB_model
            implicit none
            class(EFTCAMB_model)                         :: self          !< the base class.
            real(dl), intent(in)                         :: a             !< the input scale factor.
            type(EFTCAMB_parameter_cache), intent(inout) :: eft_par_cache !< the EFTCAMB parameter cache that contains all the physical parameters.
            type(EFTCAMB_timestep_cache ), intent(inout) :: eft_cache     !< the EFTCAMB timestep cache that contains all the physical values.
        end subroutine EFTCAMBModelComputeAdotoa

    ! ---------------------------------------------------------------------------------------------

    end interface

contains

    ! ---------------------------------------------------------------------------------------------
    ! EFTCAMB abstract model implementation: the following are all the procedures that can be
    ! be safely implemented for the abstract class and are not harmful if not overritten.
    ! ---------------------------------------------------------------------------------------------

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that initializes the name and latex name of the model.
    subroutine EFTCAMBModelInitialize( self, name, latexname )

        implicit none

        class(EFTCAMB_model)     :: self      !< the base class
        character(*), intent(in) :: name      !< the name of the function
        character(*), intent(in) :: latexname !< the latex name of the function

        self%name       = TRIM(name)
        self%name_latex = TRIM(latexname)

    end subroutine EFTCAMBModelInitialize

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that initializes the background of the model, if needed.
    subroutine EFTCAMBModelInitBackground( self )

        implicit none

        class(EFTCAMB_model)  :: self   !< the base class

    end subroutine EFTCAMBModelInitBackground

    ! ---------------------------------------------------------------------------------------------
    !> Subroutine that computes \rho_Q and P_Q. For details refer to the numerical notes.
    !! Again the interface is slightly complicated for performance reasons.
    subroutine EFTCAMBModelComputeRhoQPQ( self, a )

        implicit none

        class(EFTCAMB_model)  :: self                      !< the base class
        real(dl), intent(in)  :: a                         !< the input scale factor

    end subroutine EFTCAMBModelComputeRhoQPQ

    ! ---------------------------------------------------------------------------------------------

end module EFTCAMB_abstract_model

!----------------------------------------------------------------------------------------
