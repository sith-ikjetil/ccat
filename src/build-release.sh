#!/bin/bash
#: Title       : build-release.sh
#: Date        : 2020-12-25
#: Author      : Kjetil Kristoffer Solberg <post@ikjetil.no>
#: Version     : 1.0
#: Description : Builds ccat.
error_message=""

echo "Compiling ccat ..."
echo "> using release build <"

fpc ./ccat.pas
if [[ $? -eq 0 ]]
then
    echo "> ccat build ok <"
else
    echo "> ccat build error <"
    error_message="with errors "
fi

echo "> build process complete" $error_message "<"
