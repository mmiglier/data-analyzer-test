# Data Analyzer Test

Testing the `/kb` API of the [MODAClouds Tower 4Clouds Data Analyzer](http://deib-polimi.github.io/tower4clouds/docs/data-analyzer/). The following query counting the number of friendships is run multiple times while increasing the size of the knowledge base with randomly generated persons and friendships relations:

```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX ex: <http://example.org#>
SELECT (COUNT (*) as ?count)
WHERE
{
  ?s rdf:type ex:Person ;
    ex:friendOf ?p .
  ?p rdf:type ex:Person .
}
```

Query execution time as well as jvm memory consumption is recorded.

## How to run

Run `docker-compose up -d`.

Results in folder `results`.
