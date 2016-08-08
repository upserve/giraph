require 'spec_helper'

describe Giraph::Remote::Query do
  include_context 'sample graphql structure'

  let(:connector) { double(Giraph::Remote::Connector) }
  let(:subquery) { double(Giraph::Subquery) }

  let(:subquery_string) { 'GiraphQuery { bar { baz } }' }
  let(:variable_string) { '{ "foo": 1000 }' }

  let(:object) { { some: 'object' } }
  let(:args) { { some: 'args' } }
  let(:context) { { some: 'context' } }

  before do
    allow(Giraph::Subquery).to receive(:new).and_return(subquery)

    allow(subquery).to receive(:subquery_string).and_return(subquery_string)
    allow(subquery).to receive(:variable_string).and_return(variable_string)
  end

  context 'given an evaluator block' do
    subject { described_class.new('endpoint', connector, &evaluator) }

    let(:evaluator) { -> (o, a, c) { evaluator_response } }

    context 'that returns data' do
      let(:evaluator_response) { { foo: :bar } }

      it 'calls the block before resolving' do
        expect(connector)
          .to receive(:resolve)
          .with(
            { some: 'context' },
            "query #{subquery_string}",
            variable_string
          )
          .and_return(good: 'data')

        expect(subject.call(object, args, context)).to eq(good: 'data')
      end
    end

    context 'that returns falsy' do
      let(:evaluator_response) { nil }

      it 'does not let the request continue' do
        expect(connector).to_not receive(:resolve)

        expect(subject.call(object, args, context)).to_not be
      end
    end
  end

  context 'given no evaluator block' do
    subject { described_class.new('endpoint', connector) }

    it 'calls the default evaluator' do
      expect(connector)
        .to receive(:resolve)
        .with(
        { some: 'context' },
        "query #{subquery_string}",
        variable_string
      )
        .and_return(good: 'data')

      expect(subject.call(object, args, context)).to eq(good: 'data')
    end
  end
end
