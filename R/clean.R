#' @title clean
#' @author Simon Goring \email{goring@wisc.edu}
#' @import gtools
#' @import lubridate
#' @importFrom methods new
#' @param x sites, datasets, collunits that may have duplicates.
#' @param ... Additional parameters associated with the call.
#' @description Function that removes duplicate objects such as sites, datasets, or collection units.

clean <- function(x = NA, ...) {
  if (!missing(x)) {
    UseMethod("clean", x)
  } else {
    UseMethod("clean", NA)
  }
}

clean.sites <- function(x) {

  siteids <- as.data.frame(x)$siteid
  if (any(duplicated(siteids))) {
    matched <- unique(siteids[duplicated(siteids)])
    clean_sites <- neotoma2::filter(x, !.data$siteid %in% matched)
    for (i in matched) {
      messy_site <- neotoma2::filter(x, .data$siteid == i)
      messy_cus <- clean(collunits(messy_site))
      new_site <- messy_site[1]
      new_site@sites[[1]]@collunits <- messy_cus
      clean_sites <- c(clean_sites, new_site[[1]])
    }
    return(clean_sites)
  } else {
    return(x)
  }
}

clean.collunits <- function(x) {
  cuids <- as.data.frame(x)$collectionunitid
  matched <- unique(cuids[duplicated(cuids)])
  if (length(matched) == 0) {
    return(x)
  } else {
    clean_cus <- x[which(!cuids %in% matched)]
    for (i in matched) {
      messy_cus <- new("collunits", collunits = x@collunits[cuids == i])
      cu_ds <- clean(datasets(messy_cus))
      newcu <- messy_cus[1]
      newcu[[1]]@datasets <- cu_ds
      clean_cus <- c(clean_cus, newcu)
    }
  }
  return(clean_cus)
}

clean.datasets <- function(x) {
  dsids <- as.data.frame(x)$datasetid
  return(x[which(!duplicated(dsids))])
}
