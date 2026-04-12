# R/utils/narrative_functions.R
# Purpose: Centralize theoretical narratives, statistical foundations, 
# and dictionary definitions for the automated scientific report.
# Dependencies: None

source("R/utils/case_configuration_functions.R")

#' Get standardized Dataset Description
get_dataset_narration <- function(dataset_mode = "BOTH") {
  campus_text <- if (dataset_mode == "FLORIDA") {
    "The sample consists of students from the Floridablanca Campus."
  } else if (dataset_mode == "BUC") {
    "The sample consists of students from the Bucaramanga Campus."
  } else {
    "The sample consists of students from both the Floridablanca and Bucaramanga Campuses."
  }
  
  c(
    "The empirical foundation of this project rests on two primary experimental datasets: FLORIDA and BUC. ",
    campus_text,
    " These datasets capture incentivized moral judgments from distinct socio-economic contexts. Participants were presented ",
    "with standardized negotiation scenarios where a negotiator's decision resulted in varying degrees of payoff for ",
    "themselves, their own group, and a victim group. Under ",
    get_case_configuration_option_label(),
    ", each judgment is treated as relational and linked both to a descriptive victim x negotiator scenario shorthand and to hypothesis-specific predictors for N1 (judged negotiator) and N2 (counterpart), observer-side victim alignment when applicable, and additional relational controls."
  )
}

#' Get Mathematical Foundations (Tobit Random-Intercept Branch and Robustness Branch)
get_math_foundations <- function() {
  c(
    "The analysis employs two complementary estimators for bounded moral judgments. The primary inferential branch is labeled Tobit and estimated with random intercepts, separately by role subset. ",
    "Observed moral judgments ($y_{isjr}$) remain on the original bounded scale from -9 to 9, where lower values indicate harsher condemnation and higher values indicate less severe condemnation. ",
    "The primary model is:",
    "",
    "$$y_{isjr} = \\beta_0 + \\mathbf{x}_{isjr}'\\beta + u_i + v_{c(i,s)} + \\epsilon_{isjr}$$",
    "",
    "where $u_i$ is a participant random intercept and $v_{c(i,s)}$ is an optional case-level random intercept included when the case identifier supports repeated within-case judgments (otherwise the model keeps the participant random intercept only). In implementation terms this corresponds to $(1|id)$ and, when identifiable, $(1|id\\_case)$.",
    get_case_configuration_option_text(latex = TRUE),
    " H1, H2, and H3 are all estimated separately in the victim and bystander subsets using role-specific relational predictors:",
    "",
    "Victim-subset H2:",
    "",
    "$$y_{isj,Victim} = \\beta_0 + \\beta_1 \\text{Empathy}_i + \\gamma_1 \\text{Victim-N1}_{isj} + \\gamma_2 \\text{Victim-N2}_{isj} + \\gamma_3(\\text{Victim-N1}_{isj} \\times \\text{Victim-N2}_{isj}) + \\gamma_4\\text{SameFac}_{isj} + \\boldsymbol{\\delta}'\\mathbf{Z}_i + u_i + v_{c(i,s)} + \\epsilon_{isj}$$",
    "",
    "Bystander-subset H2:",
    "",
    "$$y_{isj,Obs} = \\beta_0 + \\beta_1 \\text{Empathy}_i + \\eta\\text{Bystander-Victim}_{isj} + \\boldsymbol{\\kappa}'(\\text{Bystander-Victim}_{isj}\\times\\text{Bystander-N}_{isj}) + \\boldsymbol{\\gamma}'\\mathbf{R}_{isj} + \\gamma_4\\text{SameFac}_{isj} + \\boldsymbol{\\delta}'\\mathbf{Z}_i + u_i + v_{c(i,s)} + \\epsilon_{isj}$$",
    "",
    "H3:",
    "",
    "$$y_{isjr} = \\beta_0 + \\beta_1 \\text{Empathy}_i + \\boldsymbol{\\beta}_2'\\mathbf{G}_{isjr} + \\boldsymbol{\\beta}_3'(\\text{Empathy}_i \\times \\mathbf{G}_{isjr}) + \\kappa_1(\\text{Bystander-Victim}_{isjr}\\times\\text{Bystander-N}_{isjr}) + \\kappa_2(\\text{Empathy}_i\\times\\text{Bystander-Victim}_{isjr}) + \\beta_4\\text{SameFac}_{isjr} + \\boldsymbol{\\delta}'\\mathbf{Z}_i + u_i + v_{c(i,s)} + \\epsilon_{isjr}$$",
    "",
    "For the three-level relational factors (Victim-N1, Victim-N2, Bystander-N1, Bystander-N2), the control-labeled level is the reference category. For bystander-victim alignment, ingroup is the reference category.",
    if (report_includes_nonparametric()) {
      c(
        "",
        "As a robustness branch, the pipeline can also fit a distribution-robust censored median specification implemented as interval-censored quantile regression ($p = 0.5$). ",
        "This complementary estimator targets the conditional median of the latent bounded outcome and is less sensitive to heavy tails and non-normal disturbances:",
        "",
        "$$Q_{0.5}(y^*_{isjr} \\mid \\mathbf{x}_{isjr}) = \\mathbf{x}_{isjr}'\\beta_{0.5}$$",
        "",
        "The non-parametric branch preserves censoring structure while relaxing strong parametric assumptions. Primary-model and robustness results should therefore be interpreted jointly."
      )
    } else {
      ""
    }
  )
}

#' Get Statistical Inference Analysis (Type I and II Errors)
get_error_analysis_narration <- function() {
  c(
    "The statistical validity of our inferences depends on the trade-off between False Positives (Type I error, $\\alpha$) ",
    "and False Negatives (Type II error, $\\beta$). Given the clustered nature of our data, sample size impact is not ",
    "merely a count of observations, but a function of cluster correlation.",
    "",
    "\\subsubsection{Step-by-Step Sensitivity Analysis}",
    "To determine the impact of our sample size on our ability to detect effects, we follow these steps:",
    "",
    "1. Calculate the Design Effect (Deff): As multiple judgments are nested within individuals, we adjust for the Intraclass Correlation (ICC).",
    "$$Deff = 1 + (m - 1) \\times ICC$$",
    "where $m$ is the average number of scenarios per participant. ",
    "",
    "2. Determine the Effective Sample Size (ESS): The ESS represents the number of independent observations that would provide the same statistical power as our clustered sample.",
    "$$ESS = \\frac{n_{total}}{Deff}$$",
    "",
    "3. Inference Impact: A higher ICC reduces the ESS, thereby increasing standard errors in our Tobit random-intercepts coefficients. ",
    "If the ESS is low, our models become 'conservative', increasing the risk of Type II errors (failing to support a hypothesis). ",
    sprintf(
      "By using role-specific Tobit random-intercepts estimation%s, we ensure that inference acknowledges this reduced information density, protecting the integrity of our Type I error threshold ($\\alpha = 0.05$).",
      if (report_includes_nonparametric()) " and participant-level cluster bootstrap inference for the non-parametric robustness model after each converged full-sample fit" else ""
    )
  )
}

#' Get Symbols and Variables Dictionary (LaTeX format)
get_symbols_dictionary <- function() {
  symbols <- data.frame(
    Symbol = c(
      "$y_{isjr}$",
      "$y^*_{isjr}$",
      "$\\beta_1$",
      if (report_includes_nonparametric()) "$\\beta_{0.5}$" else NULL,
      if (report_includes_nonparametric()) "$Q_{0.5}(y^*_{isjr} \\mid \\mathbf{x}_{isjr})$" else NULL,
      "$\\text{IRI}_i$",
      "$\\mathbf{S}_{isj}$",
      "$V_{is}$",
      "$G_{isjr}$",
      "$A_{is}$",
      "$C_{isjr}$",
      "$\\text{ICC}$"
    ),
    Definition = c(
      "Observed moral judgment (Scale: -9 to 9).",
      "Latent moral preference score (unbounded true judgment).",
      "The measured effect of a variable on moral judgment (coefficient).",
      if (report_includes_nonparametric()) "Effect measured by the alternative non-parametric model (median regression)." else NULL,
      if (report_includes_nonparametric()) "Theoretical conditional median of the moral score." else NULL,
      "Empathy score: Participant's propensity for empathy across different IRI subscales.",
      "Relationship structure: The group status of both N1 and N2 negotiators (Ingroup, Outgroup, or Control).",
      "Observer-victim match: Whether the observer and victim have matching group affiliations.",
      "N1 Group Status: The specific group affiliation of the N1 negotiator being judged.",
      "Action Taken: Whether the harm was Accepted (A=1) or Rejected (A=0).",
      "Relational Controls: Other factors that might influence judgment, like age or socioeconomic status.",
      "Intraclass Correlation: The degree of similarity in judgments within the same participant."
    ),
    stringsAsFactors = FALSE
  )
  # Filter out NULLs
  symbols <- symbols[!vapply(symbols$Symbol, is.null, logical(1)), ]
  symbols
}

#' Get limitations and discussion points
get_limitations_narration <- function() {
  c(
    "While the dual-estimator strategy strengthens the analysis, several limitations remain. First, both inference strategies assume ",
    "independence between participants, which may still be violated by broader shared institutional or contextual shocks. Second, we assume a ",
    "Gaussian residual structure in the primary mixed-effects branch; strong departures from that assumption can affect calibration of inferential summaries. ",
    if (report_includes_nonparametric()) {
      "The non-parametric robustness branch reduces dependence on that assumption and adds participant-level cluster bootstrap inference after converged full-sample fits, but bootstrap summaries still carry Monte Carlo error and can be sensitive to convergence problems in difficult specifications. "
    } else {
       ""
    },
    "Finally, the use of unstandardized averages for empathy assumes a linear relationship between the survey score and actual moral preference."
  )
}
