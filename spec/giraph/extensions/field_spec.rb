require 'spec_helper'

describe Giraph::Extensions::Field do
  class MockResolver; end

  let(:schema) do
    GraphQL::Schema.new(
      query: query_root,
      # mutation: mutation_root
    )
  end

  let(:query_root) do
    GraphQL::ObjectType.define do
      name 'Query'

      field :test do
        type types.Int
        argument :foo, types.String
        resolve MockResolver
      end
    end
  end

  let(:some_context) do
    {
      bar: [1, 2]
    }
  end

  let(:query_string) do
    '{ test(foo: "foo value") }'
  end

  let(:query_variables) do
    {}
  end

  let(:giraph_response) do
    Giraph::Remote::Response[test: 84]
  end

  it 'allows assigned resolver to resolve under regular execution' do
    expect(MockResolver).to receive(:call) do |obj, args, ctx|
      expect(obj).to eq(nil)
      expect(args[:foo]).to eq('foo value')
      expect(ctx[:bar]).to eq([1, 2])

      42
    end

    resp = schema.execute(
      query_string,
      variables: query_variables,
      context: some_context
    )

    expect(resp).to eq('data' => { 'test' => 42 })
  end

  it 'intercepts resolver if object-in-resolution is a Giraph response' do
    expect(MockResolver).to_not receive(:call)

    resp = schema.execute(
      query_string,
      variables: query_variables,
      context: some_context,
      root_value: giraph_response
    )

    expect(resp).to eq('data' => { 'test' => 84 })
  end
end
