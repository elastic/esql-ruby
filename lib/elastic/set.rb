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
  # The SET directive can be used to specify query settings that modify the behavior of an ES|QL
  # query.
  # Multiple SET directives can be included in a single query, separated by semicolons. If the same
  # setting is defined multiple times, the last definition takes precedence.
  #
  module SetDirective
    # @param [Hash] value The column with the metric in which you want to detect a change point.
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/set
    def set(settings)
      @set = parse_settings(settings)
      self
    end

    private

    def parse_settings(settings)
      settings.map do |key, value|
        if value.is_a?(String)
          "#{key} = \"#{value}\""
        elsif value.is_a?(Hash)
          # Translate value hash as {"key": value}
          rep = value.map { |k, v| "{\"#{k}\":#{v}}" }.join
          "#{key} = #{rep}"
        else
          "#{key} = #{value}"
        end
      end.join(', ')
    end
  end
end
