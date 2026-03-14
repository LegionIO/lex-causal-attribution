# lex-causal-attribution

Weiner's attribution theory for brain-modeled agentic AI — locus, stability, and controllability.

## What It Does

Models how the agent explains why outcomes occurred. Based on Weiner's attribution theory, every outcome is explained along three dimensions: **locus** (internal = I caused it / external = something else caused it), **stability** (stable = it will happen again / unstable = one-time), and **controllability** (controllable = I could change it / uncontrollable = I couldn't). Each unique combination maps to a specific emotion (guilt, shame, anger, relief, etc.).

## Core Concept: Attribution Dimensions to Emotions

```
internal + stable + controllable → :guilt       (I reliably cause bad outcomes and could stop)
internal + stable + uncontrollable → :shame      (I am a bad agent by nature)
external + stable + controllable → :anger        (they keep doing this and could stop)
external + unstable + uncontrollable → :relief   (it just happened, no one's fault)
```

## Usage

```ruby
client = Legion::Extensions::CausalAttribution::Client.new

# Attribute an outcome
result = client.create_causal_attribution(
  event: 'deployment_failed',
  outcome: :failure,
  domain: :infrastructure,
  locus: :internal,
  stability: :unstable,
  controllability: :controllable
)
# => { attribution: { emotional_response: :regret, ... } }

# Re-examine the attribution with new information
client.reattribute_cause(
  attribution_id: result[:attribution][:id],
  locus: :external   # actually it was a Vault issue, not our code
)
# => { attribution: { emotional_response: :frustration } }

# Check for self-serving bias
client.attribution_bias_assessment
# => { self_serving_bias_detected: true, internal_success_rate: 0.9, external_failure_rate: 0.8 }
```

## Integration

Feed `emotional_response` into lex-emotion after outcome processing. `attribution_bias_assessment` informs lex-anosognosia about evaluation errors. `emotional_attribution_profile` feeds lex-dream's contradiction resolution for examining helplessness patterns.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
