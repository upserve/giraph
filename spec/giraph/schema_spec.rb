require 'spec_helper'

describe Giraph::Schema do
  include_context 'sample graphql structure'

  it 'sets root_value to empty hash by default' do
    expect(MockResolver).to receive(:call) do |obj, args, ctx|
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

    expect(resp).to eq('data' => { 'test' => { 'res' => 126 } })
  end

  context 'given Giraph root value from remote parent' do
    let(:query_variables) do
      {
        'baz' => 'foo value',
        '__giraph_root__' => {
          'hello' => 'world',
          'what?' => {
            'answer' => 42,
            'for' => ['question', 10.3]
          }
        }
      }
    end

    it 'sets the Giraph root from parent as root_value' do
      expect(MockResolver).to receive(:call) do |obj, args, ctx|
        expect(obj).to eq(
          'hello' => 'world',
          'what?' => {
            'answer' => 42,
            'for' => ['question', 10.3]
          }
        )
        expect(args[:foo]).to eq('foo value')
        expect(ctx[:bar]).to eq([1, 2])

        Struct.new(:res).new(126)
      end

      resp = schema.execute(
        query_string,
        variables: query_variables,
        context: query_context
      )

      expect(resp).to eq('data' => { 'test' => { 'res' => 126 } })
    end
  end
end
