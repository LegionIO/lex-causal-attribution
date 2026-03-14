# lex-causal-attribution

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Weiner's attribution theory for brain-modeled agentic AI — locus, stability, controllability. Models how the agent explains why outcomes occurred using three causal dimensions: locus (internal vs external), stability (stable vs unstable), and controllability (controllable vs uncontrollable). Each combination maps to a distinct emotional response.

## Gem Info

- **Gem name**: `lex-causal-attribution`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::CausalAttribution`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/causal_attribution/
  causal_attribution.rb         # Main extension module
  version.rb                    # VERSION = '0.1.0'
  client.rb                     # Client wrapper
  helpers/
    attribution.rb              # Attribution value object + all constants + emotion map
    attribution_engine.rb       # AttributionEngine — manages attributions, bias detection
  runners/
    causal_attribution.rb       # Runner module with 9 public methods
spec/
  (spec files)
```

## Key Constants (in `Helpers::Attribution`)

```ruby
MAX_ATTRIBUTIONS      = 200
MAX_HISTORY           = 300
LOCUS_VALUES          = %i[internal external]
STABILITY_VALUES      = %i[stable unstable]
CONTROLLABILITY_VALUES = %i[controllable uncontrollable]
DEFAULT_CONFIDENCE    = 0.5
CONFIDENCE_FLOOR      = 0.0
CONFIDENCE_CEILING    = 1.0
DECAY_RATE            = 0.02

ATTRIBUTION_EMOTIONS = {
  %i[internal stable controllable]     => :guilt,
  %i[internal stable uncontrollable]   => :shame,
  %i[internal unstable controllable]   => :regret,
  %i[internal unstable uncontrollable] => :surprise,
  %i[external stable controllable]     => :anger,
  %i[external stable uncontrollable]   => :helplessness,
  %i[external unstable controllable]   => :frustration,
  %i[external unstable uncontrollable] => :relief
}
```

## Runners

### `Runners::CausalAttribution`

All methods delegate to a private `@engine` (`Helpers::AttributionEngine` instance).

- `create_causal_attribution(event:, outcome:, domain:, locus:, stability:, controllability:, confidence: nil)` — create an attribution; derives emotional_response from the dimension pattern
- `reattribute_cause(attribution_id:, locus: nil, stability: nil, controllability: nil)` — change one or more causal dimensions; recalculates emotional response
- `attributions_by_pattern(locus: nil, stability: nil, controllability: nil)` — filter attributions by any combination of dimensions
- `domain_attributions(domain:)` — all attributions in a domain
- `outcome_attributions(outcome:)` — all attributions for a specific outcome type
- `attribution_bias_assessment` — detect self-serving attribution bias (tendency to attribute successes internally, failures externally)
- `emotional_attribution_profile` — distribution of emotional responses across all attributions
- `most_common_attribution` — most frequent pattern (locus, stability, controllability) and count
- `update_causal_attribution` — decay all attributions
- `causal_attribution_stats` — stats hash

## Helpers

### `Helpers::AttributionEngine`
Core engine. `attribution_bias` detects self-serving bias by checking whether success attributions skew internal and failure attributions skew external. `emotional_profile` aggregates emotional responses to find dominant patterns. `most_common_pattern` finds the most frequent `[locus, stability, controllability]` combination.

### `Helpers::Attribution`
Value object. `pattern` returns `[locus, stability, controllability]`. `emotional_response` is computed at initialization from `ATTRIBUTION_EMOTIONS` hash lookup. Includes `internal?`, `external?`, `stable?`, `controllable?` predicates.

## Integration Points

No constants.rb (constants are defined directly in the Attribution class). No actor defined. This extension bridges outcome events and emotional responses: after lex-agency records an outcome, use causal attribution to explain why it happened and derive the associated emotion. Feed the emotional_response into lex-emotion for valence updating. `attribution_bias_assessment` informs lex-anosognosia about systematic self-evaluation errors. `emotional_attribution_profile` feeds into lex-dream's contradiction_resolution for examining patterns of self-blame or helplessness.

## Development Notes

- Constants are in `Helpers::Attribution` (the value object class), not a separate constants module — unique among this group of extensions
- `reattribute_cause` with all-nil arguments is effectively a no-op but valid
- Self-serving bias detection compares internal-attribution rate for successes vs external-attribution rate for failures — if both are above 50%, bias is flagged
- `ATTRIBUTION_EMOTIONS` covers all 8 combinations of the three binary dimensions
