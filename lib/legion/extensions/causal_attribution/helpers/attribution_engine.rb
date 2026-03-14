# frozen_string_literal: true

module Legion
  module Extensions
    module CausalAttribution
      module Helpers
        class AttributionEngine
          def initialize
            @attributions = {}
            @history      = []
          end

          def create_attribution(event:, outcome:, domain:, locus:, stability:, controllability:,
                                 confidence: Attribution::DEFAULT_CONFIDENCE)
            trim_if_needed
            attribution = Attribution.new(
              event:           event,
              outcome:         outcome,
              domain:          domain,
              locus:           locus,
              stability:       stability,
              controllability: controllability,
              confidence:      confidence
            )
            @attributions[attribution.id] = attribution
            attribution
          end

          def reattribute(attribution_id:, locus: nil, stability: nil, controllability: nil)
            attr = @attributions[attribution_id]
            return { found: false, attribution_id: attribution_id } unless attr

            new_locus           = locus           || attr.locus
            new_stability       = stability       || attr.stability
            new_controllability = controllability || attr.controllability

            updated = Attribution.new(
              event:           attr.event,
              outcome:         attr.outcome,
              domain:          attr.domain,
              locus:           new_locus,
              stability:       new_stability,
              controllability: new_controllability,
              confidence:      attr.confidence
            )
            @history << attr.to_h if @history.size < Attribution::MAX_HISTORY
            @attributions[attribution_id] = updated
            updated
          end

          def by_pattern(locus: nil, stability: nil, controllability: nil)
            @attributions.values.select do |a|
              (locus.nil? || a.locus == locus) &&
                (stability.nil?       || a.stability == stability) &&
                (controllability.nil? || a.controllability == controllability)
            end
          end

          def by_domain(domain:)
            @attributions.values.select { |a| a.domain == domain }
          end

          def by_outcome(outcome:)
            @attributions.values.select { |a| a.outcome == outcome }
          end

          def attribution_bias
            return { bias: :none, detail: 'no attributions' } if @attributions.empty?

            all     = @attributions.values
            total   = all.size.to_f
            locus   = bias_ratio(all, :locus, :external, total)
            stab    = bias_ratio(all, :stability, :stable, total)
            control = bias_ratio(all, :controllability, :uncontrollable, total)

            failures = all.select { |a| a.outcome == :failure }
            external_failure_ratio = failures.empty? ? 0.0 : failures.count(&:external?).to_f / failures.size

            {
              external_locus_ratio:       locus.round(3),
              stable_ratio:               stab.round(3),
              uncontrollable_ratio:       control.round(3),
              external_failure_ratio:     external_failure_ratio.round(3),
              self_serving_bias_detected: external_failure_ratio > 0.6,
              total_attributions:         @attributions.size
            }
          end

          def emotional_profile
            counts = Hash.new(0)
            @attributions.each_value { |a| counts[a.emotional_response] += 1 if a.emotional_response }
            total = counts.values.sum.to_f
            profile = counts.transform_values { |v| (v / total).round(3) }
            dominant = counts.max_by { |_, v| v }&.first
            { distribution: profile, dominant: dominant, total: counts.values.sum }
          end

          def most_common_pattern
            return { pattern: nil, count: 0 } if @attributions.empty?

            grouped = @attributions.values.group_by(&:pattern)
            best    = grouped.max_by { |_, attrs| attrs.size }
            { pattern: best[0], count: best[1].size }
          end

          def decay_all
            decayed = 0
            @attributions.each_value do |a|
              new_conf = (a.confidence - Attribution::DECAY_RATE).clamp(
                Attribution::CONFIDENCE_FLOOR, Attribution::CONFIDENCE_CEILING
              )
              a.instance_variable_set(:@confidence, new_conf)
              decayed += 1
            end
            decayed
          end

          def count
            @attributions.size
          end

          def to_h
            {
              total_attributions: @attributions.size,
              history_size:       @history.size,
              outcome_counts:     outcome_counts,
              locus_counts:       locus_counts
            }
          end

          private

          def trim_if_needed
            return unless @attributions.size >= Attribution::MAX_ATTRIBUTIONS

            oldest_key = @attributions.min_by { |_, a| a.created_at }&.first
            @attributions.delete(oldest_key)
          end

          def bias_ratio(all, dimension, value, total)
            all.count { |a| a.public_send(dimension) == value } / total
          end

          def outcome_counts
            @attributions.values.group_by(&:outcome).transform_values(&:size)
          end

          def locus_counts
            @attributions.values.group_by(&:locus).transform_values(&:size)
          end
        end
      end
    end
  end
end
