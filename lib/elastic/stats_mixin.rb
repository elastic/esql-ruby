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
  # Mixin for shared functions between STATS and INLINE_STATS
  module StatsMixin
    def by(grouping)
      @query[@query.keys.last] << " BY #{grouping}"
      self
    end

    private

    # Parse incoming parameters accordingly whether it's one Hash or an Array of Hashes
    def parse_stats(stats)
      if stats.is_a?(Hash)
        stat_to_string(stats)
      elsif stats.is_a? Array
        stats.map { |stat| stat_to_string(stat) }.join(', ')
      end
    end

    # Turns a stat Hash into the required query
    # rubocop:disable Metrics/AbcSize
    def stat_to_string(stat)
      validate_function(stat)
      expressions = find_expressions(stat)
      query = []
      query << "#{stat[:column]} =" if stat[:column]
      query << expressions.map { |e| parse_expression(e, stat[e]) }.join(', ')
      query << "WHERE #{stat[:where]}" if stat[:where]
      query << "BY #{stat[:by]}" if stat[:by]
      query.join(' ')
    end
    # rubocop:enable Metrics/AbcSize

    # Validates that there's an expression with a function
    def validate_function(stat)
      stat.keys.map { |f| return true if AGG_FUNCTIONS.include?(f) || TS_AGG_FUNCTIONS.include?(f) }

      raise ArgumentError,
            'No valid expression specified. Use an Aggregation function or TS aggregation function to compute.'
    end

    def find_expressions(stat)
      (AGG_FUNCTIONS + TS_AGG_FUNCTIONS).select { |f| stat.keys.include?(f) }
    end

    # Parses the expression into the proper query
    def parse_expression(expression, value)
      if value.is_a?(Hash)
        "#{expression.upcase}(#{deep_dive(value)})"
      elsif value.is_a?(String)
        if value.include?('::')
          value, type = value.split('::')
          "#{expression.upcase}(#{value})::#{type}"
        else
          "#{expression.upcase}(#{value})"
        end
      end
    end

    def deep_dive(expression)
      return expression if expression.is_a?(String)

      raise ArgumentError "Expression #{expression} is invalid" unless expression.is_a?(Hash)

      key = expression.keys.first
      "#{key.upcase}(#{deep_dive(expression[key])})"
    end
  end
end
