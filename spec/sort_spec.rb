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

# rubocop:disable Metrics/BlockLength
describe Elastic::ESQL do
  context 'SORT' do
    it 'uses regular sort' do
      expect(
        Elastic::ESQL.from('sample_data').sort('@timestamp').to_s
      ).to eq 'FROM sample_data | SORT @timestamp'
    end

    it 'sorts ascending' do
      expect(
        Elastic::ESQL.from('sample_data').sort('@timestamp').ascending.to_s
      ).to eq 'FROM sample_data | SORT @timestamp ASC'
    end

    it 'sorts descending' do
      expect(
        Elastic::ESQL.from('sample_data').sort('@timestamp').descending.to_s
      ).to eq 'FROM sample_data | SORT @timestamp DESC'
    end

    it 'uses null last' do
      expect(
        Elastic::ESQL.from('sample_data').sort('@timestamp').descending.nulls_last.to_s
      ).to eq 'FROM sample_data | SORT @timestamp DESC NULLS LAST'
    end

    it 'uses null first' do
      expect(
        Elastic::ESQL.from('sample_data').sort('@timestamp').descending.nulls_first.to_s
      ).to eq 'FROM sample_data | SORT @timestamp DESC NULLS FIRST'
    end

    context 'Errors' do
      it 'raises an error when using asc without sorting' do
        expect do
          Elastic::ESQL.from('sample_data').ascending
        end.to raise_error ArgumentError
      end

      it 'raises an error when using desc without sorting' do
        expect do
          Elastic::ESQL.from('sample_data').descending
        end.to raise_error ArgumentError
      end
    end

    context 'Aliases' do
      it 'uses asc alias' do
        expect(
          Elastic::ESQL.from('sample_data').sort('@timestamp').asc.to_s
        ).to eq 'FROM sample_data | SORT @timestamp ASC'
      end

      it 'uses desc alias' do
        expect(
          Elastic::ESQL.from('sample_data').sort('@timestamp').desc.to_s
        ).to eq 'FROM sample_data | SORT @timestamp DESC'
      end

      it 'mutates with desc!' do
        esql = Elastic::ESQL.from('sample_data')
        esql.sort!('@timestamp').desc!
        expect(esql.to_s).to eq 'FROM sample_data | SORT @timestamp DESC'
      end

      it 'mutates with asc!' do
        esql = Elastic::ESQL.from('sample_data')
        esql.sort!('@timestamp').asc!
        expect(esql.to_s).to eq 'FROM sample_data | SORT @timestamp ASC'
      end
    end

    context 'mutating the object' do
      let(:esql) { Elastic::ESQL.from('sample_data') }
      it 'changes the object when using !' do
        esql.sort!('@timestamp').descending!
        expect(esql.to_s).to eq 'FROM sample_data | SORT @timestamp DESC'

        esql.nulls_first!
        expect(esql.to_s).to eq 'FROM sample_data | SORT @timestamp DESC NULLS FIRST'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
