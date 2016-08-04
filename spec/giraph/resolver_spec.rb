require 'spec_helper'

describe Giraph::Resolver do
  include_context 'sample graphql structure'

  let(:query_string) do
    'query Test($baz: String) { proxy(foo: $baz) { res } }'
  end

  it 'calls requested method on given resolver object at resolution time' do
    expect(query_resolver).to receive(:resolver_method) do |obj, args, ctx|
      expect(obj).to eq({})
      expect(args[:foo]).to eq('foo value')
      expect(ctx[:bar]).to eq([1, 2])

      Struct.new(:res).new(126)
    end

    resp = schema.execute(
      query_string,
      variables: query_variables,
      context: query_context
    )

    expect(resp).to eq('data' => { 'proxy' => { 'res' => 126 } })
  end
end
