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
  # Util mixin with reusable functions to be included.
  module Util
    # Helper method to return a copy of the object when functions are called without `!`, so the
    # object is not mutated.
    def method_copy(name, *params)
      esql = clone
      esql.instance_variable_set('@query', esql.instance_variable_get('@query').clone)
      esql.send("#{name}!", *params)
      esql
    end

    # Helper to build the String for the simpler functions.
    # These are of the form 'key.upcase value' like 'DROP value'
    # If metadata has been set, it needs to be added to FROM. There's a possibility there'll be more
    # special cases like this in the future, they can be added here.
    def build_string_query
      @query.map do |k, v|
        if k == :from && !@metadata.empty?
          "#{k.upcase} #{v} METADATA #{@metadata.join(', ')}"
        elsif k && (v == '' || v.nil?)
          k.upcase
        else
          "#{k.upcase} #{v}"
        end
      end.join(' | ')
    end
  end
end
