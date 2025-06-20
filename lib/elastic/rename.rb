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
  # The RENAME processing command renames one or more columns.
  module Rename
    # @param [Hash<Symbol, String>] params Hash with key, values to rename
    # @option params [Symbol] :old_nameX The name of a column you want to rename.
    # @option params [String] new_nameX The new name of the column. If it conflicts with an existing
    #                         column name, the existing column is dropped. If multiple columns are
    #                         renamed to the same name, all but the rightmost column with the same
    #                         new name are dropped.
    # @param [String] old_nameX The name of a column you want to rename.
    # @param [String] new_nameX The new name of the column you want to rename.
    # @example
    #   esql.rename('first_name', 'fn')
    #   esql.rename({ first_name: 'fn', last_name: 'ln' })
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-rename
    def rename(params)
      hash_param(:rename, params)
      @query[:rename] = @query[:rename].gsub('=', 'AS')
      self
    end
  end
end
