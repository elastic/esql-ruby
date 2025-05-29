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
  TYPE_NAMES = %w[dip distribution_change spike step_change trend_change].freeze
  # The ROW source command produces a row with one or more columns with values that you specify.
  module ChangePoint
    def change_point(column, key: nil, type_name: nil, pvalue_name: nil)
      query = column
      query += " ON #{key}" unless key.nil?
      validate_type_name(type_name) if type_name
      query += " AS #{type_name}, #{pvalue_name}" unless (type_name || pvalue_name).nil?

      @query[:change_point] = query
      self
    end

    private

    def validate_type_name(type_name)
      if TYPE_NAMES.include?(type_name.to_s)
        true
      else
        message = <<~MSG
          The possible change point types are:

          dip: a significant dip occurs at this change point
          distribution_change: the overall distribution of the values has changed significantly
          spike: a significant spike occurs at this point
          step_change: the change indicates a statistically significant step up or down in value distribution
          trend_change: there is an overall trend change occurring at this point
          See: https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands
        MSG
        raise ArgumentError, message
      end
    end
  end
end
