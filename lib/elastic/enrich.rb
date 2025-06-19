# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
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
  # ENRICH enables you to add data from existing indices as new columns using an enrich policy.
  # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-enrich
  class Enrich
    # @param [String] policy - The name of the enrich policy. You need to create and execute the enrich policy first.
    #
    # @example
    #
    #   esql.enrich('policy')
    #
    def initialize(policy, esql)
      @policy = policy
      @esql = esql
    end

    # @param [String] match_field - The match field. ENRICH uses its value to look for records in
    # the enrich index. If not specified, the match will be performed on the column with the same
    # name as the match_field defined in the enrich policy.
    #
    # @example
    #
    #  query.enrich(''policy').on('a')
    #
    def on(match_field)
      @match_field = match_field
      self
    end

    # @param [String] fields - The enrich fields from the enrich index that are added to the result
    # as new columns. If a column with the same name as the enrich field already exists, the existing
    # column will be replaced by the new column. If not specified, each of the enrich fields defined
    # in the policy is added. A column with the same name as the enrich field will be dropped unless
    # the enrich field is renamed.
    #
    # @example
    #   esql.enrich('policy').on('a').with('name')
    #   esql.enrich('policy').on('a').with({ name: 'language_name' })
    #
    def with(fields)
      @fields = if fields.is_a?(String)
                  fields
                elsif fields.is_a?(Hash)
                  fields.map { |k, v| "#{k} = #{v}" }.join(', ')
                end
      self
    end

    def to_s
      query = [@policy]
      query << "ON #{@match_field}" if @match_field
      query << "WITH #{@fields}" if @fields
      query.join(' ')
    end

    private

    def method_missing(name, *args)
      @esql.send(name, *args)
    end

    def respond_to_missing?(method_name, *args)
      super
    end
  end
end
