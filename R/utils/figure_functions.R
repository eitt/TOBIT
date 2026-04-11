# R/utils/figure_functions.R
# Purpose: Helpers for accessible, high-contrast exporting of figures with Letter-width optimization.
# Dependencies: None

get_plot_style <- function() {
  list(
    ink = "#1A1A1A",
    primary = "#0B5E8E",
    primary_dark = "#083B5C",
    primary_light = "#CFE3F1",
    grid = "#D8D8D8",
    background = "#FFFFFF"
  )
}

open_accessible_png <- function(file_path, width = 8, height = 5) {
  grDevices::png(
    filename = file_path,
    width = width,
    height = height,
    units = "in",
    res = 300,
    bg = "white"
  )
}

apply_accessible_theme <- function() {
  style <- get_plot_style()
  graphics::par(
    bg = style$background,
    fg = style$ink,
    col.axis = style$ink,
    col.lab = style$ink,
    col.main = style$ink,
    cex.axis = 1.05,
    cex.lab = 1.15,
    cex.main = 1.10,
    family = "sans",
    las = 1,
    lend = "round",
    lwd = 2,
    mar = c(5, 5, 3.5, 1.5),
    bty = "l"
  )
}

#' Wraps a title for letter-width if it is too long (above ~60 chars)
wrap_title <- function(title_text, width = 60) {
  paste(strwrap(title_text, width = width), collapse = "\n")
}

sanitize_filename_component <- function(x, max_chars = 90L) {
  x <- trimws(as.character(x)[1])
  if (!nzchar(x)) return("figure")
  cleaned <- tolower(x)
  cleaned <- gsub("[^a-z0-9]+", "_", cleaned)
  cleaned <- gsub("_+", "_", cleaned)
  cleaned <- gsub("^_+|_+$", "", cleaned)
  if (!nzchar(cleaned)) cleaned <- "figure"
  if (nchar(cleaned) > max_chars) {
    cleaned <- substr(cleaned, 1, max_chars)
    cleaned <- gsub("_+$", "", cleaned)
  }
  cleaned
}

build_titled_figure_filename <- function(prefix, title, ext = "png") {
  sprintf("%s_%s.%s", prefix, sanitize_filename_component(title), ext)
}

get_standard_figure_filename <- function(figure_key) {
  switch(
    figure_key,
    age = build_titled_figure_filename("figure_01", "Age distribution"),
    empathy = build_titled_figure_filename("figure_02", "Empathy composite distribution"),
    radar = build_titled_figure_filename("figure_03", "IRI latent variable averages"),
    severity_panels = build_titled_figure_filename("figure_04", "Judgment distributions by N1 status"),
    bivariate_scatters = build_titled_figure_filename("figure_05", "Bivariate scatters IRI scales vs mean judgment"),
    victim_case_panels = build_titled_figure_filename("figure_06", "Victim subset judgment distributions across six case configurations"),
    bystander_case_panels = build_titled_figure_filename("figure_07", "Bystander subset judgment distributions across six case configurations"),
    accepted_case_panels = build_titled_figure_filename("figure_08", "Agreement judgment distributions across six case configurations"),
    rejected_case_panels = build_titled_figure_filename("figure_09", "Disagreement judgment distributions across six case configurations"),
    stop(sprintf("Unknown standard figure key '%s'.", figure_key), call. = FALSE)
  )
}

get_judgment_axis_limits <- function() {
  get_judgment_observed_bounds()
}

get_judgment_observed_bounds <- function() {
  c(-9, 9)
}

get_judgment_axis_ticks <- function() {
  seq(get_judgment_observed_bounds()[1], get_judgment_observed_bounds()[2], by = 3)
}

get_judgment_hist_breaks <- function() {
  seq(-9.5, 9.5, by = 1)
}

clamp_judgment_scale <- function(x, lower = get_judgment_observed_bounds()[1], upper = get_judgment_observed_bounds()[2]) {
  pmin(pmax(x, lower), upper)
}

draw_confidence_interval_bars <- function(x, low, high, color, cap_width = 0.12, lwd = 2) {
  finite_index <- is.finite(x) & is.finite(low) & is.finite(high)
  if (!any(finite_index)) return(invisible(NULL))

  x <- x[finite_index]
  low <- low[finite_index]
  high <- high[finite_index]

  graphics::segments(x, low, x, high, col = color, lwd = lwd)
  graphics::segments(x - cap_width, low, x + cap_width, low, col = color, lwd = lwd)
  graphics::segments(x - cap_width, high, x + cap_width, high, col = color, lwd = lwd)
  invisible(NULL)
}

draw_lm_fit_with_confidence_band <- function(x, y, line_color = "#083B5C", band_alpha = 0.18, level = 0.95, n_points = 100L) {
  complete_cases <- is.finite(x) & is.finite(y)
  x <- x[complete_cases]
  y <- y[complete_cases]

  if (length(x) < 3L || length(unique(x)) < 2L) {
    return(invisible(FALSE))
  }

  lm_fit <- stats::lm(y ~ x)
  prediction_grid <- data.frame(x = seq(min(x), max(x), length.out = n_points))
  prediction <- stats::predict(lm_fit, newdata = prediction_grid, interval = "confidence", level = level)

  graphics::polygon(
    c(prediction_grid$x, rev(prediction_grid$x)),
    c(prediction[, "lwr"], rev(prediction[, "upr"])),
    col = grDevices::adjustcolor(line_color, alpha.f = band_alpha),
    border = NA
  )
  graphics::lines(prediction_grid$x, prediction[, "fit"], col = line_color, lwd = 2.5)

  invisible(TRUE)
}

#' Draw a high-quality, minimalistic Radar Plot (Base R)
#' @param values Numeric vector of length N (scores to plot)
#' @param labels Character vector of length N (axis labels)
#' @param max_scale Numeric. Maximum boundary.
#' @param min_scale Numeric. Minimum boundary.
#' @param title Character. Main title.
#' @param style List. Style parameters.
#' @param legend_text Character vector. Text for the legend.
draw_base_radar_plot <- function(values, labels, max_scale = 5, min_scale = 1, title = "", style = get_plot_style(), legend_text = NULL) {
  n <- length(values)
  if (n < 3) stop("Radar plots require at least 3 axes.")
  
  # Set angles (0 is North)
  angles <- seq(pi/2, 2*pi + pi/2, length.out = n + 1)[1:n]
  
  # Normalization
  norm_values <- (values - min_scale) / (max_scale - min_scale)
  norm_values[norm_values < 0] <- 0
  norm_values[norm_values > 1] <- 1
  
  # Square aspect ratio enforcement
  graphics::par(pty = "s", mar = c(1, 1, 3, 1)) # Tighten margins
  
  # Prepare empty plot with sufficient room for labels
  # We increase xlim/ylim slightly and use a custom label positioning logic
  plot(0, 0, type = "n", xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5), 
       axes = FALSE, xlab = "", ylab = "", main = wrap_title(title), asp = 1)
  
  # Draw scale web (polygons for 20% increments)
  for (radius in seq(0.2, 1, by = 0.2)) {
    x_poly <- radius * cos(c(angles, angles[1]))
    y_poly <- radius * sin(c(angles, angles[1]))
    graphics::polygon(x_poly, y_poly, border = "#EEEEEE", lty = 1, lwd = 0.8)
  }
  
  # Draw axis spokes
  for (i in 1:n) {
    graphics::lines(x = c(0, cos(angles[i])), y = c(0, sin(angles[i])), col = "#D0D0D0", lwd = 1)
  }
  
  # Labels with smart positioning to avoid clipping
  label_radius <- 1.25
  for (i in 1:n) {
    adj_val <- if (cos(angles[i]) > 0.1) 0 else if (cos(angles[i]) < -0.1) 1 else 0.5
    graphics::text(label_radius * cos(angles[i]), label_radius * sin(angles[i]), 
                   labels = labels[i], col = style$ink, cex = 0.85, font = 2, adj = c(adj_val, 0.5))
  }
                 
  # Data Polygon
  x_poly_data <- c(norm_values * cos(angles), (norm_values * cos(angles))[1])
  y_poly_data <- c(norm_values * sin(angles), (norm_values * sin(angles))[1])
  
  # SteelBlue fill
  graphics::polygon(x_poly_data, y_poly_data, 
                    col = grDevices::adjustcolor("#4682B4", alpha.f = 0.35),
                    border = "#4682B4", lwd = 2.5)
                    
  # Vertices
  graphics::points(norm_values * cos(angles), norm_values * sin(angles), 
                   pch = 21, bg = "white", col = "#4682B4", cex = 1.1)
                   
  # Markers
  graphics::text(0, -0.1, labels = as.character(min_scale), cex = 0.6, col = "#BBBBBB")
  graphics::text(0, 1.05, labels = as.character(max_scale), cex = 0.6, col = "#BBBBBB")
  
  # Legend
  if (!is.null(legend_text)) {
    graphics::legend("bottomright", legend = legend_text, bty = "n", cex = 0.75, text.col = style$ink)
  }
}
