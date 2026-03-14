# frozen_string_literal: true

require 'legion/extensions/causal_attribution/client'

RSpec.describe Legion::Extensions::CausalAttribution::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    %i[
      create_causal_attribution
      reattribute_cause
      attributions_by_pattern
      domain_attributions
      outcome_attributions
      attribution_bias_assessment
      emotional_attribution_profile
      most_common_attribution
      update_causal_attribution
      causal_attribution_stats
    ].each do |method|
      expect(client).to respond_to(method)
    end
  end
end
