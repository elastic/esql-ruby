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

require_relative 'change_point'
require_relative 'dissect'
require_relative 'drop'
require_relative 'eval'
require_relative 'grok'
require_relative 'limit'
require_relative 'keep'
require_relative 'rename'
require_relative 'row'
require_relative 'show'
require_relative 'sort'
require_relative 'where'

module Elastic
  # Elastic::ESQL.from('sample_data').sort_descending('@timestamp').limit(3)
  # FORM 'sample_data' | SORT @timestamp desc | LIMIT 3
  class ESQL
    include ChangePoint
    include Dissect
    include Drop
    include Eval
    include Grok
    include Keep
    include Limit
    include Rename
    include Row
    include Show
    include Sort
    include Where
    SOURCE_COMMANDS = [:from, :row, :show].freeze

    def initialize
      @query = {}
    end

    def query
      raise ArgumentError, 'No source command found' unless source_command_present?

      @query.map do |k, v|
        "#{k.upcase} #{v}"
      end.join(' | ')
    end

    # Class method to allow instantiating with Elastic::ESQL.from('sample_data')
    def self.from(from)
      new.from(from)
    end

    def self.show
      new.show
    end

    def self.row(*params)
      new.row(*params)
    end

    # Instance method to allow to update from with esql.from('something_else')
    def from(from)
      @query = { from: from }
      self
    end

    def to_s
      query
    end

    alias run query

    private

    # Function for eval, row, and other functions that have one or more columns with values specified
    # as parameters. The hash_or_string function is called with the caller name since it's the same
    # logic to use these parameters.
    # TODO: Refactor to accept other types when not a Hash
    def hash_param(name, params)
      raise_hash_error(name) unless params.is_a?(Hash)

      @query[symbolize(name)] = params.map { |k, v| "#{k} = #{v}" }.join(', ')
      self
    end

    def raise_hash_error(name)
      raise ArgumentError, "#{name.to_s.upcase} needs a Hash as a parameter where the keys are the " \
                          'column names and the value is the function or expression to calculate.'
    end

    def string_or_strings(name, params)
      @query[name] = if params.size > 1
                       params.join(', ')
                     else
                       params[0]
                     end
    end

    def symbolize(name)
      name.is_a?(Symbol) ? name : name.to_sym
    end

    def source_command_present?
      SOURCE_COMMANDS.map { |c| @query.each_key { |k| return true if k == c } }

      false
    end
  end
end
