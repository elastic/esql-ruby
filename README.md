# Ruby ES|QL Query Builder

[![Tests](https://github.com/elastic/esql-ruby/actions/workflows/tests.yml/badge.svg)](https://github.com/elastic/esql-ruby/actions/workflows/tests.yml) [![rubocop](https://github.com/elastic/esql-ruby/actions/workflows/rubocop.yml/badge.svg)](https://github.com/elastic/esql-ruby/actions/workflows/rubocop.yml) [![Gem Version](https://badge.fury.io/rb/elastic-esql.svg)](https://badge.fury.io/rb/elastic-esql)

This gem allows you to build [ES|QL](https://www.elastic.co/docs/explore-analyze/query-filter/languages/esql) queries to use with Elastic's ES|QL `query` API. The library doesn't depend on an Elasticsearch client - its sole purpose is to facilitate building ES|QL queries in Ruby. This makes it possible to use it with any Elasticsearch client.

## Installation

You can install this gem from RubyGems with:

```
gem install elastic-esql
```

or add it to your Gemfile:

```ruby
gem 'elastic-esql'
```

## Use

> [!IMPORTANT]
> This library is in active development and the final API hasn't been completed yet. If you have any feedback on the current API or general usage, please don't hesitate to [open a new issue](https://github.com/elastic/esql-ruby/issues). It may also add features available in technical preview only.

You can instantiate a query with a [source command](https://www.elastic.co/docs/reference/query-languages/esql/esql-commands#esql-source-commands), `FROM`, `ROW`, `SHOW` or `TS`:

```ruby
Elastic::ESQL.from('sample')
```

Build the query by chaining ES|QL methods. You can see the generated query with `.to_s`:

```ruby
Elastic::ESQL.from('sample_data').limit(2).sort('@timestamp').descending.to_s
# => "FROM sample_data | LIMIT 2 | SORT @timestamp DESC"
```

To mutate an instantiated query object, you can use the `!` equivalents of each function:

```ruby
query = Elastic::ESQL.from('sample_data')
query.to_s
# => "FROM sample_data"
query.limit!(2).sort!('@timestamp')
query.to_s
# => "FROM sample_data | LIMIT 2 | SORT @timestamp"
```

You can import the Elastic module to use the `ESQL` class directly:

```ruby
include Elastic

esql = ESQL.from('employees')
           .fork([
                   ESQL.branch.where('emp_no == 10001'),
                   ESQL.branch.where('emp_no == 10002')
                 ])
           .keep('emp_no', '_fork')
           .sort('emp_no')
```

## API

📜 Reference documentation can be generated with YARD docs in `./doc` by running `rake yard`. You can also check out [the tests](https://github.com/elastic/esql-ruby/tree/main/spec) for even more usage examples.

### Source Commands (FROM, ROW, SHOW, TS)

An ES|QL query **must start** with a source command:

```ruby
# FROM
Elastic::ESQL.from('sample_data').to_s
# => FROM sample_data

# ROW
Elastic::ESQL.row(a: 1, b: 'two').to_s
# => ROW a = 1, b = two

# SHOW
# The `show` command will always return the String `'SHOW INFO'`:
Elastic::ESQL.show.to_s
# => SHOW INFO

# TS
Elastic::ESQL.ts('index_pattern').to_s
# => TS index_pattern
> Elastic::ESQL.ts('sample', '_index, _id').query
# => TS sample METADATA _index, _id
```

While `from`, `row` and `ts` can be chained with other functions to build a complex query, `show` will just return the `SHOW INFO` String.

ES|QL can access [document metadata fields](https://www.elastic.co/docs/reference/elasticsearch/mapping-reference/document-metadata-fields). To access these fields, use the `METADATA` directive with the `FROM` source command. For example:

```ruby
Elastic::ESQL.from('index').metadata('_index', '_id').query
# => FROM index METADATA _index, _id
```

In the case of `TS`, you can pass the metadata fields to the `ts` method:

```ruby
fields = '_index, _id_'
Elastic::ESQL.ts('index_pattern', fields).query
# => "TS index_pattern METADATA _index, _id_"
```

### DISSECT

[DISSECT](https://www.elastic.co/docs/reference/query-languages/esql/esql-process-data-with-dissect-grok ) enables you to extract structured data out of a string. The `dissect` function accepts a input and a pattern:

```ruby
query = Elastic::ESQL.from('sample_data')
query.dissect!('a', '%{date} - %{msg} - %{ip}').to_s
# => 'FROM sample_data | DISSECT a """%{date} - %{msg} - %{ip}"""'
```

You can also specify a separator, a string used as the separator between appended values, when using the append modifier:

```ruby
query.dissect!('a', '%{date} - %{msg} - %{ip}', ',').to_s
# => 'FROM sample_data | DISSECT a """%{date} - %{msg} - %{ip}""" APPEND_SEPARATOR=","'
```

### DROP

The [DROP](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-drop) processing command removes one or more columns.

```ruby
query.drop!('column1', 'column2').to_s
# => 'FROM sample_data | DROP column1, column2'
```

### ENRICH

[ENRICH](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-enrich) enables you to add data from existing indices as new columns using an enrich policy.

```ruby
esql = Elastic::ESQL.from('sample_data')
esql.enrich!('policy')
```

Once you call `enrich` on an `Elastic::ESQL` object, you can chain `on` and `with` to it.

```ruby
esql.enrich!('policy').on('a').with({ name: 'language_name' })
```

### EVAL

The [EVAL](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-eval) processing command enables you to append new columns with calculated values. EVAL supports various functions for calculating values.

```ruby
Elastic::ESQL.from('sample_data').eval({ height_feet: 'height * 3.281', height_cm: 'height * 100' }).to_s
# => "FROM sample_data | EVAL height_feet = height * 3.281, height_cm = height * 100"
```

### FORK

The [`FORK`](https://www.elastic.co/docs/reference/query-languages/esql/commands/fork) processing command creates multiple execution branches to operate on the same input data and combines the results in a single output table. You can create new branches for `fork` with `ESQL.branch`. This behavior is consistent with other ES|QL query builders in PHP, Python and JavaScript:

```ruby
esql = Elastic::ESQL.from('employees')
                    .fork([
                            Elastic::ESQL.branch.where('emp_no == 10001'),
                            Elastic::ESQL.branch.where('emp_no == 10002')
                          ])
                    .keep('emp_no', '_fork')
                    .sort('emp_no')
# => "FROM employees | FORK (WHERE emp_no == 10001) (WHERE emp_no == 10002) | KEEP emp_no, _fork | SORT emp_no"
```

### FUSE

The [`FUSE`](https://www.elastic.co/docs/reference/query-languages/esql/commands/fuse) processing command merges rows from multiple result sets and assigns new relevance scores.


```ruby
include Elastic

ESQL.from('books')
    .metadata('_id, _index, _score')
    .fork(
      [
        ESQL.branch.where('title == "Shakespeare"').sort('_score').desc,
        ESQL.branch.where('semantic_title == "Shakespeare"').sort('_score').desc
      ]
    )
    .fuse(:linear).to_s
# => "FROM books METADATA _id, _index, _score | FORK (WHERE title == \"Shakespeare\" | SORT _score DESC) (WHERE semantic_title == \"Shakespeare\" | SORT _score DESC) | FUSE LINEAR"
```

### GROK

[GROK](https://www.elastic.co/docs/reference/query-languages/esql/esql-process-data-with-dissect-grok) enables you to extract structured data out of a string.

```ruby
query.grok('a', '%{date} - %{msg} - %{ip}').to_s
# => 'FROM sample_data | GROK a """%{date} - %{msg} - %{ip}"""'
```

### KEEP

[KEEP](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-keep) enables you to specify what columns are returned and the order in which they are returned.

```ruby
query.keep('column1', 'column2').to_s
# => 'FROM sample_data | KEEP column1, column2'
```

### LIMIT

[LIMIT](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-limit) the number of rows that are returned, up to a maximum of 10,000 rows

```ruby
query.limit(2).to_s
# => 'FROM sample_data | LIMIT 2'
```

### LOOKUP JOIN

[LOOKUP JOIN](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-lookup-join) enables you to add data from another index, AKA a 'lookup' index, to your ES|QL query results, simplifying data enrichment and analysis workflows.

```ruby
Elastic::ESQL.from('system_metrics')
             .lookup_join('host_inventory', 'host.name')
             .lookup_join('ownerships', 'host.name').query
# => FROM system_metrics | LOOKUP JOIN host_inventory ON host.name | LOOKUP JOIN ownerships ON host.name
```

### RENAME

The [RENAME](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-rename) processing command renames one or more columns. Pass in a Hash where keys are the name of columns you want to rename, and the value is the name of the new column:

```ruby
query.rename({ first_name: 'fn', last_name: 'ln' }).to_s
# => 'FROM sample_data | RENAME first_name AS fn, last_name AS ln'
```

### SORT
The [SORT](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-sort) processing command sorts a table on one or more columns.

```ruby
Elastic::ESQL.from('sample_data').sort('@timestamp').to_s
# => 'FROM sample_data | SORT @timestamp'
```

You can chain `desc`, `asc`, `nulls_first` and `nulls_last` to your query after using `sort`:

```ruby
Elastic::ESQL.from('sample_data').sort('@timestamp').ascending.to_s
# => 'FROM sample_data | SORT @timestamp ASC'

Elastic::ESQL.from('sample_data').sort('@timestamp').descending.nulls_first.to_s
# => 'FROM sample_data | SORT @timestamp DESC NULLS FIRST'
```

### STATS

The [`STATS`](https://www.elastic.co/docs/reference/query-languages/esql/commands/stats-by) processing command groups rows according to a common value and calculates one or more aggregated values over the grouped rows.

```ruby
> Elastic::ESQL.from('employees').stats(column: 'avg_lang', avg: 'languages').query
# => "FROM employees | STATS avg_lang = AVG(languages)"
```

It’s possible to calculate multiple values:

```ruby
> stats = [
    { column: 'avg_lang', avg: 'languages' },
    { column: 'max_lang', max: 'languages' }
  ]
> Elastic::ESQL.from('employees').stats(stats).query
# => "FROM employees | STATS avg_lang = AVG(languages), max_lang = MAX(languages)"
```

You can write more complex queries with `where`, grouping and multiple values:
```ruby
> stats = [
  { column: 'avg50s', avg: 'salary::LONG', where: 'birth_date < "1960-01-01"' },
  { column: 'avg60s', avg: 'salary::LONG', where: 'birth_date >= "1960-01-01"' }
]
> esql = Elastic::ESQL.from('employees').stats(stats).by('gender').sort('gender')
> esql.query
# => "FROM employees | STATS avg50s = AVG(salary)::LONG WHERE birth_date < \"1960-01-01\", avg60s = AVG(salary)::LONG WHERE birth_date >= \"1960-01-01\" BY gender | SORT gender"
```

And nested functions:

```ruby
> stats = { column: 'distinct_word_count', count_distinct: { split: 'words, ";"' } }
> esql = Elastic::ESQL.row(words: '"foo;bar;baz;qux;quux;foo"').stats(stats)
> esql.query
# => "ROW words = \"foo;bar;baz;qux;quux;foo\" | STATS distinct_word_count = COUNT_DISTINCT(SPLIT(words, \";\"))"
```

They can be used with `TS`:

```ruby
> esql = Elastic::ESQL.ts('k8s')
         .where('cluster == "prod"')
         .where('pod == "two"')
         .stats({ column: 'events_received', max: { absent_over_time: 'events_received' } })
         .by('pod, time_bucket = TBUCKET(2 minute)')
> esql.query
# => "TS k8s | WHERE cluster == \"prod\" AND pod == \"two\" | STATS events_received = MAX(ABSENT_OVER_TIME(events_received)) BY pod, time_bucket = TBUCKET(2 minute)"
```


### WHERE

Use the [WHERE](https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-where) command to query the data.

```ruby
query = Elastic::ESQL.from('sample')
# => #<Elastic::ESQL:0x000073015ef041f0 @query={from: "sample"}>
query.where!('age > 18')
#  => #<Elastic::ESQL:0x000073015ef041f0 @query={from: "sample", where: "age > 18"}>
query.to_s
# => "FROM sample | WHERE age > 18"
```

You can chain WHERE commands which will be joined with `AND` as is expected in ES|QL:
```ruby
Elastic::ESQL.from('sample').where('first_name == "Juan"').where('last_name == "Perez"').where('age > 18').query
# => "FROM sample | WHERE first_name == \"Juan\" AND last_name == \"Perez\" AND age > 18"
```

### CHICKEN

The `CHICKEN` function wraps any text message in ASCII art of a chicken saying the message. Example usage:
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
=> nil
```

### Custom Strings

You can use the `custom` function to add custom Strings to the query. This will concatenate the strings at the end of the query. It will add them as they're sent to the function, without adding any pipe characters. They'll be joined to the rest of the query by a space character.

```ruby
esql = Elastic::ESQL.from('sample_data')
esql.custom('| MY_VALUE = "test value"').to_s
# => 'FROM sample_data | MY_VALUE = "test value"'
```

Chaining `custom` functions:

```ruby
esql.custom('| MY_VALUE = "test value"').custom('| ANOTHER, VALUE')
'FROM sample_data | MY_VALUE = "test value" | ANOTHER, VALUE'
```

## Usage with elasticsearch-ruby

You can use the query builder directly with [elasticsearch-ruby](https://github.com/elastic/elasticsearch-ruby) and the `esql.query` API by sending the query object:

```ruby
require 'elasticsearch'
require 'elastic/esql'

client = Elasticsearch::Client.new
index = 'sample_data'

query = Elastic::ESQL.from(index)
                     .sort('@timestamp')
                     .desc
                     .where('event_duration > 5000000')
                     .limit(3)
                     .eval({ duration_ms: 'ROUND(event_duration/1000000.0, 1)' })
client.esql.query(body: { query: query })
```

You can also use it with the ES|QL Helper from the Elasticsearch Ruby client ([find out more](https://www.elastic.co/search-labs/blog/esql-ruby-helper-elasticsearch)):

```ruby
require 'elasticsearch/helpers/esql_helper'

Elasticsearch::Helpers::ESQLHelper.query(client, query)
```

## License

This software is licensed under the [Apache 2 license](./LICENSE). See [NOTICE](./NOTICE).
