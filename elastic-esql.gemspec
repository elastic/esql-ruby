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

Gem::Specification.new do |s|
  s.name          = 'elastic-esql'
  s.version       = '0.0.1'
  s.authors       = ['Fernando Briano']
  s.summary       = 'Elastic ES|QL Query builder'
  s.license       = 'Apache-2.0'
  s.metadata = {
    'changelog_uri' => 'https://github.com/elastic/esql-ruby/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/elastic/esql-ruby/tree/main',
    'bug_tracker_uri' => 'https://github.com/elastic/esql-ruby/issues'
  }
  s.files         = ['lib/elastic/esql.rb']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.0'
  s.add_development_dependency 'debug', '~> 1' unless defined?(JRUBY_VERSION)
  s.add_development_dependency 'rake', '~> 13'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rubocop', '~> 1.75'
  s.add_development_dependency 'yard', '~> 0.9'
end
