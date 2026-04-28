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
  # The USER_AGENT processing command parses a user-agent string and extracts its components (name,
  # version, OS, device) into new columns.
  class UserAgent
    # @param params [Hash] +{ prefix: expression }+. +prefix+: The prefix for the output columns. The
    #                      extracted components are available as prefix.component.
    #                      +expression+ - The string expression containing the user-agent string to
    #                      parse.
    # @example
    #   esql.from('weblogs').user_agent(ua: 'user_agent')
    #   esql.row(input: 'Mozilla/5.0').user_agent(ua: 'input').with(extract_device_type: true)
    #   esql.from('weblogs').user_agent(ua: 'user_agent').with(regex_file: 'my-regexes.yml')
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/user-agent
    def initialize(params, esql)
      unless params.is_a?(Hash) && params.keys.size == 1
        raise ArgumentError,
              'params needs to be a Hash with one pair of key, value'
      end

      @query = params.shift.join(" = ")
      @esql = esql
    end

    # @param regex_file [String] The name of the parser configuration to use. Default: _default_,
    #                            which uses the built-in regexes from uap-core. To use a custom
    #                            regex file, place a .yml file in the config/user-agent directory on
    #                            each node before starting Elasticsearch. The file must be present
    #                            at node startup; changes or new files added while the node is
    #                            running have no effect. Pass the filename (including the .yml
    #                            extension) as the value. Custom regex files are typically variants
    #                            of the default, either a more recent uap-core release or a
    #                            customized version.
    # @param extract_device_type [Boolean] When true, extracts device type (e.g., Desktop, Phone,
    #                                      Tablet) on a best-effort basis and includes
    #                                      prefix.device.type in the output. Default: false.
    # @param properties [Array] List of property groups to include in the output. Each value expands
    #                           to one or more columns:
    #                            name → prefix.name;
    #                            version → prefix.version;
    #                            os → prefix.os.name, prefix.os.version, prefix.os.full;
    #                            device → prefix.device.name (and prefix.device.type when
    #                            extract_device_type is true).
    #                           Default: ["name", "version", "os", "device"]. You can pass a subset
    #                           to reduce output columns.
    def with(regex_file: nil, extract_device_type: nil, properties: nil)
      with = []
      with << "\"properties\": [#{properties.map { |p| "\"#{p}\"" }.join(', ')}]" if properties
      with << "\"regex_file\": \"#{regex_file}\"" if regex_file
      with << "\"extract_device_type\": #{extract_device_type}" if extract_device_type
      @with = "WITH { #{with.join(', ')} }"
      self
    end

    private

    # Sets +@query[:user_agent]+ in +@esql+ when calling a method that's not +new+ or +with+.
    def method_missing(name, *args)
      @esql.instance_variable_get('@query')[:user_agent] = to_query
      @esql.send(name, *args)
    end

    def respond_to_missing?(method_name, *args)
      super
    end

    def to_query
      query = [@query]
      query << @with if @with
      query.join(' ')
    end
  end
end
