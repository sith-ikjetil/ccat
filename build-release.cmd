echo "Compiling ccat ..."
echo "> using release build <"

fpc -Px86_64 -Twin64 -FE.\build -FU.\build .\src\ccat.pas 
if %ERRORLEVEL% eq 0 {
    echo "> ccat build ok <"
} else {
    echo "> ccat build error <"
}

echo "> build process complete <"