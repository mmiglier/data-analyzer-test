#!/bin/bash

# DEBUG="on"
MAXITER=200000

RESULTSFILE=/tmp/`date +%Y%m%d-%H%M%S`.txt
if [[ $DEBUG ]] ; then
  RESULTSFILE=/tmp/debug.txt
  rm $RESULTSFILE
fi

echo "Waiting for data analyzer to be ready"
until $(curl --output /dev/null --silent --head --fail http://data-analyzer:8175/queries); do
    printf '.'
    sleep 5
done

curl -sS --fail --data-urlencode "action=update" --data-urlencode "queryBody=clear all" data-analyzer:8175/kb > /dev/null
i=0
while [ $i -lt $MAXITER ]
do
  ts=$(date +%s%N)
  curl -G -sS --fail --data-urlencode 'query=
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX ex: <http://example.org#>
    SELECT (COUNT (*) as ?count)
    WHERE
    {
      ?s rdf:type ex:Person ;
        ex:sonOf ?p .
      ?p rdf:type ex:Person .
    }
    ' data-analyzer:8175/kb > /dev/null
  tt=$((($(date +%s%N) - $ts)/1000000))
  echo $[5*$i],$tt >> $RESULTSFILE
  i=$[$i+1]
  curl -sS --fail --data-urlencode "action=update" --data-urlencode 'queryBody=
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX ex: <http://example.org#>
  INSERT DATA
  {
    <http://person#'${i}'> rdf:type ex:Person .
    <http://person#'${i}'> ex:sonOf <http://person#'$[$i+1]'> .
    <http://person#'${i}'> ex:sonOf <http://person#'$[$i+2]'> .
    <http://person#'${i}'> ex:sonOf <http://person#'$[$i+3]'> .
    <http://person#'${i}'> ex:sonOf <http://person#'$[$i+4]'> .
  }' data-analyzer:8175/kb > /dev/null
done
