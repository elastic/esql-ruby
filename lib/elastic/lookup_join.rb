# Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
# or more contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

module Elastic
  # +LOOKUP JOIN+ enables you to add data from another index, AKA a 'lookup' index, to your ES|QL
  # query results, simplifying data enrichment and analysis workflows.
  # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-lookup-join
  module LookupJoin
    # @param [String] lookup_index The name of the lookup index. This must be a specific index
    #                              name - wildcards, aliases, and remote cluster references are not
    #                              supported. Indices used for lookups must be configured with the
    #                              lookup index mode.
    # @param [String] field_name The field to join on. This field must exist in both your current
    #                            query results and in the lookup index. If the field contains
    #                            multi-valued entries, those entries will not match anything (the
    #                            added fields will contain null for those rows).
    #
    # @example
    #   Elastic::ESQL.from('sample_data').lookup_join('threat_list', 'source.IP')
    #   Elastic::ESQL.from('system_metrics')
    #                .lookup_join('host_inventory', 'host.name')
    #                .lookup_join('ownerships', 'host.name').query
    #   => FROM system_metrics | LOOKUP JOIN host_inventory ON host.name | LOOKUP JOIN ownerships ON host.name
    #
    def lookup_join!(lookup_index, field_name)
      @query[:lookup_joins] ||= []
      @query[:lookup_joins] << { lookup_index.to_sym => field_name }
      self
    end

    def lookup_join(lookup_index, field_name)
      method_copy(:lookup_join, lookup_index, field_name)
    end
  end
end
