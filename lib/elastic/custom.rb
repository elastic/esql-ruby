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
  # Helpers that allows adding custom Strings to the query.
  module Custom
    # This will concatenate custom strings at the end of the query. It will add them as they're sent
    # to the function, without adding any pipe characters. They'll be joined to the rest of the
    # query by a space character.
    #
    # @param [String] custom String to add to the query
    # @example
    #   esql.custom('| MY_VALUE = "test value"')
    #   esql.custom('| MY_VALUE = "test"').custom('| OTHER, VALUES')
    #
    def custom!(string)
      @custom << string
      self
    end

    def custom(*params)
      esql = clone
      esql.instance_variable_set('@custom', esql.instance_variable_get('@custom').clone)
      esql.custom!(*params)
      esql
    end
  end
end
