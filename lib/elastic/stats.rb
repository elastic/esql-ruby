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
  # The STATS processing command groups rows according to a common value and calculates one or
  # more aggregated values over the grouped rows.
  module Stats
    # Parameters
    # columnX - The name by which the aggregated value is returned. If omitted, the name is equal
    # to the corresponding expression (expressionX). If multiple columns have the same name, all
    # but the rightmost column with this name will be ignored.
    # expressionX - An expression that computes an aggregated value.
    # grouping_expressionX - An expression that outputs the values to group by. If its name
    # coincides with one of the computed columns, that column will be ignored.
    # boolean_expressionX -  The condition that must be met for a row to be included in the
    # evaluation of expressionX.
    #
    # Examples
    #   FROM employees
    #   | STATS count = COUNT(emp_no) BY languages
    #   | SORT languages
    # FROM employees
    # | STATS COUNT(height)
    #
    def stats(stats)
      @query[:stats] = if stats.is_a?(Hash)
                         stat_to_string(stats)
                       elsif stats.is_a? Array
                         stats.map { |stat| stat_to_string(stat) }.join(', ')
                       end
      self
    end

    def by(grouping)
      @query[:stats] << " BY #{grouping}"
      self
    end

    private

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

      raise ArgumentError 'No expression specified'
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
