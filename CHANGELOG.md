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
