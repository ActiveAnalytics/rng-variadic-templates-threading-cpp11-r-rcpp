rng-variadic-templates-threading-cpp11-r-rcpp
=============================================

Code from Active Analytics Blog: Random number generation using variadic template functions, and threading in C++11 and R with Rcpp

This library provides an interface to R for the C++11 random number generation tools, but it also provides a variadic template that allows distributions that gives a convenient way to call the distributions in C++ using one master function.

There are two variadic templates:

*randomCpp* variadic template function allows the user to sample from distributions in single threaded mode
*randomCpp_par* variadic template function allows the user to sample from the distributions in multithreaded mode

Please read the following blog entry carefully, it provides implementation considerations for the use of the code ...
http://www.active-analytics.com/blog/rng-variadic-templates-threading-cpp11-r-rcpp/

# The distributions.cpp file

This file contains the C++ code which includes the variadic templates and the R SEXP interface.

# The distributions.r file

This file contains example for how to call the functions from R.

# Example calls

Here are some example code snippets that sample uniform and normal distributons

## Sampling from a uniform distribution:

```
int n;
double min = 0;
double max = 1;
std::vector svec(n);
std::vector mvec(n);
/* Single Threaded */ 
svec = randomCpp<uniform_real_distribution, double>(n, min, max)
/* Multi Threaded */ 
mvec = randomCpp_par<uniform_real_distribution, double>(n, min, max)
```

## Sample from a normal distribution

```
int n;
double mean = 0;
double sd = 1;
std::vector svec(n);
std::vector mvec(n);
/* Single Threaded */ 
svec = randomCpp<normal_distribution, double>(n, mean, sd)
/* Multi Threaded */ 
mvec = randomCpp_par<normal_distribution, double>(n, mean, sd)
```

