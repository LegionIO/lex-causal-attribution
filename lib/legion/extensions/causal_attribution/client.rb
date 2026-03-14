# frozen_string_literal: true

require 'legion/extensions/causal_attribution/helpers/attribution'
require 'legion/extensions/causal_attribution/helpers/attribution_engine'
require 'legion/extensions/causal_attribution/runners/causal_attribution'

module Legion
  module Extensions
    module CausalAttribution
      class Client
        include Runners::CausalAttribution

        def initialize(**)
          @engine = Helpers::AttributionEngine.new
        end

        private

        attr_reader :engine
      end
    end
  end
end
