# frozen_string_literal: true

module Legion
  module Extensions
    module CausalAttribution
      module Runners
        module CausalAttribution
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_causal_attribution(event:, outcome:, domain:, locus:, stability:, controllability:,
                                        confidence: nil, **)
            conf = (confidence || Helpers::Attribution::DEFAULT_CONFIDENCE)
                   .clamp(Helpers::Attribution::CONFIDENCE_FLOOR, Helpers::Attribution::CONFIDENCE_CEILING)
            attr = engine.create_attribution(
              event:           event,
              outcome:         outcome,
              domain:          domain,
              locus:           locus.to_sym,
              stability:       stability.to_sym,
              controllability: controllability.to_sym,
              confidence:      conf
            )
            Legion::Logging.info "[causal_attribution] create id=#{attr.id} event=#{event} " \
                                 "outcome=#{outcome} locus=#{locus} emotion=#{attr.emotional_response}"
            { success: true, attribution: attr.to_h }
          end

          def reattribute_cause(attribution_id:, locus: nil, stability: nil, controllability: nil, **)
            result = engine.reattribute(
              attribution_id:  attribution_id,
              locus:           locus&.to_sym,
              stability:       stability&.to_sym,
              controllability: controllability&.to_sym
            )
            if result.is_a?(Hash) && result[:found] == false
              Legion::Logging.warn "[causal_attribution] reattribute not_found id=#{attribution_id}"
              return { success: false, attribution_id: attribution_id, found: false }
            end

            Legion::Logging.debug "[causal_attribution] reattribute id=#{attribution_id} " \
                                  "locus=#{result.locus} emotion=#{result.emotional_response}"
            { success: true, attribution: result.to_h }
          end

          def attributions_by_pattern(locus: nil, stability: nil, controllability: nil, **)
            results = engine.by_pattern(
              locus:           locus&.to_sym,
              stability:       stability&.to_sym,
              controllability: controllability&.to_sym
            )
            Legion::Logging.debug "[causal_attribution] by_pattern count=#{results.size}"
            { success: true, attributions: results.map(&:to_h), count: results.size }
          end

          def domain_attributions(domain:, **)
            results = engine.by_domain(domain: domain.to_sym)
            Legion::Logging.debug "[causal_attribution] by_domain domain=#{domain} count=#{results.size}"
            { success: true, attributions: results.map(&:to_h), count: results.size }
          end

          def outcome_attributions(outcome:, **)
            results = engine.by_outcome(outcome: outcome.to_sym)
            Legion::Logging.debug "[causal_attribution] by_outcome outcome=#{outcome} count=#{results.size}"
            { success: true, attributions: results.map(&:to_h), count: results.size }
          end

          def attribution_bias_assessment(**)
            bias = engine.attribution_bias
            Legion::Logging.debug "[causal_attribution] bias_assessment self_serving=#{bias[:self_serving_bias_detected]}"
            { success: true, bias: bias }
          end

          def emotional_attribution_profile(**)
            profile = engine.emotional_profile
            Legion::Logging.debug "[causal_attribution] emotional_profile dominant=#{profile[:dominant]} total=#{profile[:total]}"
            { success: true, profile: profile }
          end

          def most_common_attribution(**)
            result = engine.most_common_pattern
            Legion::Logging.debug "[causal_attribution] most_common pattern=#{result[:pattern].inspect} count=#{result[:count]}"
            { success: true, pattern: result[:pattern], count: result[:count] }
          end

          def update_causal_attribution(**)
            decayed = engine.decay_all
            Legion::Logging.debug "[causal_attribution] decay cycle entries=#{decayed}"
            { success: true, decayed: decayed }
          end

          def causal_attribution_stats(**)
            stats = engine.to_h
            Legion::Logging.debug "[causal_attribution] stats total=#{stats[:total_attributions]}"
            { success: true, stats: stats }
          end

          private

          def engine
            @engine ||= Helpers::AttributionEngine.new
          end
        end
      end
    end
  end
end
