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

require_relative 'change_point'
require_relative 'custom'
require_relative 'dissect'
require_relative 'drop'
require_relative 'enrich'
require_relative 'eval'
require_relative 'functions'
require_relative 'fork'
require_relative 'fuse'
require_relative 'grok'
require_relative 'keep'
require_relative 'lookup_join'
require_relative 'metadata'
require_relative 'queryable'
require_relative 'rename'
require_relative 'row'
require_relative 'show'
require_relative 'stats'
require_relative 'ts'
require_relative 'util'

module Elastic
  # @example
  #    Elastic::ESQL.from('sample_data').sort_descending('@timestamp').limit(3).to_s
  #    # => FROM 'sample_data' | SORT @timestamp desc | LIMIT 3
  class ESQL
    [
      ChangePoint, Custom, Dissect, Drop, Eval, Fork, Fuse, Grok, Keep, LookupJoin, Metadata,
      Queryable, Rename, Row, Show, Stats, TS, Util
    ].each { |m| include m }

    SOURCE_COMMANDS = [:from, :row, :show, :ts].freeze

    def initialize
      @query = {}
      @custom = []
      @metadata = []
    end

    # Function to build the ES|QL formatted query and return it as a String.
    # @raise [ArgumentError] if the query has no source command
    # @return [String] The ES|QL query in ES|QL format.
    def query
      raise ArgumentError, 'No source command found' unless source_command_present?

      @query[:enrich] = @enriches.map(&:to_query).join('| ') if @enriches
      string_query = build_string_query
      string_query.concat(" #{@custom.join(' ')}") unless @custom.empty?
      string_query
    end

    # Creates a new Enrich object to chain with +on+ and +with+. If other method is chained to the
    # Enrich object, it calls it upon the ESQL object that instantiated it, and returns it.
    # @return [Elastic::Enrich]
    def enrich(policy)
      @enriches ||= []
      enrich = Enrich.new(policy, self)
      @enriches << enrich
      enrich
    end

    # Class method to allow static instantiation.
    # @param [String] index_pattern A list of indices, data streams or aliases. Supports wildcards and date math.
    # @example
    #   Elastic::ESQL.from('sample_data')
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/source-commands#esql-from
    def self.from(index_pattern)
      new.from(index_pattern)
    end

    # The SHOW source command returns information about the deployment and its capabilities.
    # @return [String] 'SHOW INFO'
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/source-commands#esql-show
    def self.show
      new.show
    end

    # Class method to allow static instantiation.
    # @param [Hash] params Receives a Hash<column, value>
    # @option params [String] column_name The column name. In case of duplicate column names, only the
    #                                rightmost duplicate creates a column.
    # @option params [String] value The value for the column. Can be a literal, an expression, or a function.
    def self.row(*params)
      new.row(*params)
    end

    def self.ts(*params)
      new.ts(*params)
    end

    # Instance method to allow to update +from+ with +esql.from('different_source')+.
    # @param [String] index_pattern A list of indices, data streams or aliases. Supports wildcards and date math.
    def from(index_pattern)
      @query = { from: index_pattern }
      self
    end

    # Defining to_s so the ES|QL formatted query is returned. This way the query will be serialized
    # when passing an Elastic::ESQL object to the Elasticsearch client and other libraries.
    def to_s
      query
    end

    # rubocop:disable Naming/MethodName, Naming/BinaryOperatorParameterName
    def self.🐔(message)
      "ROW CHICKEN(\"#{message}\")"
    end

    def 🐔(message)
      self.class.🐔(message)
    end

    alias chicken 🐔

    class << self
      alias chicken 🐔
    end
    # rubocop:enable Naming/MethodName, Naming/BinaryOperatorParameterName

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

    # Error raised when a function expects a Hash and something else is passed in, with explanation
    def raise_hash_error(name)
      raise ArgumentError, "#{name.to_s.upcase} needs a Hash as a parameter where the keys are the " \
                           'column names and the value is the function or expression to calculate.'
    end

    # Used when building the query from hash params function
    def symbolize(name)
      name.is_a?(Symbol) ? name : name.to_sym
    end

    # Check if we have a source command
    def source_command_present?
      SOURCE_COMMANDS.map { |c| @query.each_key { |k| return true if k == c } }

      false
    end
  end
end
