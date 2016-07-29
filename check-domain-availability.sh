#!/bin/bash

#checks site availability
#TODO: add ping checking support and showing results by checking types

function ok {
    if [ $2 -ne 0 ] ; then echo -e "\e[32m[ok]\e[0m Host $1 available"; fi
    echo "Response code is:  $2" 
    exit 0;
}

function down  {
    echo -ne "\e[31m[DOWN]\e[0m Host $1 is "
    if [ $3 -eq 0 ]; then  echo "DOWN";
    else echo "unavailable";  fi
    echo ""
    if [ $4 -ne 0 ]  ; then echo "Error occurred getting URL $1"; fi
    if [ $4 -eq 6 ]  ; then echo "Unable to resolve host"; fi
    if [ $4 -eq 7 ]  ; then echo "Unable to connect to host"; fi
    if [ $2 -ne 0 ] ; then echo "Response code is:  $2"; fi
    exit 1;
}

function check {
    response=$(curl -w %{http_code}  --silent --output /dev/null $1)
    answer=$( dig $1 +nostats +noanswer +noquestion | grep -i -oP 'ANSWER:\s(\d)' | awk '{print $2 }')

    #response code hack
    if [ $response -eq 000 ]; then response=$(expr $response + 0); fi
    
    if [ $response -ge 200 ] && [ $response -le 308 ]; then
        ok $1 $response
    elif [ $answer -gt 0 ]; then
        ok $1 $response
    else
        $(curl --silent -o - $1) #checking curl response code
        down $1 $response $answer $?
    fi
}
check $1;
