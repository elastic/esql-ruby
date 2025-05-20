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
  # Elastic::ESQL.from('sample_data').sort_descending('@timestamp').limit(3)
  # FORM 'sample_data' | SORT @timestamp desc | LIMIT 3
  class ESQL
    def initialize(from)
      @from = from
      @query = { from: @from }
    end

    def self.from(from)
      new(from)
    end

    def sort(sort)
      @query[:sort] = sort
      self
    end

    def ascending
      raise ArgumentError unless @query[:sort]

      @query[:sort] = "#{@query[:sort]} ASC"
      self
    end

    def descending
      raise ArgumentError unless @query[:sort]

      @query[:sort] = "#{@query[:sort]} DESC"
      self
    end

    def limit(limit)
      @query[:limit] = limit
      self
    end

    def where(where)
      @query[:where] = where
      self
    end

    # Use the EVAL command to append columns to a table, with calculated values.
    # esql.eval('duration_ms', 'event_duration/10000.0')
    # esql.eval({ height_feet: 'height * 3.281', height_cm: 'height * 100' })
    # TODO: Can the experience be improved?
    # TODO: Consider array as argument?
    def eval(*params)
      @query[:eval] = if params.size == 1 && params[0].is_a?(Hash)
                        params[0].map { |k, v| "#{k} = #{v}" }.join(', ')
                      elsif params.size == 2 && params[0].is_a?(String) && params[1].is_a?(String)
                        "#{params[0]} = #{params[1]}"
                      else
                        raise ArgumentError, 'EVAL needs either a String column name and a String value or a key, ' \
                                             'value Hash where the keys are the column names and the value ar the ' \
                                             'function or expression to calculate.'
                      end
      self
    end

    # KEEP enables you to specify what columns are returned and the order in which they are returned.
    # Accepts:
    #  esql.keep('column1, column2') || esql.keep('column1', 'column2')
    def keep(*params)
      @query[:keep] = if params.size > 1
                        params.join(', ')
                      else
                        params[0]
                      end
      self
    end

    def query
      @query.map do |k, v|
        "#{k.upcase} #{v}"
      end.join(' | ')
    end

    alias run query
    alias asc ascending
    alias desc descending
  end
end
