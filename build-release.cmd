 @ECHO OFF

echo Compiling ccat ...
echo ^> using debug build ^<

fpc -Px86_64 -Twin64 -FE.\build -FU.\build .\src\ccat.pas 
if %ERRORLEVEL% equ 0 (
    echo ^> ccat build ok ^<
) else (
    echo ^> ccat build error ^<
)

echo ^> build process complete ^<