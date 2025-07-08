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
  # The SORT processing command sorts a table on one or more columns.
  module Sort
    # @param sort - The column to sort on.
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-sort
    def sort(column)
      @query[:sort] = column
      self
    end

    # Sorts ascending, adds ASC to the sort function
    def ascending
      sorting('ASC')
    end

    # Sorts descending, adds DESC to the sort function
    def descending
      sorting('DESC')
    end

    # Sort null values first using NULLS FIRST
    # By default, null values are treated as being larger than any other value.
    #
    def nulls_first
      sorting('NULLS FIRST')
    end

    # Sort null values last using NULLS LAST
    #
    def nulls_last
      sorting('NULLS LAST')
    end

    alias asc ascending
    alias desc descending

    private

    def sorting(name)
      raise ArgumentError, 'No sort field specified' unless @query[:sort]

      @query[:sort] = "#{@query[:sort]} #{name}"
      self
    end
  end
end
