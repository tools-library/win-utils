@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION



:PROCESS_CMD
    SET "utility_folder=%~dp0"
    SET "utility_software_folder=%utility_folder%software"
    SET "utility_sfx=%utility_folder%software.exe"

    SET help_arg=false
    SET pack_arg=false
    SET unpack_arg=false

    SET first_arg=%1
    IF  [%first_arg%] EQU [-h]       SET help_arg=true
    IF  [%first_arg%] EQU [--help]   SET help_arg=true
    IF  [%first_arg%] EQU [--pack]   SET pack_arg=true
    IF  [%first_arg%] EQU [--unpack] SET unpack_arg=true

    IF  [%help_arg%] EQU [true] (
        CALL :SHOW_HELP
    ) ELSE (
        IF  [%pack_arg%] EQU [true]  (
            CALL :PACK
        ) ELSE (
            IF  [%unpack_arg%] EQU [true]  (
                CALL :UNPACK
            ) ELSE (
                CALL :MAIN %*
                IF !ERRORLEVEL! NEQ 0 (
                    EXIT /B !ERRORLEVEL!
                )
            )
        )
    )

    REM All changes to variables within this script, will have local scope. Only
    REM variables specified in the following block can propagates to the outside
    REM world (For example, a calling script of this script).
    ENDLOCAL & (
        SET "TOOLSET_CECHO_PATH=%utility_software_folder%"
        SET "PATH=%PATH%"
    )
EXIT /B 0



:MAIN
    CALL :UNPACK

    REM Check if the 'utility_software_folder' is not already in system path. If
    REM not, insert it.
    IF EXIST "%windir%/SysWOW64" (SET system_arch=x64) ELSE (SET system_arch=x32)
    IF "!PATH:%utility_software_folder%\%system_arch%=!" EQU "%PATH%" (
        SET "PATH=%utility_software_folder%\%system_arch%;%PATH%"
        CALL :SHOW_INFO "Utility added to system path."
    )
EXIT /B 0



:PACK
    IF EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Packing utility files."

        WHERE 7z >nul 2>nul
        IF !ERRORLEVEL! NEQ 0 CALL "%~dp0..\7zip\setup.cmd" --unpack

        "%~dp0..\7zip\software\7z.exe" u -uq0 -mx9 -sfx "!utility_sfx!" "!utility_software_folder!"
    )
EXIT /B 0

:UNPACK
    IF NOT EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Unpacking utility files."
        CALL "!utility_sfx!" -y -o"!utility_folder!"
    )
EXIT /B 0



:SHOW_INFO
    WHERE cecho >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        cecho {olive}[TOOLSET - CECHO]{default} INFO: %~1{\n}
    ) ELSE (
        echo [TOOLSET - CECHO] INFO: %~1
    )
EXIT /B 0

:SHOW_ERROR
    WHERE cecho >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        cecho {olive}[TOOLSET - CECHO]{red} ERROR: %~1 {default} {\n}
    ) ELSE (
        echo [TOOLSET - CECHO] ERROR: %~1
    )
EXIT /B 0



:SHOW_HELP
    SET "script_name=%~n0%~x0"
    ECHO #######################################################################
    ECHO #                                                                     #
    ECHO #                      T O O L   S E T U P                            #
    ECHO #                                                                     #
    ECHO #             'CECHO' is an enhanced command line like                #
    ECHO #             'echo' utility, but with color support.                 #
    ECHO #                                                                     #
    ECHO #             Website https://www.codeproject.com/Articles/           #
    ECHO #                     17033/Add-Colors-to-Batch-Files                 #
    ECHO #                                                                     #
    ECHO #             After running the %SCRIPT_NAME%, the tool will be           #
    ECHO #             available in the system path.                           #
    ECHO #                                                                     #
    ECHO # TOOL   : CECHO                                                      #
    ECHO # VERSION: 2.0                                                        #
    ECHO # ARCH   : x64 and x32                                                #
    ECHO #                                                                     #
    ECHO # USAGE:                                                              #
    ECHO #     %SCRIPT_NAME% [-h^|--help^|--pack^|--unpack]                           #
    ECHO #                                                                     #
    ECHO # EXAMPLES:                                                           #
    ECHO #     %script_name%                                                       #
    ECHO #     %script_name% -h                                                    #
    ECHO #     %script_name% --pack                                                #
    ECHO #                                                                     #
    ECHO # ARGUMENTS:                                                          #
    ECHO #     -h^|--help    Print this help and exit.                          #
    ECHO #                                                                     #
    ECHO #     --pack    Pack the content of the software folder in one        #
    ECHO #         self-extract executable called 'software.exe'.              #
    ECHO #                                                                     #
    ECHO #     --unpack    Unpack the self-extract executable 'software.exe'   #
    ECHO #         to the software folder.                                     #
    ECHO #                                                                     #
    ECHO # EXPORTED ENVIRONMENT VARIABLES:                                     #
    ECHO #     TOOLSET_CECHO_PATH    Absolute path where this tool is located. #
    ECHO #                                                                     #
    ECHO #     PATH    This tool will export all local changes that it made to #
    ECHO #         the path's environment variable.                            #
    ECHO #                                                                     #
    ECHO #     The environment variables will be exported only if this tool    #
    ECHO #     executes without any error.                                     #
    ECHO #                                                                     #
    ECHO #######################################################################
EXIT /B 0
