# Ruby ES|QL Query builder

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
> This library is in active development and the final API hasn't been completed yet. If you have any feedback on the current API or general usage, please don't hesitate to [open a new issue](https://github.com/elastic/esql-ruby/issues).

You can instantiate a query with a [source command](https://www.elastic.co/docs/reference/query-languages/esql/esql-commands#esql-source-commands), like `from` or `row`:

```ruby
Elastic::ESQL.from('sample')
```

The `show` command will always return the String `'SHOW INFO'`:

```ruby
Elastic::ESQL.show
# => "SHOW INFO"
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

## API

📜 Reference documentation can be generated with YARD docs in `./doc` by running `rake yard`.

### Source Commands (FROM, ROW, SHOW)

An ES|QL query must start with a source command:

```ruby
# FROM
Elastic::ESQL.from('sample_data').to_s
# => FROM sample_data

# ROW
Elastic::ESQL.row(a: 1, b: 'two').to_s
# => ROW a = 1, b = two

# SHOW
Elastic::ESQL.show
# => SHOW INFO
```

While `row` and `from` can be chained with other functions to build a complex query, `show` will just return the `SHOW INFO` String.

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
