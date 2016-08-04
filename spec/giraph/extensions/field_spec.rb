require 'spec_helper'

describe Giraph::Extensions::Field do
  include_context 'sample graphql structure'

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
      context: query_context
    )

    expect(resp).to eq('data' => { 'test' => 42 })
  end

  it 'intercepts resolver if object-in-resolution is a Giraph response' do
    expect(MockResolver).to_not receive(:call)

    resp = schema.execute(
      query_string,
      variables: query_variables,
      context: query_context,
      root_value: giraph_response
    )

    expect(resp).to eq('data' => { 'test' => 84 })
  end
end
