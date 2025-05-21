# Ruby ES|QL Query builder

This gem allows you to build [ES|QL](https://www.elastic.co/docs/explore-analyze/query-filter/languages/esql) queries to use with Elastic's ES|QL `query` API.

You can instantiate a query with `Elastic::ESQL.from('sample')` and start building on it by chaining ES|QL methods to it. You can see the generated query with `.query`.

Example:
```ruby
Elastic::ESQL.from('sample_data').limit(2).sort('@timestamp').descending.query
# => "FROM sample_data | LIMIT 2 | SORT @timestamp DESC"
```

EVAL
```ruby
esql = Elastic::ESQL.from('sample_data').eval('duration_ms', 'event_duration/10000.0')
# => #<Elastic::ESQL:0x000077cb530b7548 @query={from: "sample_data", eval: "duration_ms = event_duration/10000.0"}>
esql.run
# => "FROM sample_data | EVAL duration_ms = event_duration/10000.0"
esql.eval({ height_feet: 'height * 3.281', height_cm: 'height * 100' }).query
 => "FROM sample_data | EVAL height_feet = height * 3.281, height_cm = height * 100"
```
