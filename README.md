# Ruby ES|QL Query builder

This gem allows you to build [ES|QL](https://www.elastic.co/docs/explore-analyze/query-filter/languages/esql) queries to use with Elastic's ES|QL `query` API.

You can instantiate a query with `Elastic::ESQL.from('sample')` and start building on it by chaining ES|QL methods. You can see the generated query with `.query`.

Basic example:

```ruby
Elastic::ESQL.from('sample_data').limit(2).sort('@timestamp').descending.query
# => "FROM sample_data | LIMIT 2 | SORT @timestamp DESC"
```

Example using `EVAL`:

```ruby
esql = Elastic::ESQL.from('sample_data').eval('duration_ms', 'event_duration/10000.0')
# => #<Elastic::ESQL:0x000077cb530b7548 @query={from: "sample_data", eval: "duration_ms = event_duration/10000.0"}>
esql.run
# => "FROM sample_data | EVAL duration_ms = event_duration/10000.0"
esql.eval({ height_feet: 'height * 3.281', height_cm: 'height * 100' }).query
 => "FROM sample_data | EVAL height_feet = height * 3.281, height_cm = height * 100"
```

# Usage with elasticsearch-ruby

You can use the query builder directly with [elasticsearch-ruby](https://github.com/elastic/elasticsearch-ruby) and the `esql.query` API:

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

