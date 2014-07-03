# Benchmarks for the R vs. C++11 functions

require(Rcpp)
require(microbenchmark)

sourceCpp("distributions.cpp")

genRandom <- function(func, ...)
{
	args = list(...)
	do.call(func, args)
}

funcs <- c("runif", "rbinom", "rgeom", "rnbinom", "rpois", "rexp",
	"rgamma", "rweibull", "rnorm", "rlnorm", "rchisq", "rcauchy", "rf")
funcsCpp <- paste0(funcs, "Cpp")

# The benchmark to be created
createBenchmark <- function(funcNum = 1, n = 1E3, ...)
{
	func <- funcs[funcNum]
	tempFile <- tempfile()
	sink(file = tempFile) #prevents verbose printing
	output <- print(microbenchmark(genRandom(func, n, ...), genRandom(funcsCpp[funcNum], n, ...)))
	sink()
	unlink(tempFile)
	.median <- output[1, "median"]
	output[,2:6] <- output[,2:6]/.median
	output[, 1] <- substr(func, 2, nchar(func))
	names(output)[1] <- "distr"
	output <- cbind(c("R", "Rcpp"), output)
	names(output)[1] <- "call"
	return(output[-1,])
}

bechmarks <- list(createBenchmark(),
		createBenchmark(funcNum = 2, size = 10, prob = .5),
		createBenchmark(funcNum = 3, prob = .5),
		createBenchmark(funcNum = 4, size = 10, prob = .5),
		createBenchmark(funcNum = 5, lambda = 1),
		createBenchmark(funcNum = 6, rate = 1),
		createBenchmark(funcNum = 7, shape = 1, rate = 1),
		createBenchmark(funcNum = 8, shape = 1, scale = 1),
		createBenchmark(funcNum = 9, mean = 0, sd = 1),
		createBenchmark(funcNum = 10, mean = 0, sdlog = 1),
		createBenchmark(funcNum = 11, df = 5),
		createBenchmark(funcNum = 12),
		createBenchmark(funcNum = 13, df1 = 100, df2 = 100))

benchmarks <- do.call(rbind, bechmarks)

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
microbenchmark(runif(n), runifCpp(n, 0, 1), runifCpp_par(n, 0, 1), times = 1)
