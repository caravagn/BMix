#' Export a tibble with the parameters fits for this model
#'
#' @description
#'
#' This functions extracts a tibble reporting the parameters fits for
#' the input model (clusters, means of clusters, dispersion, likelihood
#' score, cluster sizes etc.).
#'
#' @param x An object of class \code{bmix} that represents a fit.
#'
#' @return A `tibble` for the statistcis.
#'
#' @import dplyr
#'
#' @export
#'
#' @examples
#' # The same dataset used in the package vignette
#' data = data.frame(successes = c(rbinom(30, 100, .4), rbinom(70, 100, .7)), trials = 100)
#'
#' # BMix fit with default parameters
#' x = bmixfit(data)
#'
#' to_string(x)
to_string = function(x)
{
  rn = function(d, n) {
    if(all(is.null(d))) return(data.frame())
    colnames(d) = paste0(n, '_', colnames(d))
    colnames(d) = gsub(" ", '_', colnames(d))
    d
  }

  # Number of points per cluster
  n_cl = data.frame(as.vector(table(x$labels)), stringsAsFactors = FALSE) %>% t
  colnames(n_cl) = names(table(x$labels))

  # Clusters means and overdispersion
  Bm = BBm = BBo = data.frame()
  if(x$K[1] > 0) Bm = as.data.frame(x$B.params) %>% t %>% rn(n = "Mean")
  if(x$K[2] > 0) BBm = as.data.frame(x$BB.params[1, , drop = F]) %>% rn(n = "Mean")
  if(x$K[2] > 0) BBo = as.data.frame(x$BB.params[2, , drop = F]) %>% rn(n = "Dispersion")

  # Assembly
  df = cbind(
    data.frame(
      N = length(x$labels),
      n_cl %>% rn(n = "N"),
      stringsAsFactors = FALSE
    ),
      K_B = x$K[1],
      K_BB = x$K[2],
      K = sum(x$K),
      x$pi %>% as.data.frame %>% t %>% rn(n = "Pi"),
      ICL = x$ICL,
      BIC = x$BIC,
      entropy = x$entropy,
      use_entropy = x$use_entropy
    )

  if(x$K[1] > 0) df = cbind(df, Bm)
  if(x$K[2] > 0) df = cbind(df, BBm, BBo)

  rownames(df) = NULL
  df %>% as_tibble()
}
