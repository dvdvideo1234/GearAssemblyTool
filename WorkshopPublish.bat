:: This is comment

@echo off

set "BinPath=F:\Games\Steam\steamapps\common\GarrysMod\bin"

set  Dir[0]=Gearassembly
set  IDs[0]=384782853

echo Press Crtl+C to terminate !
echo Press a key if you dont want to wait ! 
echo Rinning in %CD%.
echo.  

set "x=0"

:SymLoop
if defined Dir[%x%]  (
    if defined IDs[%x%]  (
    call %BinPath%/gmad.exe create -folder "%CD%/%%Dir[%x%]%%" -out "%CD%/%%Dir[%x%]%%"
    call %BinPath%/gmpublish.exe update -addon "%CD%/%%Dir[%x%]%%.gma" -id "%%IDs[%x%]%%" -changes "Generated by Batch!"
    call del %CD%/%%Dir[%x%]%%.gma
    call echo %%Dir[%x%]%% [%%IDs[%x%]%%] Published
    set /a "x+=1"
    GOTO :SymLoop
  )
)

echo.
echo.
echo Published !
timeout 500
exit