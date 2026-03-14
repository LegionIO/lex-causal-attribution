# frozen_string_literal: true

RSpec.describe Legion::Extensions::CausalAttribution::Helpers::Attribution do
  subject(:attr) do
    described_class.new(
      event:           'task failed',
      outcome:         :failure,
      domain:          :work,
      locus:           :internal,
      stability:       :stable,
      controllability: :controllable
    )
  end

  describe '#initialize' do
    it 'assigns an id' do
      expect(attr.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores all dimensions' do
      expect(attr.locus).to eq(:internal)
      expect(attr.stability).to eq(:stable)
      expect(attr.controllability).to eq(:controllable)
    end

    it 'derives emotional_response from ATTRIBUTION_EMOTIONS' do
      expect(attr.emotional_response).to eq(:guilt)
    end

    it 'uses DEFAULT_CONFIDENCE when none given' do
      expect(attr.confidence).to eq(described_class::DEFAULT_CONFIDENCE)
    end

    it 'clamps confidence to ceiling' do
      high = described_class.new(
        event: 'x', outcome: :success, domain: :test,
        locus: :external, stability: :unstable, controllability: :uncontrollable,
        confidence: 5.0
      )
      expect(high.confidence).to eq(1.0)
    end

    it 'clamps confidence to floor' do
      low = described_class.new(
        event: 'x', outcome: :success, domain: :test,
        locus: :external, stability: :unstable, controllability: :uncontrollable,
        confidence: -1.0
      )
      expect(low.confidence).to eq(0.0)
    end

    it 'records created_at' do
      expect(attr.created_at).to be_a(Time)
    end
  end

  describe '#pattern' do
    it 'returns [locus, stability, controllability] tuple' do
      expect(attr.pattern).to eq(%i[internal stable controllable])
    end
  end

  describe 'predicates' do
    it 'internal? returns true for internal locus' do
      expect(attr.internal?).to be true
      expect(attr.external?).to be false
    end

    it 'stable? returns true for stable stability' do
      expect(attr.stable?).to be true
    end

    it 'controllable? returns true for controllable controllability' do
      expect(attr.controllable?).to be true
    end
  end

  describe 'ATTRIBUTION_EMOTIONS mapping' do
    {
      %i[internal stable controllable]     => :guilt,
      %i[internal stable uncontrollable]   => :shame,
      %i[internal unstable controllable]   => :regret,
      %i[internal unstable uncontrollable] => :surprise,
      %i[external stable controllable]     => :anger,
      %i[external stable uncontrollable]   => :helplessness,
      %i[external unstable controllable]   => :frustration,
      %i[external unstable uncontrollable] => :relief
    }.each do |pattern, emotion|
      it "maps #{pattern.inspect} to #{emotion}" do
        a = described_class.new(
          event: 'e', outcome: :neutral, domain: :test,
          locus: pattern[0], stability: pattern[1], controllability: pattern[2]
        )
        expect(a.emotional_response).to eq(emotion)
      end
    end
  end

  describe '#to_h' do
    it 'includes all required keys' do
      h = attr.to_h
      %i[id event outcome domain locus stability controllability
         confidence emotional_response created_at].each do |key|
        expect(h).to have_key(key)
      end
    end
  end
end
