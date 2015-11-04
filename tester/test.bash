#!/bin/bash

# DEBUG="on"
MAXTRIPLES=1000000
STEP=100000
FRIENDS=30

MAXITER=$((MAXTRIPLES/STEP))
RESULTSFILE=/tmp/`date +%Y%m%d-%H%M%S`.txt
if [[ $DEBUG ]] ; then
  RESULTSFILE=/tmp/debug.txt
  rm $RESULTSFILE
fi

function createUpdateQuery(){
  start=$1
  triples=$2
  nFriends=$3
  query='PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX ex: <http://example.org#>
  INSERT DATA { '
  i=0
  current=$start
  while [ $i -lt $triples ]
  do
    query=${query}'<http://person#'$current'> rdf:type ex:Person . '
    remainingTriples=$(( triples - i ))
    # nFriends=$(( (RANDOM % maxfriends) + 1 ))
    nFriends=$(( nFriends > remainingTriples - 1 ? remainingTriples - 1 : nFriends ))
    j=0
    friend=0
    while [ $j -lt $nFriends ]
    do
      friend=$(( friend + (RANDOM % ( (start + triples) / nFriends ) + 1 ) ))
      query=${query}'<http://person#'$current'> ex:friendOf <http://person#'$friend'> . '
      j=$((j+1))
    done
    i=$((i+nFriends+1))
    current=$((current+1))
  done
  query=${query}'}'
  echo $query
}

echo "Waiting for data analyzer to be ready"
until $(curl --output /dev/null --silent --head --fail http://data-analyzer:8175/queries); do
    printf '.'
    sleep 5
done

curl -sS --fail --data-urlencode "action=update" --data-urlencode "queryBody=clear all" data-analyzer:8175/kb > /dev/null
i=0
current=0
while [ $i -lt $MAXITER ]
do
  if [[ $DEBUG ]] ; then
    echo $(createUpdateQuery $current $STEP $FRIENDS)
  fi
  curl -sS --fail --data-urlencode "action=update" --data-urlencode "queryBody=$(createUpdateQuery $current $STEP $FRIENDS)" \
  data-analyzer:8175/kb > /dev/null
  ts=$(date +%s%N)
  curl -G -sS --fail --data-urlencode 'query=
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX ex: <http://example.org#>
    SELECT (COUNT (*) as ?count)
    WHERE
    {
      ?s rdf:type ex:Person ;
        ex:friendOf ?p .
      ?p rdf:type ex:Person .
    }
    ' data-analyzer:8175/kb > /dev/null
  tt=$((($(date +%s%N) - $ts)/1000000))
  echo $((STEP*(i+1))),$tt >> $RESULTSFILE
  current=$((current + STEP / (FRIENDS + 1) + ( STEP % (FRIENDS + 1) == 0 ? 0 : 1 ) ))
  i=$((i+1))
done
