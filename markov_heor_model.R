# =============================================================
# Health Economic Decision Model – Markov Cost-Effectiveness Simulation
# Comparing Standard of Care (SoC) vs. New Treatment
# States: Stable -> Progressed -> Death
# =============================================================

library(heemod)
library(ggplot2)

# -------------------------------------------------------------
# 1. PARAMETERS
# All values that might vary in the sensitivity analysis are
# declared here as named parameters, not hard-coded numbers.
# -------------------------------------------------------------

param <- define_parameters(
  # -- Transition probabilities: Standard of Care --
  p_stable_to_progressed_soc = 0.20,
  p_stable_to_death_soc      = 0.10,
  p_progressed_to_death_soc  = 0.25,
  
  # -- Transition probabilities: New Treatment --
  p_stable_to_progressed_new = 0.13,
  p_stable_to_death_new      = 0.07,
  p_progressed_to_death_new  = 0.20,
  
  # -- Costs (annual, per state) --
  cost_stable_soc      = 5000,
  cost_stable_new      = 15000,
  cost_progressed      = 12000,
  
  # -- Utilities (quality of life weight, 0 = death, 1 = full health) --
  util_stable_soc      = 0.80,
  util_stable_new      = 0.85,
  util_progressed       = 0.50
)

# -------------------------------------------------------------
# 2. TRANSITION MATRICES
# Built from the parameters above (not raw numbers), so heemod
# can vary them during the sensitivity analysis.
# -------------------------------------------------------------

mat_soc <- define_transition(
  state_names = c("Stable", "Progressed", "Death"),
  C, p_stable_to_progressed_soc,     p_stable_to_death_soc,
  0, C,                              p_progressed_to_death_soc,
  0, 0,                              1
)

mat_new <- define_transition(
  state_names = c("Stable", "Progressed", "Death"),
  C, p_stable_to_progressed_new,     p_stable_to_death_new,
  0, C,                              p_progressed_to_death_new,
  0, 0,                              1
)

# Note: "C" tells heemod to auto-complete that cell so the row sums to 1.

# -------------------------------------------------------------
# 3. HEALTH STATES (cost + utility per state, per strategy)
# -------------------------------------------------------------

state_stable_soc <- define_state(
  cost    = cost_stable_soc,
  utility = util_stable_soc
)

state_progressed_soc <- define_state(
  cost    = cost_progressed,
  utility = util_progressed
)

state_stable_new <- define_state(
  cost    = cost_stable_new,
  utility = util_stable_new
)

state_progressed_new <- define_state(
  cost    = cost_progressed,
  utility = util_progressed
)

state_death <- define_state(
  cost    = 0,
  utility = 0
)

# -------------------------------------------------------------
# 4. STRATEGIES
# -------------------------------------------------------------

strat_soc <- define_strategy(
  transition = mat_soc,
  Stable     = state_stable_soc,
  Progressed = state_progressed_soc,
  Death      = state_death
)

strat_new <- define_strategy(
  transition = mat_new,
  Stable     = state_stable_new,
  Progressed = state_progressed_new,
  Death      = state_death
)

# -------------------------------------------------------------
# 5. RUN THE BASE-CASE MODEL
# -------------------------------------------------------------

res_mod <- run_model(
  soc    = strat_soc,
  new    = strat_new,
  parameters = param,
  cycles = 10,
  cost   = cost,
  effect = utility,
  method = "life-table"
)

print(res_mod)
summary(res_mod)

# -------------------------------------------------------------
# 6. DETERMINISTIC SENSITIVITY ANALYSIS (one-way / tornado)
# We vary a few key parameters +/- 20% around their base value
# and see how much the ICER moves.
# -------------------------------------------------------------

def_dsa <- define_dsa(
  cost_stable_new,             12000, 18000,
  util_stable_new,              0.75,  0.95,
  p_stable_to_progressed_new,   0.08,  0.18,
  cost_progressed,              9000, 15000
)

res_dsa <- run_dsa(res_mod, def_dsa)

print(res_dsa)

# Tornado plot
plot(res_dsa, type = "difference", result = "icer") +
  ggtitle("Tornado Diagram – ICER Sensitivity (New vs. SoC)")

# -------------------------------------------------------------
# 7. (Optional) Save outputs
# -------------------------------------------------------------

# ggsave("tornado_icer.png", width = 8, height = 5)
# write.csv(summary(res_mod)$res_comp, "model_results.csv")
