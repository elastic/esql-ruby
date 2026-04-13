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
  # The INLINE STATS processing command groups rows according to a common value and calculates one
  # or more aggregated values over the grouped rows. The results are appended as new columns to the
  # input rows.
  # The command is identical to STATS except that it preserves all the columns from the input table.
  module InlineStats
    # @param [Hash|Array<Hash>] stats
    # @option stats [String] columnX The name by which the aggregated value is returned. If
    #                                omitted, the name is equal to the corresponding expression
    #                                (expressionX). If multiple columns have the same name, all but
    #                                the rightmost column with this name will be ignored.
    # @option stats [String] expressionX An expression that computes an aggregated value.
    # @option stats [String] grouping_expressionX An expression that outputs the values to group by.
    #                                             If its name coincides with one of the computed
    #                                             columns, that column will be ignored.
    # @option stast [Boolean] boolean_expressionX The condition that must be met for a row to be
    #                                             included in the evaluation of expressionX.
    #
    # @example
    #   ESQL.from('employees').inline_stats(column: 'avg_lang', avg: 'languages')
    #
    #   stats = [
    #     { column: 'avg_lang', avg: 'languages' },
    #     { column: 'max_lang', max: 'languages' }
    #   ]
    #   esql = ESQL.from('employees').inline_stats(stats)
    #
    def inline_stats(stats)
      @query[:inline_stats] = parse_stats(stats)
      self
    end
  end
end
