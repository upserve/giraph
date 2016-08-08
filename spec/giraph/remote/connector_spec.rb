require 'spec_helper'

describe Giraph::Remote::Connector do
  describe '.resolve' do
    let(:response) do
      double(
        Net::HTTPResponse,
        body: response_body,
        code: response_code,
        msg: response_msg
      )
    end

    let(:mock_context) { double(GraphQL::Query::Context, ast_node: 'AST_NODE') }

    let(:response_body) { '{ "data": { "foo": { "bar": [1, 2] } } }' }
    let(:response_code) { 201 }
    let(:response_msg) { 'Created' }

    let(:query_string) { 'query GiraphQuery($foo: Int) { bar(baz: $foo) }' }
    let(:query_variables) { '{ "foo": 100 }' }

    subject { described_class.new('some_remote_host') }

    it 'sends over the query, parses the response, returns relevant parts' do
      expect(Net::HTTP).to receive(:post_form).and_return(response)

      result = subject.resolve(mock_context, query_string, query_variables)

      expect(result).to eq(foo: { bar: [1, 2] })
    end

    context 'when remote returns GraphQL errors' do
      let(:response_body) do
        '{"errors":[{"message":"FOOL!","locations":[{"line":18,"column":9}]}]}'
      end

      it 'rasises the error for parent as a GraphQL error' do
        expect(Net::HTTP).to receive(:post_form).and_return(response)

        expect do
          subject.resolve(mock_context, query_string, query_variables)
        end.to raise_error(GraphQL::ExecutionError, /FOOL!/)
      end
    end

    context 'when remote returns invalid response' do
      let(:response_body) do
        '--NOT A JSON--'
      end

      let(:response_code) { 500 }
      let(:response_msg) { 'Bad, bad server!' }

      it 'rasises the error for parent as a GraphQL error' do
        expect(Net::HTTP).to receive(:post_form).and_return(response)

        expect do
          subject.resolve(mock_context, query_string, query_variables)
        end.to raise_error(
          Giraph::Remote::InvalidResponse,
          "Remote endpoint returned: '500 Bad, bad server!'"
        )
      end
    end
  end
end
