# 0.4.0

This update adds some new ES|QL functions, tests for more specific uses, general documentation updates and code refactoring.

## Adds `FORK` command

The [`FORK`](https://www.elastic.co/docs/reference/query-languages/esql/commands/fork) processing command creates multiple execution branches to operate on the same input data and combines the results in a single output table.

Syntax:

```ruby
esql = Elastic::ESQL.from('employees')
                    .fork([
                            Elastic::FORK.new.where('emp_no == 10001'),
                            Elastic::FORK.new.where('emp_no == 10002')
                          ])
                    .keep('emp_no', '_fork')
                    .sort('emp_no')
=> "FROM employees | FORK (WHERE emp_no == 10001) (WHERE emp_no == 10002) | KEEP emp_no, _fork
| SORT emp_no"
```

## Adds `FUSE` command

The [`FUSE`](https://www.elastic.co/docs/reference/query-languages/esql/commands/fuse) processing command merges rows from multiple result sets and assigns new relevance scores.

Syntax:

```ruby
include Elastic

ESQL.from('books')
    .metadata('_id, _index, _score')
    .fork(
      [
        FORK.new.where('title == "Shakespeare"').sort('_score').desc,
        FORK.new.where('semantic_title == "Shakespeare"').sort('_score').desc
      ]
    )
    .fuse(:linear).to_s
=> "FROM books METADATA _id, _index, _score
| FORK
(WHERE title == \"Shakespeare\" | SORT _score DESC)
(WHERE semantic_title == \"Shakespeare\" | SORT _score DESC)
| FUSE LINEAR"
```

## `ENRICH` code refactor

Example code snippets from the official documentation were added to the tests. This resulted in some refactors and updates that made the code for `enrich` more robust. To build the query, the `Enrich` object now uses a new method name `to_query`, and `to_s` calls ESQL's function, so the results are more cohesive when chaining functions and using `to_s`.

## `LOOKUP JOIN` code refactor

The `lookup_join` code is now more flexible. It's part of `@query` in the `ESQL` object, so it's added to the query in the order it is chained to the object. The lookup join array is now parsed in `Util`, a helper `method build_lookup_joins` is called from `build_string_query`.

# 0.3.0

## Adds `TS` source command

The [`TS`](https://www.elastic.co/docs/reference/query-languages/esql/commands/ts) source command is similar to the `FROM` source command, with the following key differences:

* Targets only time series indices
* Enables the use of time series aggregation functions inside the STATS command

Syntax:

```ruby
> Elastic::ESQL.ts('sample').query
=> "TS sample"
> Elastic::ESQL.ts('sample', ['_index', '_id']).query
=> "TS sample METADATA _index, _id"
> Elastic::ESQL.ts('sample', '_index, _id').query
=> "TS sample METADATA _index, _id"
```

## Adds `STATS` command

The [`STATS`](https://www.elastic.co/docs/reference/query-languages/esql/commands/stats-by) processing command groups rows according to a common value and calculates one or more aggregated values over the grouped rows.

```ruby
> Elastic::ESQL.from('employees').stats(column: 'avg_lang', avg: 'languages').query
=> "FROM employees | STATS avg_lang = AVG(languages)"
```

See [README](https://github.com/elastic/esql-ruby?tab=readme-ov-file#stats) for more usage examples.

## Adds `CHICKEN` function

[Elasticsearch Pull Request](https://github.com/elastic/elasticsearch/pull/140645) - The `CHICKEN` function wraps any text message in ASCII art of a chicken saying the message. Example usage:
```ruby
> query = Elastic::ESQL.chicken("Hello World")
=> "ROW CHICKEN(\"Hello World\")"
> query = Elastic::ESQL.🐔("Hello World")
=> "ROW CHICKEN(\"Hello World\")"
> client = Elasticsearch::Client.new
> puts client.esql.query(body: { query: query }).body['values'][0][0]
 _____________
< Hello World >
 -------------
     \
      \    MM
       \ <' \___/|
          \_  _/
            ][
```

# 0.2.0

## Adds METADATA function for FROM source command.

ES|QL can access [document metadata fields](https://www.elastic.co/docs/reference/elasticsearch/mapping-reference/document-metadata-fields). To access these fields, use the `METADATA` directive with the `FROM` source command. For example:

```ruby
Elastic::ESQL.from('index').metadata('_index', '_id').query
# => FROM index METADATA _index, _id
```

## Adds LOOKUP JOIN

[LOOKUP JOIN](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-lookup-join) enables you to add data from another index, AKA a 'lookup' index, to your ES|QL query results, simplifying data enrichment and analysis workflows.

```ruby
Elastic::ESQL.from('system_metrics')
             .lookup_join('host_inventory', 'host.name')
             .lookup_join('ownerships', 'host.name').query
# => FROM system_metrics | LOOKUP JOIN host_inventory ON host.name | LOOKUP JOIN ownerships ON host.name
```

# 0.1.0

First release, of ES|QL Query builder for Ruby.

This library is in active development and the final API hasn't been completed yet. If you have any feedback on the current API or general usage, please don't hesitate to [open a new issue](https://github.com/elastic/esql-ruby/issues).

Check out the [README](./README.md) for available functions and examples. If you [clone the code](https://github.com/elastic/esql-ruby/), you can also generate the reference documentation with YARD by running `rake yard` in the root directory. This will create a `doc` directory, open `doc/index.html` in a web browser to read the docs.
