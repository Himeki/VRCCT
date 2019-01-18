@echo off
setlocal enableextensions enabledelayedexpansion
title VRChat Cache Tool
echo Tool Start>"VRCCT-log.txt"
cls

echo Report any issues related to this script to Himeki#2865 on Discord. Please include the "VRCCT-log.txt" from the file location. The log re-generates on each run and will stay small.
echo If you did not download this script from "https://github.com/Himeki/VRCCT/releases" then cease execution of this script immediately^^! The validity of the script cannot be assured.
echo.
echo Description of script:
echo This script will give you options to delete the cache as well as make or remove symbolic links to place the cache on another drive or location. It will also create an INI file to log the current location of the cache for future runs.
echo.
echo.
echo Liability:
echo This script is provided "as is", without warranty of any kind, expressed or implied. You cannot hold us accountable for any claim, damages, or other liability, under any circumstance.
echo.
echo By agreeing to continue the execution of this script. You're agreeing to not hold us accountable for any sort of damages.

echo. >>"VRCCT-log.txt"
echo Log Start >>"VRCCT-log.txt"

:ContinueChoice
echo.
set /p cc=Do you wish to continue executing this script?[Y/N]: 
echo Choice: !cc! >>"VRCCT-log.txt"
if /i "!cc!" EQU "Y" ( goto :Properties )
if /i "!cc!" EQU "N" ( goto :ExitChoice )
REM Catch-all
goto :ContinueChoice

:ExitChoice
cls
echo. >>"VRCCT-log.txt"
echo User Cancled Execution >>"VRCCT-log.txt"
echo Choice: !cc! >>"VRCCT-log.txt"
echo User canceled further execution of script.
pause 
echo Exiting...
goto :ExitTool

REM Do not edit below unless you know what you are doing.
:Properties
set "CacheLoc=!userprofile!\appdata\locallow\VRChat"
set "DefCacheLoc=!userprofile!\appdata\locallow\VRChat"
set "TempCacheLoc=!userprofile!\appdata\locallow\VRCCT-temp"
set "TestMode=0"
echo. >>"VRCCT-log.txt"
echo Main Logging Start >>"VRCCT-log.txt"
echo TestMode: !TestMode! >>"VRCCT-log.txt"
echo Version: 2.0 >>"VRCCT-log.txt"
cls

:CacheLocFileCheck
REM check for ini file, if exists, load path, else skip
if "!TestMode!"=="1" (
    echo Cache Loc: !CacheLoc!
)
if exist "VRCCT.ini" (
    if "!TestMode!"=="1" (
        echo VRCCT.ini Found.
        echo.
    )
    set "LocExist=1"
    set /p CacheLoc=<VRCCT.ini
    goto :PathCheck
)

if not exist "VRCCT.ini" (
    if "!TestMode!"=="1" (
        echo VRCCT.ini Not Found, creating.
        echo.
    )
    set "LocExist=2"
)

:PathCheck
echo. >>"VRCCT-log.txt"
echo PathCheck >>"VRCCT-log.txt"
REM Ask if path edited. If path edited, ask link to path.
echo Make sure you run this tool as administrator. If it is not currently, please close it and do so.
echo.
set /p "PathCheck=Has the cache location been changed without this tool? [Y/N]: "
if /i "!PathCheck!"=="n" (
    cls
    echo path not changed >>"VRCCT-log.txt"
    goto :PathNotChanged
)
if /i "!PathCheck!"=="y" (
    cls
    echo If you have changed the cache location with a symbolic link, this tool can still delete cache or remove the link but requires the exact path.
    echo.
    echo Nothing except logging the path is being done right now.
    echo.
    echo You can type the path or copy the current path from explorer and right click and paste.
    echo.
    set /p "CacheLoc=Enter the current path: "
    echo PathChangedExternal: !CacheLoc! >>"VRCCT-log.txt"
    goto :WriteToIni
)

REM Catch-all
cls
echo Error: Please enter Y or N
goto :PathCheck

:PathNotChanged
if "!LocExist!"=="1" (
    if "!TestMode!"=="1" (
        echo Location exists, path not changed.
        echo. >>"VRCCT-log.txt"
        echo ini exists >>"VRCCT-log.txt"
        timeout /t 2
    )
    goto :UserSelect
)

if "!LocExist!"=="2" (
    if "!TestMode!"=="1" (
        echo Location doesn't exist, path not changed, writing default ini.
        echo. >>"VRCCT-log.txt"
        echo ini does not exist, writing default >>"VRCCT-log.txt"
        timeout /t 2
    )
    echo !CacheLoc!>"VRCCT.ini"
    goto :UserSelect
)

:WriteToIni
REM Write new location to ini file for later runs.
echo !CacheLoc!>"VRCCT.ini"
echo. >>"VRCCT-log.txt"
echo ini written with: !CacheLoc! >>"VRCCT-log.txt"
echo.
echo Operation complete, ini updated
timeout /t 10

:UserSelect
REM Clear cache, mklink, or exit
cls
set USelect=nul
if "!TestMode!"=="1" (
    echo UserSelect.
    echo Cache: !CacheLoc!
    echo DefCache: !DefCacheLoc!
)
echo MENU:
echo 1) Clear Cache
echo 2) Link cache to another location
echo 3) Remove SymLink
echo 4) Exit
echo.
set /p "USelect=Choose one of the above, type the number and press enter: "

if "!USelect!"=="4" (
    echo.
    echo Exiting...
    echo. >>"VRCCT-log.txt"
    echo USel-Exit >>"VRCCT-log.txt"
    goto :ExitTool
)

REM Confirm remove link
if "!USelect!"=="3" (
    echo.
    echo This option will remove the link between the stored folder location and the default VRChat location.
    echo.
    set confirm=null
    set /p "confirm=Is this what you want to do? [Y/N]: "
    if /i "!confirm!"=="y" (
        echo. >>"VRCCT-log.txt"
        echo Usel-Rmlink >>"VRCCT-log.txt"
        goto :UnlinkPaths
    ) else (
        goto :UserSelect
    )
)

REM Confirm symlink.
if "!USelect!"=="2" (
    echo.
    echo This option will set up a link between the folder you choose and the default VRChat storage location, making the computer believe the files are being stored there.
    echo.
    echo It is recommended to delete the cache before creating a link but can be done as is. It will take a while to move the cache.
    echo.
    set confirm=null
    set /p "confirm=Is this what you want to do? [Y/N]: "
    if /i "!confirm!"=="y" (
        REM Only link if cache is set to default.
        if "!CacheLoc!" NEQ "!DefCacheLoc!" (
            cls
            echo.
            echo Cache is not set to default location, please use "Remove SymLink" before trying to set a new path.
            echo.
            echo CurCacheLoc: !CacheLoc! >>"VRCCT-log.txt"
            echo DefCacheLoc: !DefCacheLoc! >>"VRCCT-log.txt"
            timeout /t 20
            goto :UserSelect
        )
        echo. >>"VRCCT-log.txt"
        echo Usel-Mklink >>"VRCCT-log.txt"
        goto :LinkPaths
    ) else (
        goto :UserSelect
    )
)

REM Delete cache folders after confirm
if "!USelect!"=="1" (
    echo This option will delete the cache folders from the current cache location, either default or moved.
    echo.
    set confirm=null
    set /p "confirm=Is this what you want to do? [Y/N]: "
    if /i "!confirm!"=="y" (
        echo. >>"VRCCT-log.txt"
        echo USel-DelCache >>"VRCCT-log.txt"
        goto :DelCache
    ) else (
        goto :UserSelect
    )
)

REM Catch-all
goto :UserSelect

:LinkPaths
REM Link !DefCacheLoc! to entered directory.
cls
echo.
echo This will be the new location the vrchat data is actually stored.
echo.
echo Please type the exact path you want the folder stored in.
echo Recommended to make a folder, then copy the path and right click-paste path into tool.
echo Example: E:\Games\VRChat Cache
echo.
set /p "NewCacheLoc=Enter the new path: "
echo.
echo New folder path will be:
echo !NewCacheLoc!
echo.
echo. >>"VRCCT-log.txt"
echo NewLocEntered: !NewCacheLoc! >>"VRCCT-log.txt"
set confirm=null
set /p "confirm=Is this correct? [Y/N (E to return)]: "
echo Confirm mklink >>"VRCCT-log.txt"
echo !confirm! >>"VRCCT-log.txt"
if /i "!confirm!"=="y" (
    echo mklink-confirm pass >>"VRCCT-log.txt"
    goto :LinkRename
)
if /i "!confirm!"=="n" (
    goto :LinkPaths
)

REM Catch-all
echo returning to Selection
timeout /t 2
goto :UserSelect

:LinkRename
REM Rename VRChat appdata folder to VRCCT-temp
if exist "!DefCacheLoc!" (
    echo.
    echo Creating Temp Directory...
    echo. >>"VRCCT-log.txt"
    echo rename appdata folder >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    rename "!DefCacheLoc!" "VRCCT-temp" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
)
if exist "!DefCacheLoc!" (
    echo rename appdata 2 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    rename "!DefCacheLoc!" "VRCCT-temp" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
)
if exist "!DefCacheLoc!" (
    echo Error-unable to rename >>"VRCCT-log.txt"
    echo.
    echo.
    echo Error: Unable to create temp directory
    echo.
    echo Rename the "VRChat" folder to "VRCCT-temp", then re-run the tool. It is located at:
    echo "!DefCacheLoc!"
    pause
    echo.
    echo Exiting...
    goto :ExitTool
)

:LinkDelay
REM Delay before creating link to free files
echo. >>"VRCCT-log.txt"
echo rename complete - delay start >>"VRCCT-log.txt"
echo Preparing to create link...[Attempt 1/4]
echo Link delay 1 >>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
if exist "!DefCacheLoc!" (
    echo Preparing to create link...[Attempt 2/4]
    echo Link delay 2 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 5 >nul 2>nul
)
if exist "!DefCacheLoc!" (
    echo Preparing to create link...[Attempt 3/4]
    echo Link delay 3 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 10 >nul 2>nul
)
if exist "!DefCacheLoc!" (
    echo Preparing to create link...[Attempt 4/4]
    echo Link delay 4 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 10 >nul 2>nul
)
if exist "!DefCacheLoc!" (
    echo. >>"VRCCT-log.txt"
    echo Link delay failure >>"VRCCT-log.txt"
    echo.
    echo.
    echo Unable to prepare link...
    echo.
    echo Please close the tool then delete the
    echo "!DefCacheLoc!"
    echo folder, and re-run the tool selecting create link again.
    pause
    echo.
    echo Exiting...
    goto ExitTool
)

:LinkCreate
REM Create Directory SymLink
echo. >>"VRCCT-log.txt"
echo Link delay complete - Start mklink >>"VRCCT-log.txt"
echo Creating link...[Attempt 1/4]
echo Link create 1 >>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
mklink /d "!DefCacheLoc!" "!NewCacheLoc!" 2>>"VRCCT-log.txt"
timeout /NOBREAK /t 5 >nul 2>nul
if not exist "!DefCacheLoc!" (
    echo Creating Link...[Attempt 2/4]
    echo Link create 2 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    mklink /d "!DefCacheLoc!" "!NewCacheLoc!" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 5 >nul 2>nul
)
if not exist "!DefCacheLoc!" (
    echo Creating Link...[Attempt 3/4]
    echo Link create 3 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    mklink /d "!DefCacheLoc!" "!NewCacheLoc!" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 10 >nul 2>nul
)
if not exist "!DefCacheLoc!" (
    echo Creating Link...[Attempt 4/4]
    echo Link create 4 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    mklink /d "!DefCacheLoc!" "!NewCacheLoc!" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 10 >nul 2>nul
)
if not exist "!DefCacheLoc!" (
    echo Creating Link - Failed
    echo. >>"VRCCT-log.txt"
    echo Link create - failure >>"VRCCT-log.txt"
    echo Symbolic Link creation failed, please press any key to close the tool then delete the
    echo "!DefCacheLoc!"
    echo folder if it is there and re-run the tool again selecting create link.
    echo Make sure the tool is running as administrator [right click, run as administrator]
    echo. >>"VRCCT-log.txt"
    echo Link create - pausing to exit >>"VRCCT-log.txt"
    pause
    echo Exiting...
    goto :ExitTool
)

:LinkMove
REM Move Temp Files to new Location
echo. >>"VRCCT-log.txt"
echo Mklink complete - start move >>"VRCCT-log.txt"
echo.
echo Moving files...
timeout /NOBREAK /t 1 >nul 2>nul
xcopy "!TempCacheLoc!" "!NewCacheLoc!\" /e /y 2>>"VRCCT-log.txt"
echo copy complete: !NewCacheLoc! >>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul

:LinkCleanup
REM Delete temporary directory
echo. >>"VRCCT-log.txt"
echo start temp cleanup >>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
rmdir /s /q "!TempCacheLoc!" 2>>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
if exist "!TempCacheLoc!" (
    echo Temp delete 2 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    rmdir /s /q "!TempCacheLoc!" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
)
if exist "!TempCacheLoc!" (
    echo Temp delete 3 >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    rmdir /s /q "!TempCacheLoc!" 2>>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
)
if exist "!TempCacheLoc!" (
    echo Temp delete failure >>"VRCCT-log.txt"
    echo.
    echo Unable to delete temporary folder, it is now safe to manually delete:
    echo !TempCacheLoc!
    echo.
    echo Press any key when ready to continue.
    pause >nul 2>nul
)

REM Set cache location and goto ini write
echo. >>"VRCCT-log.txt"
echo cleanup complete >>"VRCCT-log.txt"
set "CacheLoc=!NewCacheLoc!"
echo New CacheLoc set: !CacheLoc! >>"VRCCT-log.txt"
echo.
echo.
echo Link attempt complete.
timeout /t 3
goto :WriteToIni


:UnlinkPaths
cls
REM Remove symlink
if "!CacheLoc!" NEQ "!DefCacheLoc!" (
    echo. >>"VRCCT-log.txt"
    echo unlink - pass default check >>"VRCCT-log.txt"
    timeout /NOBREAK /t 1 >nul 2>nul
    rmdir /s /q "!DefCacheLoc!" 2>>"VRCCT-log.txt"
    echo.
    echo.
    echo Link removed.
    echo Unlink complete >>"VRCCT-log.txt"
    timeout /t 5
    
    :UnlinkMoveCheck
    REM copy files back to default, leave old files as backup. Cannot determine if they have other files/folders safely.
    echo. >>"VRCCT-log.txt"
    echo unlink - move check >>"VRCCT-log.txt"
    echo.
    echo.
    set UnlinkMoveConfirm=null
    set /p "UnlinkMoveConfirm=Would you like to move files from previous location back into the default (Will move ALL files in cache folder. Will NOT delete old files)? [Y/N]: "
    if /i "!UnlinkMoveConfirm!"=="y" (
        echo !UnlinkMoveConfirm! >>"VRCCT-log.txt"
        echo unlink - moving files >>"VRCCT-log.txt"
        echo.
        echo Moving files...
        echo.
        timeout /NOBREAK /t 1 >nul 2>nul
        xcopy "!CacheLoc!\*" "!DefCacheLoc!" /e /i /y 2>>"VRCCT-log.txt"
        timeout /NOBREAK /t 3 >nul 2>nul
        echo.
        echo.
        echo Files copied, old files remain.
        echo Keep as backup or delete manually.
        goto :FinishUnlink
    )
    if /i "!UnlinkMoveConfirm!"=="n" (
        echo !UnlinkMoveConfirm! >>"VRCCT-log.txt"
        echo unlink - not moving files >>"VRCCT-log.txt"
        echo.
        echo Not moving files, files untouched.
        goto :FinishUnlink
    )
    REM Catch-all
    echo unlink - check - unidentified entry >>"VRCCT-log.txt"
    goto :UnlinkMoveCheck
) else (
    echo. >>"VRCCT-log.txt"
    echo unlink - fail default check >>"VRCCT-log.txt"
    echo.
    echo.
    echo Error: Cache is set to default, can not remove symlink.
    timeout /t 10
    goto :UserSelect
    )
)
:FinishUnlink
set "CacheLoc=!DefCacheLoc!"
echo. >>"VRCCT-log.txt"
echo CacheLoc Set: !CacheLoc! >>"VRCCT-log.txt"
goto :WriteToIni

:DelCache
cls
echo.
echo Deleting cache...
timeout /t 5
REM pull location from !CacheLoc! and delete cache folders
echo. >>"VRCCT-log.txt"
echo DelCache Start >>"VRCCT-log.txt"
echo. >>"VRCCT-log.txt"
echo del path1:"!CacheLoc!\vrchat\HTTPCache" >>"VRCCT-log.txt"
echo del path2:"!CacheLoc!\vrchat\VRCHTTPCache" >>"VRCCT-log.txt"
echo del path2:"!CacheLoc!\vrchat\HTTPCache-WindowsPlayer" >>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
del /f /s /q "!CacheLoc!\vrchat\HTTPCache" 2>>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
del /f /s /q "!CacheLoc!\vrchat\VRCHTTPCache" 2>>"VRCCT-log.txt"
timeout /NOBREAK /t 1 >nul 2>nul
del /f /s /q "!CacheLoc!\vrchat\HTTPCache-WindowsPlayer" 2>>"VRCCT-log.txt"
)

echo.
echo.
echo Cache Deleted
echo. >>"VRCCT-log.txt"
echo DelCache Complete >>"VRCCT-log.txt"
timeout /t 3
goto :UserSelect

:ExitTool
echo. >>"VRCCT-log.txt"
echo Exiting Tool >>"VRCCT-log.txt"
timeout /t 3
exit
