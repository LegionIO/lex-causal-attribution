# frozen_string_literal: true

RSpec.describe Legion::Extensions::CausalAttribution::Helpers::AttributionEngine do
  subject(:engine) { described_class.new }

  let(:basic_args) do
    {
      event:           'task completed',
      outcome:         :success,
      domain:          :work,
      locus:           :internal,
      stability:       :stable,
      controllability: :controllable
    }
  end

  describe '#create_attribution' do
    it 'returns an Attribution object' do
      result = engine.create_attribution(**basic_args)
      expect(result).to be_a(Legion::Extensions::CausalAttribution::Helpers::Attribution)
    end

    it 'stores the attribution' do
      engine.create_attribution(**basic_args)
      expect(engine.count).to eq(1)
    end

    it 'accepts optional confidence' do
      attr = engine.create_attribution(**basic_args, confidence: 0.9)
      expect(attr.confidence).to eq(0.9)
    end
  end

  describe '#reattribute' do
    let!(:attr) { engine.create_attribution(**basic_args) }

    it 'updates locus when provided' do
      result = engine.reattribute(attribution_id: attr.id, locus: :external)
      expect(result.locus).to eq(:external)
    end

    it 'preserves unchanged dimensions' do
      result = engine.reattribute(attribution_id: attr.id, locus: :external)
      expect(result.stability).to eq(:stable)
      expect(result.controllability).to eq(:controllable)
    end

    it 'updates the emotional_response after reattribution' do
      result = engine.reattribute(attribution_id: attr.id, locus: :external)
      expect(result.emotional_response).to eq(:anger)
    end

    it 'returns not found hash for unknown id' do
      result = engine.reattribute(attribution_id: 'nonexistent')
      expect(result[:found]).to be false
    end
  end

  describe '#by_pattern' do
    before do
      engine.create_attribution(**basic_args)
      engine.create_attribution(**basic_args, locus: :external)
    end

    it 'filters by locus' do
      results = engine.by_pattern(locus: :internal)
      expect(results.size).to eq(1)
      expect(results.first.locus).to eq(:internal)
    end

    it 'returns all when no filter given' do
      expect(engine.by_pattern.size).to eq(2)
    end
  end

  describe '#by_domain' do
    before do
      engine.create_attribution(**basic_args)
      engine.create_attribution(**basic_args, domain: :personal)
    end

    it 'returns only matching domain' do
      results = engine.by_domain(domain: :work)
      expect(results.size).to eq(1)
    end
  end

  describe '#by_outcome' do
    before do
      engine.create_attribution(**basic_args)
      engine.create_attribution(**basic_args, outcome: :failure)
    end

    it 'returns only matching outcome' do
      results = engine.by_outcome(outcome: :failure)
      expect(results.size).to eq(1)
    end
  end

  describe '#attribution_bias' do
    it 'returns bias hash with detection key' do
      engine.create_attribution(**basic_args)
      result = engine.attribution_bias
      expect(result).to have_key(:self_serving_bias_detected)
      expect(result).to have_key(:external_failure_ratio)
    end

    it 'detects self-serving bias when failures are mostly external' do
      3.times do
        engine.create_attribution(**basic_args, outcome: :failure, locus: :external, stability: :unstable, controllability: :controllable)
      end
      result = engine.attribution_bias
      expect(result[:self_serving_bias_detected]).to be true
    end

    it 'returns no attributions message when empty' do
      result = engine.attribution_bias
      expect(result[:bias]).to eq(:none)
    end
  end

  describe '#emotional_profile' do
    before do
      engine.create_attribution(**basic_args)
      engine.create_attribution(**basic_args, locus: :external, stability: :unstable)
    end

    it 'returns distribution and dominant' do
      result = engine.emotional_profile
      expect(result).to have_key(:distribution)
      expect(result).to have_key(:dominant)
      expect(result[:total]).to eq(2)
    end
  end

  describe '#most_common_pattern' do
    before do
      2.times { engine.create_attribution(**basic_args) }
      engine.create_attribution(**basic_args, locus: :external)
    end

    it 'returns the most frequent pattern' do
      result = engine.most_common_pattern
      expect(result[:pattern]).to eq(%i[internal stable controllable])
      expect(result[:count]).to eq(2)
    end

    it 'returns nil pattern when empty' do
      expect(described_class.new.most_common_pattern[:pattern]).to be_nil
    end
  end

  describe '#decay_all' do
    it 'reduces confidence on all attributions' do
      engine.create_attribution(**basic_args, confidence: 0.8)
      engine.decay_all
      expect(engine.by_pattern.first.confidence).to be < 0.8
    end

    it 'returns count of decayed entries' do
      2.times { engine.create_attribution(**basic_args) }
      expect(engine.decay_all).to eq(2)
    end

    it 'floors at CONFIDENCE_FLOOR' do
      attr = engine.create_attribution(**basic_args, confidence: 0.001)
      engine.decay_all
      expect(attr.confidence).to be >= Legion::Extensions::CausalAttribution::Helpers::Attribution::CONFIDENCE_FLOOR
    end
  end

  describe '#to_h' do
    it 'includes stats keys' do
      engine.create_attribution(**basic_args)
      h = engine.to_h
      expect(h).to have_key(:total_attributions)
      expect(h).to have_key(:outcome_counts)
      expect(h).to have_key(:locus_counts)
    end
  end
end
