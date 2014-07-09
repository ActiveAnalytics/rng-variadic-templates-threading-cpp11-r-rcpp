// [[Rcpp::depends(Rcpp)]]
// [[Rcpp::plugins(cpp11)]]
#include <Rcpp.h>
#include <iostream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <numeric>
#include <random>
#include <thread>
#include <sstream>
#include <utility>

using namespace std;
using namespace Rcpp;

/* Single Threaded functions */

/* 
 * Generic Random sampler function
 * 
 * D is the distribution type
 * T is the return vector element type, e.g. int, double etc
 * Args... args is for forwarding the list of arguments
 *
 */

template <template<typename> class D, typename T, typename... Args>
SEXP randomCpp(int n, Args&&... args)
{
	vector<T> rVec(n);
	random_device rdev{};
	mt19937_64 e{rdev()};
	D<T> d{args... };
	generate(rVec.begin(), rVec.end(), [&d, &e](){return d(e);});
	return wrap(rVec);
}


/* Wrapper functions for R */

/* Uniform distribution */
//[[Rcpp::export]]
SEXP runifCpp(int n, double min = 0, double max = 1)
{
	return randomCpp<uniform_real_distribution, double>(n, min, max);
}


/* Integer uniform distribution */
// [[Rcpp::export]]
SEXP rIunifCpp(int n, int min = 0, int max = 10)
{
	return randomCpp<uniform_int_distribution, int>(n, min, max);
}

/* Binomial Distribution */
//[[Rcpp::export]]
SEXP rbinomCpp(int n, int size = 1, double prob = .5)
{
	return randomCpp<binomial_distribution, int>(n, size, prob);
}

/* Geometric Distribution */
//[[Rcpp::export]]
SEXP rgeomCpp(int n, double prob = .5)
{
	return randomCpp<geometric_distribution, int>(n, prob);
}

/* Negative Binomial Distribution */
//[[Rcpp::export]]
SEXP rnbinomCpp(int n, int size = 1, double prob = .5)
{
	return randomCpp<negative_binomial_distribution, int>(n, size, prob);
}


/* Poisson Distribution */
//[[Rcpp::export]]
SEXP rpoisCpp(int n, double lambda = 1)
{
	return randomCpp<poisson_distribution, int>(n, lambda);
}


/* Exponential Distribution */
//[[Rcpp::export]]
SEXP rexpCpp(int n, double rate = 1)
{
	return randomCpp<exponential_distribution, double>(n, rate);
}


/* Gamma Distribution */
//[[Rcpp::export]]
SEXP rgammaCpp(int n, double shape = 1, double rate = 1)
{
	return randomCpp<gamma_distribution, double>(n, shape, rate);
}


/* Weibull Distribution */
//[[Rcpp::export]]
SEXP rweibullCpp(int n, double shape = 1, double scale = 1)
{
	return randomCpp<weibull_distribution, double>(n, shape, scale);
}


/* Extreme Value Distribution */
//[[Rcpp::export]]
SEXP revdCpp(int n, double location = 0, double scale = 1)
{
	return randomCpp<extreme_value_distribution, double>(n, location, scale);
}


/* Normal Distribution */
//[[Rcpp::export]]
SEXP rnormCpp(int n, double mean = 0, double sd = 1)
{
	return randomCpp<normal_distribution, double>(n, mean, sd);
}


/* Lognormal Distribution */
//[[Rcpp::export]]
SEXP rlnormCpp(int n, double mean = 0, double sdlog = 1)
{
	return randomCpp<lognormal_distribution, double>(n, mean, sdlog);
}


/* Chi-Squared Distribution */
//[[Rcpp::export]]
SEXP rchisqCpp(int n, double df = 1)
{
	return randomCpp<chi_squared_distribution, double>(n, df);
}


/* Cauchy Distribution */
//[[Rcpp::export]]
SEXP rcauchyCpp(int n, double location = 0, double scale = 1)
{
	return randomCpp<cauchy_distribution, double>(n, location, scale);
}


/* F Distribution */
//[[Rcpp::export]]
SEXP rfCpp(int n, double df1 = 1, double df2 = 1)
{
	return randomCpp<fisher_f_distribution, double>(n, df1, df2);
}

/* Multi-threaded functions */

// Template function for filling the vector
template<template<typename> class D, typename T>
void random_fill(D<T> d, vector<T> &rVec, int iThread, int nThread)
{
	int startEl = iThread;
	int i = iThread;
	int vSize = rVec.size();
	random_device rdev{};
	mt19937_64 e{rdev()};
	while(i < vSize)
	{
		rVec[i] = d(e);
		i += nThread;
	}
}

/* Generic sampling Template function as before but this is for multithreaded functions */

template <template<typename> class D, typename T, typename... Args>
SEXP randomCpp_par(int n, Args&&... args)
{
	vector<T> rVec(n);
	int nThreads = thread::hardware_concurrency();
	D<T> d{args...};
	vector<thread> threads;
	for(int i = 0; i < nThreads; ++i)
	{
		threads.push_back(thread(random_fill<D, T>, d, ref(rVec), i, nThreads));
	}
	for_each(threads.begin(), threads.end(), mem_fn(&thread::join));
	return wrap(rVec);
}

/* Multi-threaded Uniform distribution Example */

// [[Rcpp::export]]
SEXP runifCpp_par(int n, double min = 0, double max = 1)
{
	return randomCpp_par<uniform_real_distribution, double>(n, min, max);
}
