require 'spec_helper'

describe Giraph::Remote::Response do
  describe '.from_json' do
    let(:sample_json) do
      {
        answer: 42,
        from: {
          type: 'computer',
          name: 'Deep Thought'
        },
        to: 'Ultimate question of...',
        what: [
          {
            question: 'Life'
          },
          {
            prefix: 'the',
            question: 'Universe'
          },
          {
            question: 'Everything'
          }
        ]
      }
    end

    let(:test_input) { sample_json.to_json }
    let(:expected_output) { sample_json }

    it 'parses JSON using Response hashes recursively' do
      # This is to allow each resolver down stream to
      # recognize a remote GraphQL response and act accordingly.

      result = described_class.from_json(test_input)

      expect(result).to eq(expected_output)

      expect(result).to be_instance_of(described_class)
      expect(result[:from]).to be_instance_of(described_class)
      result[:what].each do |rec|
        expect(rec).to be_instance_of(described_class)
      end

      expect(result[:answer]).to_not be_instance_of(described_class)
      expect(result[:to]).to_not be_instance_of(described_class)
      expect(result[:what]).to_not be_instance_of(described_class)
    end
  end
end
