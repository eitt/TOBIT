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
