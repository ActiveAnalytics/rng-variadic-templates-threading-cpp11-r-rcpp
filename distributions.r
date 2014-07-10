# Benchmarks for the R vs. C++11 functions

require(Rcpp)
require(microbenchmark)

sourceCpp("distributions.cpp")

# Benchmarks
#----------------------------------------------------------------------------------------------------------
n = 1E3

# R benchmarks
rbaseOutput <- summary(microbenchmark(runif(n), rbinom(n, size = 10, prob = .5), rgeom(n, prob = .5), rnbinom(n, size = 10, prob = .5), 
	rpois(n, lambda = 1), rexp(n, rate = 1), rgamma(n, shape = 1, rate = 1), rweibull(n, shape = 1, scale = 1), 
	rnorm(n, mean = 0, sd = 1), rlnorm(n, mean = 0, sdlog = 1), rchisq(n, df = 5), rcauchy(n), rf(n, df1 = 100, df2 = 100),
	unit = "ms"))

# Rcpp benchmarks
benchmarks <- summary(microbenchmark(runifCpp(n), rbinomCpp(n, size = 10, prob = .5), rgeomCpp(n, prob = .5), rnbinomCpp(n, size = 10, prob = .5), 
	rpoisCpp(n, lambda = 1), rexpCpp(n, rate = 1), rgammaCpp(n, shape = 1, rate = 1), rweibullCpp(n, shape = 1, scale = 1), 
	rnormCpp(n, mean = 0, sd = 1), rlnormCpp(n, mean = 0, sdlog = 1), rchisqCpp(n, df = 5), rcauchyCpp(n), rfCpp(n, df1 = 100, df2 = 100),
	unit = "ms"))

# Re-basing Rcpp benchmarks over R
benchmarks[,2:6] <- benchmarks[,2:6]/rbaseOutput[,2:6]
benchmarks[,1] <- c("unif", "binom", "geom", "nbinom", "pois", "exp", "gamma", "weibull", "norm", "lnorm", "chisq", "cauchy", "f")
names(benchmarks)[1] <- "distr"
benchmarks <- cbind("call" = "Rcpp", benchmarks)

#----------------------------------------------------------------------------------------------------------

require(ggplot2)
ggplot(benchmarks, aes(distr, median)) + geom_bar(stat = "identity") + 
	labs(x = "\nDistribution", y = "Time (Relative to R)\n", 
	title = "C++ time relative to R ( < 1 is faster than R)\n")

# Bug?
rbinomCpp(n = 10, size = 10, prob = 5)
rbinom(n = 10, size = 10, prob = 5) # gives warning and returns NA since probability > 1 is not valid

# For threading
n = 1E3
microbenchmark(runif(n), runifCpp(n, 0, 1), runifCpp_par(n, 0, 1))
n = 1E7
microbenchmark(runif(n), runifCpp(n, 0, 1), runifCpp_par(n, 0, 1), times = 1L)
