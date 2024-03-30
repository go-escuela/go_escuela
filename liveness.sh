#!/bin/sh
if ( curl --silent --fail "http://localhost:4000/api" > /dev/null --max-time 10 ) ; then
    echo "Main Health Endpoint - ok"
else
    echo "Main Health Endpoint - Time Out"
    exit 1
fi