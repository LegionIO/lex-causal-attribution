# frozen_string_literal: true

require 'legion/extensions/causal_attribution/client'

RSpec.describe Legion::Extensions::CausalAttribution::Runners::CausalAttribution do
  let(:client) { Legion::Extensions::CausalAttribution::Client.new }

  let(:base_args) do
    {
      event:           'missed deadline',
      outcome:         :failure,
      domain:          :work,
      locus:           :internal,
      stability:       :stable,
      controllability: :controllable
    }
  end

  describe '#create_causal_attribution' do
    it 'returns success true' do
      result = client.create_causal_attribution(**base_args)
      expect(result[:success]).to be true
    end

    it 'includes attribution hash' do
      result = client.create_causal_attribution(**base_args)
      expect(result[:attribution]).to have_key(:id)
      expect(result[:attribution][:emotional_response]).to eq(:guilt)
    end

    it 'accepts string locus and coerces to symbol' do
      result = client.create_causal_attribution(**base_args, locus: 'external')
      expect(result[:attribution][:locus]).to eq(:external)
    end
  end

  describe '#reattribute_cause' do
    let!(:id) { client.create_causal_attribution(**base_args)[:attribution][:id] }

    it 'updates the attribution' do
      result = client.reattribute_cause(attribution_id: id, locus: :external)
      expect(result[:success]).to be true
      expect(result[:attribution][:locus]).to eq(:external)
    end

    it 'returns success false for unknown id' do
      result = client.reattribute_cause(attribution_id: 'bad-id')
      expect(result[:success]).to be false
      expect(result[:found]).to be false
    end
  end

  describe '#attributions_by_pattern' do
    before do
      client.create_causal_attribution(**base_args)
      client.create_causal_attribution(**base_args, locus: :external)
    end

    it 'filters by locus' do
      result = client.attributions_by_pattern(locus: :internal)
      expect(result[:count]).to eq(1)
    end

    it 'returns all when no filter given' do
      result = client.attributions_by_pattern
      expect(result[:count]).to eq(2)
    end
  end

  describe '#domain_attributions' do
    before { client.create_causal_attribution(**base_args) }

    it 'returns attributions for domain' do
      result = client.domain_attributions(domain: :work)
      expect(result[:count]).to be >= 1
    end
  end

  describe '#outcome_attributions' do
    before do
      client.create_causal_attribution(**base_args)
      client.create_causal_attribution(**base_args, outcome: :success)
    end

    it 'returns attributions by outcome' do
      result = client.outcome_attributions(outcome: :failure)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#attribution_bias_assessment' do
    before { client.create_causal_attribution(**base_args) }

    it 'returns bias structure' do
      result = client.attribution_bias_assessment
      expect(result[:success]).to be true
      expect(result[:bias]).to have_key(:self_serving_bias_detected)
    end
  end

  describe '#emotional_attribution_profile' do
    before { client.create_causal_attribution(**base_args) }

    it 'returns profile with dominant emotion' do
      result = client.emotional_attribution_profile
      expect(result[:success]).to be true
      expect(result[:profile]).to have_key(:dominant)
    end
  end

  describe '#most_common_attribution' do
    before do
      2.times { client.create_causal_attribution(**base_args) }
    end

    it 'returns the most frequent pattern' do
      result = client.most_common_attribution
      expect(result[:success]).to be true
      expect(result[:count]).to eq(2)
    end
  end

  describe '#update_causal_attribution' do
    before { client.create_causal_attribution(**base_args, confidence: 0.8) }

    it 'decays confidence and reports count' do
      result = client.update_causal_attribution
      expect(result[:success]).to be true
      expect(result[:decayed]).to eq(1)
    end
  end

  describe '#causal_attribution_stats' do
    before { client.create_causal_attribution(**base_args) }

    it 'returns stats hash' do
      result = client.causal_attribution_stats
      expect(result[:success]).to be true
      expect(result[:stats][:total_attributions]).to eq(1)
    end
  end
end
