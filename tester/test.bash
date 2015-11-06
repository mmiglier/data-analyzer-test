#!/bin/bash

DEBUG="on"
MAXTRIPLES=100000
STEP=5000 # 10000 causes out memory overflow
FRIENDS=50

MAXITER=$((MAXTRIPLES/STEP))
RESULTSFILE=/tmp/results/`date +%Y%m%d-%H%M%S`-results.csv
if [[ $DEBUG ]] ; then
  RESULTSFILE=/tmp/results/debug-results.csv
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

echo "Clearing data analyzer"
curl -sS --fail -d "action=update" -d "queryBody=clear all" data-analyzer:8175/kb > /dev/null
i=0
current=0
echo "triples,start,end,time" >> $RESULTSFILE

echo "Starting feeding"
while [ $i -lt $MAXITER ]
do
  if [[ $DEBUG ]] ; then
    echo $(createUpdateQuery $current $STEP $FRIENDS)
  fi
  echo "queryBody=$(createUpdateQuery $current $STEP $FRIENDS)" | \
    curl -sS --fail -d "action=update" -d @- \
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
  te=$(date +%s%N)
  tt=$((($te - $ts)/1000000))
  echo $((STEP*(i+1))),$ts,$te,$tt >> $RESULTSFILE
  current=$((current + STEP / (FRIENDS + 1) + ( STEP % (FRIENDS + 1) == 0 ? 0 : 1 ) ))
  i=$((i+1))
done
