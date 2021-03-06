% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_pop.R
\name{sim_pop}
\alias{sim_pop}
\title{Simulate a population}
\usage{
sim_pop(genome, n.ind, ignore.gen.model = FALSE)
}
\arguments{
\item{genome}{A genome object.}

\item{n.ind}{The number of individual in the population.}

\item{ignore.gen.model}{Logical - should the gene model be ignored?}
}
\value{
A \code{pop} object.
}
\description{
Simulates a random population of given population size. SNPs are simulated
to be in linkage equilibrium.
}
\examples{
# Simulate a genome
n.mar  <- c(505, 505, 505)
len <- c(120, 130, 140)

genome <- sim_genome(len, n.mar)

# Simulate a quantitative trait influenced by 50 QTL
qtl.model <- matrix(NA, 50, 4)
genome <- sim_gen_model(genome = genome, qtl.model = qtl.model, 
                        add.dist = "geometric", max.qtl = 50)
                        
# Simulate the population
pop <- sim_pop(genome = genome, n.ind = 100)

}
