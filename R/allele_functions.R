#' Calculate the allele frequencies of loci
#' 
#' @description 
#' Calculates the frequency of markers, QTL, or both.
#' 
#' @param genome An object of class \code{genome}.
#' @param pop A population.
#' @param locus.type The type of loci for which allele frequenices should be returned. Can be \code{"qtl"},
#' \code{"markers"}, or \code{"both"}.
#' 
#' @return 
#' A \code{list} of frequencies of the 1 allele for the loci specified.
#' 
#' @examples 
#' n.mar  <- c(505, 505, 505)
#' len <- c(120, 130, 140)
#' 
#' genome <- sim_genome(len, n.mar)
#' 
#' # Randomly generate 15 QTL with additive allelic effects following a
#' # genometric series
#' qtl.model <- matrix(nrow = 15, ncol = 4)
#' genome <- sim_gen_model(genome, qtl.model, add.dist = "geometric")
#' 
#' # Create a random population
#' pop <- sim_pop(genome = genome, n.ind = 200)
#' 
#' # Calculate QTL allele freqencies
#' calc_allele_freq(genome, pop, "qtl")
#' # For markers
#' calc_allele_freq(genome, pop, "markers")
#' 
#' @export
#' 
#' 
calc_allele_freq <- function(genome, pop, locus.type = c("qtl", "markers", "both")) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Make sure genome inherits the class "genome."
  if (!inherits(pop, "pop"))
    stop("The input 'pop' must be of class 'pop.'")
  
  # Match the locus.type argument
  locus.type <- match.arg(locus.type)
  
  
  
  ## Extract the names of the locus type
  loci <- switch(locus.type,
                 qtl = qtlnames(genome),
                 markers = markernames(genome, include.qtl = FALSE),
                 both = markernames(genome, include.qtl = TRUE)
  )
  
  ## If the locus type is QTL and there is more than one trait, separate by trait
  if (locus.type == "qtl" & length(genome$gen_model) > 1) {
    loci_list <- lapply(X = genome$gen_model, "[[", "qtl_name")
    
  } else {
    loci_list <- list(loci)
    
  }
  
  # Pull out the genotypes for those loci
  loci_geno <- lapply(X = loci_list, pull_genotype, genome = genome, geno = pop$geno)
  # Calculate the frequency of the 1 allele and return
  lapply(X = loci_geno, FUN = function(x) colMeans(x) / 2)
  
}


#' Calculate the frequency of haplotypes
#' 
#' @description 
#' Calculates the frequency of haplotypes given a list of vectors of loci.
#' 
#' @param genome An object of class \code{genome}.
#' @param pop A population.
#' @param loci.list A \code{list} of vectors of loci names for which haplotype frequencies should be calculated.
#' 
#' @return 
#' A \code{list} of haplotype frequencies
#' 
#' @examples 
#' n.mar  <- c(505, 505, 505)
#' len <- c(120, 130, 140)
#' 
#' genome <- sim_genome(len, n.mar)
#' 
#' # Randomly generate 15 QTL with additive allelic effects following a
#' # genometric series
#' qtl.model <- matrix(nrow = 15, ncol = 4)
#' genome <- sim_gen_model(genome, qtl.model, add.dist = "geometric")
#' 
#' # Create a random population
#' pop <- sim_pop(genome = genome, n.ind = 200)
#' 
#' # Sample 2 pairs of QTL
#' loci.list <- replicate(n = 2, sample(qtlnames(genome), 2), simplify = F)
#' 
#' # Calculate haplotype frequencies
#' calc_haplotype_freq(genome, pop, loci.list)
#' 
#' 
#' @export
#' 
#' 
calc_haplotype_freq <- function(genome, pop, loci.list) {
  
  # Check classes
  stopifnot(class(genome) == "genome")
  stopifnot(class(pop) == "pop")
  stopifnot(class(loci.list) == "list")
  
  # Restrict to 3 loci in a haplotype
  nhaplo <- sapply(loci.list, length)
  
  if (any(nhaplo > 3)) stop("The number of loci in a haplotype cannot be greater than 3.")
  
  # Create an empty list
  haplo_count_list <- vector("list", length(loci.list))
  
  # Iterate over the list of loci
  for (i in seq_along(loci.list)) {
    
    # Pull out the genotypes for those loci
    loci_geno <- pull_genotype(genome = genome, geno = pop$geno, loci = loci.list[[i]])
    
    # Calculate haplotype counts
    haplo_counts <- as.data.frame(table(as.data.frame(loci_geno)))
    # Modify frequency and counts
    haplo_counts$Count <- haplo_counts$Freq
    haplo_counts$Freq <- haplo_counts$Freq / sum(haplo_counts$Freq)
    
    haplo_count_list[[i]] <- haplo_counts
    
  }
  
  # Return
  return(haplo_count_list)

}



#' Calculate linkage disequilibrium between loci
#' 
#' @description 
#' Calculates linkage disequilibrium (LD; as \eqn{r^2}) between loci.
#' 
#' @param genome An object of class \code{genome}.
#' @param pop A population.
#' @param loci A vector of locus names for which pairwise LD should be calculated.
#' 
#' @return 
#' A \code{matrix} of pairwise LD values.
#' 
#' @examples 
#' n.mar  <- c(505, 505, 505)
#' len <- c(120, 130, 140)
#' 
#' genome <- sim_genome(len, n.mar)
#' 
#' # Randomly generate 15 QTL with additive allelic effects following a
#' # genometric series
#' qtl.model <- matrix(nrow = 15, ncol = 4)
#' genome <- sim_gen_model(genome, qtl.model, add.dist = "geometric")
#' 
#' # Create a random population
#' pop <- sim_pop(genome = genome, n.ind = 200)
#' 
#' # Calculate QTL allele freqencies
#' calc_LD(genome, pop, qtlnames(genome))
#' 
#' @export
#' 
#' 
calc_LD <- function(genome, pop, loci) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Make sure genome inherits the class "genome."
  if (!inherits(pop, "pop"))
    stop("The input 'pop' must be of class 'pop.'")
  
  # Pull out the genotypes for the specified loci
  loci_geno <- pull_genotype(genome = genome, geno = pop$geno, loci = loci)
  # Calculate LD and return
  cor(loci_geno)^2
  
}





