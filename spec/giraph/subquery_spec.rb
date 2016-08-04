require 'spec_helper'

describe Giraph::Subquery do
  include_context 'sample graphql structure'

  context 'given a valid query' do
    let(:query_string) do
      %(
        query Test($baz: String, $bazzz: String!) {
          remote {
            argd(arg1: $bazzz)
          }

          proxy(foo: $baz) {
            res
          }
        }
      )
    end

    let(:query_variables) do
      {
        'baz' => 'unrelated',
        'bazzz' => 'what we want'
      }
    end

    it 'extracts the subquery correctly' do
      expect(MockResolver).to receive(:call) do |_, _, ctx|
        subq = described_class.new(ctx)

        # Only sub-query relevant arguments are declared!
        expect(subq.subquery_string.tr("\n", ' ').gsub(/\s+/, ' ')).to eq(
          'GiraphQuery ($bazzz: String!) { argd(arg1: $bazzz) }'
        )

        # But all variables are passed on as is
        expect(subq.variable_string).to eq(
          '{"baz":"unrelated","bazzz":"what we want"}'
        )

        Struct.new(:argd).new(168)
      end

      expect(query_resolver)
        .to receive(:resolver_method)
        .and_return(Struct.new(:res).new(126))

      resp = schema.execute(
        query_string,
        variables: query_variables,
        context: query_context
      )

      expect(resp).to eq(
        'data' => {
          'remote' => { 'argd' => 10 },
          'proxy' => { 'res' => 126 }
        }
      )
    end
  end

  context 'given a valid mutation' do
    let(:mutation_string) do
      %(
        mutation Test($baz: input_type!) {
          remote {
            update(input: $baz)
          }
        }
      )
    end

    let(:mutation_variables) do
      {
        'baz' => { 'foo' => 'foo value', 'bar' => 42 }
      }
    end

    it 'extracts the subquery correctly' do
      expect(MockResolver).to receive(:call) do |_, _, ctx|
        subq = described_class.new(ctx)

        # Only sub-query relevant arguments are declared!
        expect(subq.subquery_string.tr("\n", ' ').gsub(/\s+/, ' ')).to eq(
          'GiraphQuery ($baz: input_type!) { update(input: $baz) }'
        )

        # But all variables are passed on as is
        expect(subq.variable_string).to eq(
          '{"baz":{"foo":"foo value","bar":42}}'
        )

        Struct.new(:argd).new(168)
      end

      expect(mutation_resolver)
        .to receive(:update)
        .and_return(126)

      resp = schema.execute(
        mutation_string,
        variables: mutation_variables,
        context: query_context
      )

      expect(resp).to eq('data' => {'remote' => { 'update' => 126 } })
    end
  end
end
