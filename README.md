# Ruby ES|QL Query builder

This gem allows you to build [ES|QL](https://www.elastic.co/docs/explore-analyze/query-filter/languages/esql) queries to use with Elastic's ES|QL `query` API.

> [!IMPORTANT]
> This library is in active development and the final API hasn't been completed yet. If you have any feedback on the current API or general usage, please don't hesitate to [open a new issue](https://github.com/elastic/esql-ruby/issues).

You can instantiate a query with any [source command](https://www.elastic.co/docs/reference/query-languages/esql/esql-commands#esql-source-commands), like `from`, `row` or `show`:

```ruby
Elastic::ESQL.from('sample')
```

Build the query by chaining ES|QL methods. You can see the generated query with `.to_s`:

```ruby
Elastic::ESQL.from('sample_data').limit(2).sort('@timestamp').descending.to_s
# => "FROM sample_data | LIMIT 2 | SORT @timestamp DESC"
```

## EVAL

```ruby
Elastic::ESQL.from('sample_data').eval({ height_feet: 'height * 3.281', height_cm: 'height * 100' }).to_s
# => "FROM sample_data | EVAL height_feet = height * 3.281, height_cm = height * 100"
```

## ROW

```ruby
Elastic::ESQL.row({ a: 1, b: 'two', c: 'null' }).to_s
# => "ROW a = 1, b = two, c = null"
```

## WHERE

```ruby
query = Elastic::ESQL.from('sample')
# => #<Elastic::ESQL:0x000073015ef041f0 @query={from: "sample"}>
query.where('age > 18')
#  => #<Elastic::ESQL:0x000073015ef041f0 @query={from: "sample", where: "age > 18"}>
query.to_s
# => "FROM sample | WHERE age > 18"
```

You can chain WHERE commands which will be joined with `AND` as is expected in ES|QL:
```ruby
Elastic::ESQL.from('sample').where('first_name == "Juan"').where('last_name == "Perez"').where('age > 18').query
# => "FROM sample | WHERE first_name == \"Juan\" AND last_name == \"Perez\" AND age > 18"
```

# Usage with elasticsearch-ruby

You can use the query builder directly with [elasticsearch-ruby](https://github.com/elastic/elasticsearch-ruby) and the `esql.query` API by sending the query object:

```ruby
require 'elasticsearch'
require 'elastic-esql'

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
