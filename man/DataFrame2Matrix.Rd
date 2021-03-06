% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DataFrame2Matrix.R
\name{DataFrame2Matrix}
\alias{DataFrame2Matrix}
\title{DataFrame2Matrix}
\source{
\url{http://biopsych.dk/iPsychCNV}
}
\usage{
DataFrame2Matrix(RowNames = V1, ColNames = V2, Values = V3)
}
\arguments{
\item{RowNames}{Vector that will be matrix's rownames.}

\item{ColNames}{Vector that will be matrix's colnames.}

\item{Values}{Vector that will be matrix's values.}
}
\value{
return a matrix with values and specific rownames and colnames.
}
\description{
iPsychCNV: Find Copy Number Variation (CNV) from SNP genotyping arrays. 
Specifically designed to reduce false positive CNVs and amplified DNA on dried blood spots.
DataFrame2Matrix: Transform 3 vectors from a data frame into matrix.
}
\examples{
M <- DataFrame2Matrix(RowNames=V1, ColNames=V2, Values=V3)
}
\author{
Marcelo Bertalan
}

