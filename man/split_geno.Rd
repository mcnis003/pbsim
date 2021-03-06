% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geno_functions.R
\name{split_geno}
\alias{split_geno}
\title{Split a genotype matrix into chromosomes}
\usage{
split_geno(genome, geno, ignore.gen.model = FALSE)
}
\arguments{
\item{genome}{An object of class \code{genome}.}

\item{geno}{Genotype data on a population to phenotype. Must be a matrix of 
dimensions \code{n.ind} x \code{n.loci}, the elements of which must be z {0, 1, 2}, 
or a list of such matrices.}

\item{ignore.gen.model}{Logical - should the genetic model be ignored?}
}
\value{
A list of geno matrices, split by chromosome.
}
\description{
Split a genotype matrix into chromosomes
}
