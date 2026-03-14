# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CausalAttribution
      module Helpers
        class Attribution
          MAX_ATTRIBUTIONS = 200
          MAX_HISTORY      = 300

          LOCUS_VALUES           = %i[internal external].freeze
          STABILITY_VALUES       = %i[stable unstable].freeze
          CONTROLLABILITY_VALUES = %i[controllable uncontrollable].freeze

          DEFAULT_CONFIDENCE  = 0.5
          CONFIDENCE_FLOOR    = 0.0
          CONFIDENCE_CEILING  = 1.0
          DECAY_RATE          = 0.02

          ATTRIBUTION_EMOTIONS = {
            %i[internal stable controllable]     => :guilt,
            %i[internal stable uncontrollable]   => :shame,
            %i[internal unstable controllable]   => :regret,
            %i[internal unstable uncontrollable] => :surprise,
            %i[external stable controllable]     => :anger,
            %i[external stable uncontrollable]   => :helplessness,
            %i[external unstable controllable]   => :frustration,
            %i[external unstable uncontrollable] => :relief
          }.freeze

          attr_reader :id, :event, :outcome, :domain, :locus, :stability, :controllability,
                      :confidence, :emotional_response, :created_at

          def initialize(event:, outcome:, domain:, locus:, stability:, controllability:,
                         confidence: DEFAULT_CONFIDENCE)
            @id                = SecureRandom.uuid
            @event             = event
            @outcome           = outcome
            @domain            = domain
            @locus             = locus
            @stability         = stability
            @controllability   = controllability
            @confidence        = confidence.clamp(CONFIDENCE_FLOOR, CONFIDENCE_CEILING)
            @emotional_response = ATTRIBUTION_EMOTIONS[pattern]
            @created_at        = Time.now.utc
          end

          def pattern
            [locus, stability, controllability]
          end

          def internal?
            locus == :internal
          end

          def external?
            locus == :external
          end

          def stable?
            stability == :stable
          end

          def controllable?
            controllability == :controllable
          end

          def to_h
            {
              id:                 id,
              event:              event,
              outcome:            outcome,
              domain:             domain,
              locus:              locus,
              stability:          stability,
              controllability:    controllability,
              confidence:         confidence,
              emotional_response: emotional_response,
              created_at:         created_at
            }
          end
        end
      end
    end
  end
end
