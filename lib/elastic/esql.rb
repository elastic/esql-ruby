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

require_relative 'branch'
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
require_relative 'inline_stats'
require_relative 'keep'
require_relative 'lookup_join'
require_relative 'metadata'
require_relative 'metrics_info'
require_relative 'mv_expand'
require_relative 'promql'
require_relative 'queryable'
require_relative 'registered_domain'
require_relative 'rename'
require_relative 'rerank'
require_relative 'row'
require_relative 'sample'
require_relative 'set'
require_relative 'show'
require_relative 'stats'
require_relative 'stats_mixin'
require_relative 'ts'
require_relative 'user_agent'
require_relative 'uri_parts'
require_relative 'util'

module Elastic
  # @example
  #    Elastic::ESQL.from('sample_data').sort_descending('@timestamp').limit(3).to_s
  #    # => FROM 'sample_data' | SORT @timestamp desc | LIMIT 3
  class ESQL
    [
      ChangePoint, Custom, Dissect, Drop, Eval, Fork, Fuse, Grok, InlineStats, Keep, LookupJoin,
      Metadata, MetricsInfo, MvExpand, PromQL, Queryable, RegisteredDomain, Rename, Row, Sample,
      SetDirective, Show, Stats, StatsMixin, TS, URIParts, Util
    ].each { |m| include m }

    SOURCE_COMMANDS = [:from, :promql, :row, :show, :ts].freeze

    def initialize
      @query = {}
      @custom = []
      @metadata = []
    end

    # Dinamically define Class methods to allow static instantiation with Source Commands:
    # @see ESQL#from
    # @see PromQL#promql
    # @see Row#row
    # @see Show#show
    # @see TS#ts
    # @example
    #   Elastic::ESQL.from('sample_data')
    #   Elastic::ESQL.row({ a: 1, b: 'two' })
    class << self
      SOURCE_COMMANDS.each do |command|
        define_method(command) do |*params|
          new.send(command, *params)
        end
      end
    end

    # Function to build the ES|QL formatted query and return it as a String.
    # @raise [ArgumentError] if the query has no source command
    # @return [String] The ES|QL query in ES|QL format.
    def query
      raise ArgumentError, 'No source command found' unless source_command_present?

      string_query = @set ? "SET #{@set};\n" : ''
      @query[:enrich] = @enriches.map(&:to_query).join('| ') if @enriches
      @query[:rerank] = @rerank.to_query if @rerank
      string_query.concat(build_string_query)
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

    # Creates a new Rerank object to chain with +on+ and +with+. If other method is chained to the
    # Rerank object, it calls it upon the ESQL object that instantiated it, and returns it.
    # @return [Elastic::Rerank]
    def rerank(column: nil, query: '')
      @rerank = Rerank.new(self, column: column, query: query)
      @rerank
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
    class << self
      def 🐔(message)
        "ROW CHICKEN(\"#{message}\")"
      end
      alias chicken 🐔
    end

    def 🐔(message)
      self.class.🐔(message)
    end
    alias chicken 🐔
    # rubocop:enable Naming/MethodName, Naming/BinaryOperatorParameterName

    def self.branch
      Branch.new
    end

    # Creates a new UserAgent object to chain with +with+. If other method is chained to the
    # UserAgent object, it calls it upon the ESQL object that instantiated it, and returns it.
    # @return [Elastic::UserAgent]
    def user_agent(params)
      UserAgent.new(params, self)
    end

    private

    # Check if there's a source command present in the query
    def source_command_present?
      SOURCE_COMMANDS.map { |c| @query.each_key { |k| return true if k == c } }

      false
    end
  end
end
