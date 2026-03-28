# R/utils/narrative_functions.R
# Purpose: Centralize theoretical narratives, statistical foundations, 
# and dictionary definitions for the automated scientific report.
# Dependencies: None

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
    "themselves, their own group, and a victim group (either ingroup or outgroup)."
  )
}

#' Get Mathematical Foundations (Tobit and Latent Variables)
get_math_foundations <- function() {
  c(
    "The analysis employs two complementary estimators for bounded moral judgments. The primary specification is a Two-Limit Tobit model, which is theoretically appropriate for dependent variables that are ",
    "strictly bounded within a known interval. In this context, moral judgments ($y_{ij}$) are observed on a scale from -9 to 9. ",
    "The Tobit model assumes the existence of a latent, unobserved preference index ($y^*_{ij}$) that follows a linear relationship:",
    "",
    "$$y^*_{ij} = \\mathbf{x}_{ij}'\\beta + \\epsilon_{ij}, \\quad \\epsilon_{ij} \\sim N(0, \\sigma^2)$$",
    "",
    "The actual observed judgment $y_{ij}$ relates to this latent variable via the censoring transformation:",
    "",
    "$$y_{ij} = \\max(-9, \\min(9, y^*_{ij}))$$",
    "",
    "This approach prevents the 'ceiling' and 'floor' effects from biasing the linear coefficients, as would occur in standard OLS regression.",
    "",
    "Because the Tobit model relies on a Gaussian latent-error assumption, the pipeline also fits a distribution-robust censored median specification implemented as interval-censored quantile regression ($p = 0.5$). ",
    "This complementary estimator targets the conditional median of the latent bounded outcome and is less sensitive to heavy tails and non-normal disturbances:",
    "",
    "$$Q_{0.5}(y^*_{ij} \\mid \\mathbf{x}_{ij}) = \\mathbf{x}_{ij}'\\beta_{0.5}$$",
    "",
    "The non-parametric branch preserves the censoring structure while relaxing the parametric normality assumption. The Tobit and robustness results should therefore be interpreted jointly: Tobit provides the clustered parametric benchmark with participant-clustered standard errors by id, while the non-parametric branch first establishes a converged full-sample censored median fit and then, in the default pipeline, adds participant-level cluster bootstrap inference that resamples ids with replacement and retains all repeated observations from each sampled participant. In both branches, id is used only to account for within-participant dependence and is not a substantive explanatory variable."
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
    "3. Inference Impact: A higher ICC reduces the ESS, thereby increasing the Standard Error of our Tobit coefficients. ",
    "If the ESS is low, our models become 'conservative', increasing the risk of Type II errors (failing to support a hypothesis). ",
    "By using clustered robust standard errors for Tobit and participant-level cluster bootstrap inference for the non-parametric robustness model after each converged full-sample fit, we ensure that both sets of p-values acknowledge this reduced information density, ",
    "protecting the integrity of our Type I error threshold ($\\alpha = 0.05$)."
  )
}

#' Get Symbols and Variables Dictionary (LaTeX format)
get_symbols_dictionary <- function() {
  data.frame(
    Symbol = c("$y_{ij}$", "$y^*_{ij}$", "$\\beta_1$", "$\\beta_{0.5}$", "$Q_{0.5}(y^*_{ij} \\mid \\mathbf{x}_{ij})$", "$\\text{IRI}_i$", "$\\text{OutgroupPerp}$", "$\\text{SameGroupHarm}$", "$\\text{ICC}$"),
    Definition = c(
      "Observed moral judgment of scenario $j$ by participant $i$.",
      "Latent moral preference score (unbounded).",
      "Regression coefficient representing the marginal effect of the predictor.",
      "Median-regression coefficient from the non-parametric censored robustness model.",
      "Conditional median of the latent bounded outcome given the predictors.",
      "Empathy score (Average composite of the Interpersonal Reactivity Index).",
      "Binary indicator: 1 if the scenario perpetrator is an outgroup member.",
      "Binary indicator: 1 if the harm is inflicted on the perpetrator's own group.",
      "Intraclass Correlation: ratio of between-cluster variance to total variance."
    ),
    stringsAsFactors = FALSE
  )
}

#' Get limitations and discussion points
get_limitations_narration <- function() {
  c(
    "While the dual-estimator strategy strengthens the analysis, several limitations remain. First, both inference strategies assume ",
    "independence between participants, which may still be violated by broader shared institutional or contextual shocks. Second, we assume a ",
    "normal distribution for the latent errors $\\epsilon_{ij}$ in the Tobit branch; departures from normality could affect the consistency of ",
    "the maximum likelihood estimators. The non-parametric robustness branch reduces dependence on that assumption and adds participant-level cluster bootstrap inference after converged full-sample fits, but bootstrap summaries still carry Monte Carlo error and can be sensitive to convergence problems in difficult specifications. ",
    "Finally, the use of unstandardized averages for empathy assumes a linear mapping between the psychometric scale and the latent moral preference across both estimators."
  )
}
