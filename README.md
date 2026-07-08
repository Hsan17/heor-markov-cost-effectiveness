# Health Economic Decision Model — Markov Cost-Effectiveness Simulation

A cohort-level Markov model built in R (`heemod`) comparing two treatment strategies for a chronic disease, estimating costs, QALYs, and the incremental cost-effectiveness ratio (ICER), with a one-way sensitivity analysis on key parameters.

## Scenario

- **States**: Stable → Progressed → Death
- **Strategies compared**:
  - **Standard of Care (SoC)** — lower cost, lower efficacy
  - **New Treatment** — higher cost, better disease control
- **Time horizon**: 10 annual cycles, cohort of 1,000 patients

All clinical and cost inputs are illustrative (not drawn from a real trial or dataset), used to demonstrate the modeling methodology.

## Method

1. Transition probabilities, costs, and utilities defined as named parameters
2. Transition matrices built per strategy (`define_transition`)
3. Health states defined with cost and utility values (`define_state`)
4. Base-case model run over 10 cycles (`run_model`)
5. Deterministic one-way sensitivity analysis on 4 key parameters, visualized as a tornado diagram (`define_dsa`, `run_dsa`)

## Results (base case)

| | Cost | Utility (QALY) |
|---|---|---|
| SoC | 40,147,486 | 3,301.85 |
| New | 85,642,565 | 4,472.22 |

**ICER (New vs. SoC): ~38,872 per QALY gained**

The sensitivity analysis shows the ICER ranges from ~28,576 to ~59,185 depending on assumptions, with the utility gain under the new treatment being the most influential parameter.

## Tools

R, `heemod`, `ggplot2`

## Files

- `markov_heor_model.R` — full model script (parameters, transitions, states, strategies, base-case run, DSA, tornado plot)
