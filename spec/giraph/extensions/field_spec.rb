require 'spec_helper'

describe Giraph::Extensions::Field do
  include_context 'sample graphql structure'

  it 'allows assigned resolver to resolve under regular execution' do
    expect(MockResolver).to receive(:call) do |obj, args, ctx|
      expect(obj).to eq({})
      expect(args[:foo]).to eq('foo value')
      expect(ctx[:bar]).to eq([1, 2])

      # Return a regular object to resolve further
      Struct.new(:res).new(42)
    end

    resp = schema.execute(
      query_string,
      variables: query_variables,
      context: query_context
    )

    expect(resp).to eq('data' => { 'test' => { 'res' => 42 } })
  end

  it 'intercepts resolver if object-in-resolution is a Giraph response' do
    expect(MockResolver).to receive(:call) do |obj, args, ctx|
      expect(obj).to eq({})
      expect(args[:foo]).to eq('foo value')
      expect(ctx[:bar]).to eq([1, 2])

      # Return a Giraph Response object to immitate intercepted remote query
      Giraph::Remote::Response[res: 84]
    end

    resp = schema.execute(
      query_string,
      variables: query_variables,
      context: query_context
    )

    expect(resp).to eq('data' => { 'test' => { 'res' => 84 } })
  end
end
