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
  # The SAMPLE command samples a fraction of the table rows.
  module Sample
    # @param [Float] probability The probability that a row is included in the sample. The value
    #                            must be between 0 and 1, exclusive.
    # @example
    #   esql.from('employees').keep('emp_no').sample(0.05)
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/sample
    def sample!(probability)
      raise ArgumentError, 'probability must be between 0 and 1, exclusive' unless probability.between?(0, 1)

      @query[:sample] = probability
      self
    end

    def sample(probability)
      method_copy(:sample, probability)
    end
  end
end
