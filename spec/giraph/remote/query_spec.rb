require 'spec_helper'

describe Giraph::Remote::Query do
  include_context 'sample graphql structure'

  let(:connector) { double(Giraph::Remote::Connector) }

  let(:object) { { some: 'object' } }
  let(:args) { { some: 'args' } }
  let(:context) { { some: 'context' } }

  context 'given an evaluator block' do
    subject { described_class.new('endpoint', connector, &evaluator) }

    let(:evaluator) { -> (o, a, c) { evaluator_response } }

    context 'that returns data' do
      let(:evaluator_response) { { foo: :bar } }

      it 'calls the block before resolving' do
        expect(connector)
          .to receive(:resolve)
          .with({ some: 'context' }, remote_root: { foo: :bar })
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
        .with({ some: 'context' }, remote_root: {})
        .and_return(good: 'data')

      expect(subject.call(object, args, context)).to eq(good: 'data')
    end
  end
end
