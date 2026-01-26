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

require 'spec_helper'

describe Elastic::ESQL do
  context 'FORK' do
    it 'builds a fork query' do
      esql = ESQL.from('employees')
                 .fork([
                         FORK.new.where('emp_no == 10001'),
                         FORK.new.where('emp_no == 10002')
                       ])
                 .keep('emp_no', '_fork')
                 .sort('emp_no')
      expect(esql.query).to eq(
        'FROM employees ' \
        '| FORK (WHERE emp_no == 10001) ' \
        '(WHERE emp_no == 10002) ' \
        '| KEEP emp_no, _fork ' \
        '| SORT emp_no'
      )
    end
  end
end
