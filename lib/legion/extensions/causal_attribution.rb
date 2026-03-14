# frozen_string_literal: true

require 'legion/extensions/causal_attribution/version'
require 'legion/extensions/causal_attribution/helpers/attribution'
require 'legion/extensions/causal_attribution/helpers/attribution_engine'
require 'legion/extensions/causal_attribution/runners/causal_attribution'

module Legion
  module Extensions
    module CausalAttribution
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
