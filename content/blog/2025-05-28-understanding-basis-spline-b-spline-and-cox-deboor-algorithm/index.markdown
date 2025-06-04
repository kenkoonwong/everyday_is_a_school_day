---
title: Understanding Basis Spline (B-spline) By Working Through Cox-deBoor Algorithm
author: Ken Koon Wong
date: '2025-05-28'
slug: bspline
categories: 
- r
- R
- bspline
- cox-deboor
- spline
- bs
tags: 
- r
- R
- bspline
- cox-deboor
- spline
- bs
excerpt: I finally understood B-splines by working through the Cox-deBoor algorithm step-by-step, discovering they're just weighted combinations of basis functions that make non-linear regression linear. What surprised me is going through Bayesian statistics really helped me understand the engine behind the model! Will try this again in the future!
---

>I finally understood B-splines by working through the Cox-deBoor algorithm step-by-step, discovering they're just weighted combinations of basis functions that make non-linear regression linear. What surprised me is going through Bayesian statistics really helped me understand the engine behind the model! Will try this again in the future!

## Motivations
I've always been curious and amazed by spline as smoothing function. The first time I heard of that was with `mgcv` package on generalized additve model. The second time I heard of that was Richard McElreath's [Statistical Rethinking 2023 videos](https://www.youtube.com/watch?v=FdnMWdICdRs&list=PLDcUM9US4XdPz-KxHM4XHt7uUVGWWVSus), more to come on that. His book cover, that's the product of basis spline, and of course his talent to convert that into wonders. Ther first time I heard him stating that he prefers basis spline smoothing function over polynomial was what caught my attention and never really understood the basics behind it, until recently. It's been mentioned here and there over the year, I've also tried to read up a bit on it and it just did not stick and I was not able to understand it. Hence, the motivation is to get the intuition behind, and nothing better than to actually look at the underlying formula that makes up the function and then code it! I also found that learning this in bayesian way is very helpful as well, as you have to write all the formula yourself, what to estimate, what to include etc. These 2 combinations, simulation and code in bayesian have been very helpful for me to understand the concept better. So, what are we waiting for, let's get some basics in smoothening this spline out!

## Objective
- [What is Basis Spline?](#spline)
- [What is Cox deBoor Recursion Formula?](#coxdeboor)
- [Let's code](#code)
  - [Let's visualize](#visualize)
- [Opportunities for improvement](#opportunity)
- [Lessons Learnt](#lessons)

## What is Basis Spline? {#spline}
Basis spline, or B-spline, is a piecewise polynomial function that is used for smoothing data. It is defined by a set of control points and a degree, which determines the polynomial degree of the segments between the control points. The B-spline is constructed using a set of basis functions, which are defined over a set of knots. The B-spline is a linear combination of these basis functions, where the coefficients are the weights assigned to each basis function.

Wow that's a lot of words! Let's take a look and see when we usually use this function and expand there. Let's write some simulation and then use `mgcv` package and model a `gam` and look at the output. 


``` r
library(tidyverse)
library(mgcv)

set.seed(1)
n <- 1000
x <- runif(n,-5,5)
y <- sin(x) + rnorm(n, 0, 0.5)
df <- tibble(x,y)

df |>
  ggplot(aes(x=x,y=y)) +
  geom_point(alpha = 0.2) +
  theme_bw()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-1-1.png" width="672" />

Alright, we have a dataset with `x` and `y` values, where `y` is a noisy sine wave. Now, let's fit a generalized additive model (GAM) using the `mgcv` package to see how the spline smooths the data.


``` r
gam_model <- gam(y ~ s(x, bs = "cr"), data = df)

df |>
  ggplot(aes(x=x,y=y)) +
  geom_point(alpha = 0.2) +
  geom_line(aes(y = predict(gam_model)), color = "blue", size = 1) +
  theme_bw()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-2-1.png" width="672" />

Look at that nice blue curve! That's our gam model. Looks like it fits a really good non-linear relationship of `x` and `y`. Now let's look at the summary output


``` r
summary(gam_model)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## y ~ s(x, bs = "cr")
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)   
## (Intercept) -0.04663    0.01623  -2.874  0.00415 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##        edf Ref.df   F p-value    
## s(x) 8.545   8.94 211  <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.654   Deviance explained = 65.7%
## GCV = 0.26587  Scale est. = 0.26334   n = 1000
```

The summary output shows us the estimated coefficients for the spline basis functions, the effective degrees of freedom, and the significance of the smooth term. The `s(x, bs = "cr")` indicates that we are using a cubic regression spline (CR) for the smooth term.

Something to pay attention to is the effective degree of freedom (`edf`). It measures the complexity of the wiggliness of the smooth function. edf = 1 means it's linear. the higher the number the higher the wiggliness is. We may on another post look more closely at what these numbers mean, how the check the models etc, but right now I'm more interested in how basis spline is constructed and how it works under the hood. `gam` has a more sophisticated penalty for the wiggliness of the spline, but for now let's just focus on the basics of how the spline is constructed using linear regression. 

$$
y(x) = \sum_{j=1}^{m} c_j B_{j,k}(x) + \varepsilon
$$
Where:

`\(c_j\)` is the coefficient vector (something we want to estimate).    
`\(B_{j,k}\)` is the basis function evaluated at `\(x_i\)` (the design matrix)

If we were to write it in a longer form, it would look like 

$$
y(x) = c_1 B_{1,k}(x) + c_2 B_{2,k}(x) + ... + c_m B_{m,k}(x) + \varepsilon
$$

Instead of fitting `x` directly to `y`, we are fitting the basis functions `\(B_{j,k}(x)\)` to `y`. The coefficients `\(c_j\)` are the weights assigned to each basis function. The basis functions are defined over a set of knots, which are the points where the piecewise polynomial segments meet. The degree of the polynomial is determined by the parameter `k`.

How we construct the basis functions? Well... in comes the Cox deBoor algorithm!

#### To Understand This, We Need To Know The Available Parameters 
- `number of basis functions`: this is called `df` in `spline::bs()`
- `degree`: this is the degree of the polynomial segments, which is usually set to 3 for cubic splines.
- `knots`: Through out this blog, we will use `t` for this. This is the set of knots that define the piecewise polynomial segments. The knots are the points where the polynomial segments meet. The number of knots is determined by the `df` parameter, and the knots are usually evenly spaced within the range of the data.


## What is Cox deBoor Recursion Formula? {#coxdeboor}
The Cox deBoor algorithm is a recursive method for constructing B-spline basis functions. It is based on the idea of piecewise polynomial interpolation, where the polynomial segments are defined over a set of knots. The algorithm allows us to compute the basis functions efficiently without having to evaluate them directly.

The Cox deBoor algorithm is defined as follows:
$$
B_{i,0}(x) =
\begin{cases}
1 & \text{if } t_i \leq x < t_{i+1} \\\
0 & \text{otherwise}
\end{cases}
$$
$$
B_{i,k}(x) = \frac{x - t_i}{t_{i+k} - x_i} \cdot  B_{i,k-1}(x) + \frac{t_{i+k+1} - x}{t_{i+k+1} - t_{i+1}} \cdot B_{i+1,k-1}(x) 
$$

Where:
- `i` is the index of the knot,
- `k` is the degree of the polynomial (we're going to use 3 for cubic spline).    
- `\(t_i\)` and `\(t_{i+k}\)` are the knots, which are the points where the piecewise polynomial segments meet.
- `\(B_{i,0}(x)\)` is the zeroth degree basis function, which is a piecewise constant function defined over the knots.
- `\(B_{i,k}(x)\)` is the k-th degree basis function, which is defined recursively using the previous degree basis functions.
The algorithm starts with the zeroth degree basis functions, which are defined as piecewise constant functions over the knots. Then, it recursively computes the higher degree basis functions using the previous degree basis functions. The recursion continues until the desired degree is reached.

Dive deeper [Cox deBoor Algorithm](https://en.wikipedia.org/wiki/De_Boor%27s_algorithm)

#### OK, That's a lot of letters and subscripts, I'm REALLY confused! 😵‍💫
Let's to the calculation and see how this works. 

Let's assume out `t` aka `knots` for degree 3: `[-3, -2, -1, 0, 1, 2, 3, 4, 5, 6]`. And take note that first first knot starts as `0`. 

1. Let's calculate our zeroth degree basis function at x = 1.5
$$
t_0 = -3, t_1 = -2, t_2 = -1, t_3 = 0, t_4 = 1, t_5 = 2, t_6 = 3, t_7 = 4, t_8 = 5, t_9 = 6 \\\
B_{i,0}(x) =
\begin{cases}
1 & \text{if } t_i \leq x < t_{i+1} \\\
0 & \text{otherwise}
\end{cases} \\\
B_{0,0}(x=1.5) = 
\begin{cases}
1 & \text{if } t_0 \leq x < t_{0+1} \\\
0 & \text{otherwise}
\end{cases} \\\
= 0 \text{ , given } t_0 = -3 \text{ and } t_1 = -2 \\\
B_{1,0}(x=1.5) = 0 \\\
B_{2,0}(x=1.5) = 0 \\\
B_{3,0}(x=1.5) = 0 \\\
B_{4,0}(x=1.5) = 1 \\\
B_{5,0}(x=1.5) = 0 \\\
B_{6,0}(x=1.5) = 0 \\\
B_{7,0}(x=1.5) = 0 \\\
B_{8,0}(x=1.5) = 0 \\\
B_{9,0}(x=1.5) = 0 
$$
2. Now, let's calculate the first degree basis function at x = 1.5
$$
t_0 = -3, t_1 = -2, t_2 = -1, t_3 = 0, t_4 = 1, t_5 = 2, t_6 = 3, t_7 = 4, t_8 = 5, t_9 = 6 \\\
B_{0,1}(x=1.5) = \frac{x - t_0}{t_{1} - t_0} \cdot B_{0,0}(x) + \frac{t_{2} - x}{t_{2} - t_1} \cdot B_{1,0}(x) \\\
= \frac{1.5 - (-3)}{-2 - (-3)} \cdot 0 + \frac{-1 - 1.5}{-1 - (-2)} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{1,1}(x=1.5) = \frac{x - t_1}{t_{2} - t_1} \cdot B_{1,0}(x) + \frac{t_{3} - x}{t_{3} - t_2} \cdot B_{2,0}(x) \\\
= \frac{1.5 - (-2)}{-1 - (-2)} \cdot 0 + \frac{0 - 1.5}{0 - (-1)} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{2,1}(x=1.5) = \frac{x - t_2}{t_{3} - t_2} \cdot B_{2,0}(x) + \frac{t_{4} - x}{t_{4} - t_3} \cdot B_{3,0}(x) \\\
= \frac{1.5 - (-1)}{0 - (-1)} \cdot 0 + \frac{1 - 1.5}{1 - 0} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{3,1}(x=1.5) = \frac{x - t_3}{t_{4} - t_3} \cdot B_{3,0}(x) + \frac{t_{5} - x}{t_{5} - t_4} \cdot B_{4,0}(x) \\\
= \frac{1.5 - 0}{1 - 0} \cdot 0 + \frac{2 - 1.5}{2 - 1} \cdot 1 \\\
= 0 + \frac{0.5}{1} \cdot 1 \\\
= 0.5 \\\
B_{4,1}(x=1.5) = \frac{x - t_4}{t_{5} - t_4} \cdot B_{4,0}(x) + \frac{t_{6} - x}{t_{6} - t_5} \cdot B_{5,0}(x) \\\
= \frac{1.5 - 1}{2 - 1} \cdot 1 + \frac{3 - 1.5}{3 - 2} \cdot 0 \\\
= \frac{0.5}{1} \cdot 1 + 0 \\\
= 0.5 \\\
B_{5,1}(x=1.5) = \frac{x - t_5}{t_{6} - t_5} \cdot B_{5,0}(x) + \frac{t_{7} - x}{t_{7} - t_6} \cdot B_{6,0}(x) \\\
= \frac{1.5 - 2}{3 - 2} \cdot 0 + \frac{4 - 1.5}{4 - 3} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{6,1}(x=1.5) = \frac{x - t_6}{t_{7} - t_6} \cdot B_{6,0}(x) + \frac{t_{8} - x}{t_{8} - t_7} \cdot B_{7,0}(x) \\\
= \frac{1.5 - 3}{4 - 3} \cdot 0 + \frac{5 - 1.5}{5 - 4} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{7,1}(x=1.5) = \frac{x - t_7}{t_{8} - t_7} \cdot B_{7,0}(x) + \frac{t_{9} - x}{t_{9} - t_8} \cdot B_{8,0}(x) \\\
= \frac{1.5 - 4}{5 - 4} \cdot 0 + \frac{6 - 1.5}{6 - 5} \cdot 0 \\\
= 0 + 0 = 0 
$$

3. Now, let's calculate the second degree basis function at x = 1.5
$$
t_0 = -3, t_1 = -2, t_2 = -1, t_3 = 0, t_4 = 1, t_5 = 2, t_6 = 3, t_7 = 4, t_8 = 5, t_9 = 6 \\\
B_{0,2}(x=1.5) = \frac{x - t_0}{t_{2} - t_0} \cdot B_{0,1}(x) + \frac{t_{3} - x}{t_{3} - t_1} \cdot B_{1,1}(x) \\\
= \frac{1.5 - (-3)}{-1 - (-3)} \cdot 0 + \frac{0 - 1.5}{0 - (-2)} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{1,2}(x=1.5) = \frac{x - t_1}{t_{3} - t_1} \cdot B_{1,1}(x) + \frac{t_{4} - x}{t_{4} - t_2} \cdot B_{2,1}(x) \\\
= \frac{1.5 - (-2)}{0 - (-2)} \cdot 0 + \frac{1 - 1.5}{1 - (-1)} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{2,2}(x=1.5) = \frac{x - t_2}{t_{4} - t_2} \cdot B_{2,1}(x) + \frac{t_{5} - x}{t_{5} - t_3} \cdot B_{3,1}(x) \\\
= \frac{1.5 - (-1)}{1 - (-1)} \cdot 0 + \frac{2 - 1.5}{2 - 0} \cdot 0.5 \\\
= 0 + \frac{0.5}{2} \cdot 0.5 \\\
= 0.25 \cdot 0.5 = 0.125 \\\
B_{3,2}(x=1.5) = \frac{x - t_3}{t_{5} - t_3} \cdot B_{3,1}(x) + \frac{t_{6} - x}{t_{6} - t_4} \cdot B_{4,1}(x) \\\
= \frac{1.5 - 0}{2 - 0} \cdot 0.5 + \frac{3 - 1.5}{3 - 1} \cdot 0.5 \\\
= \frac{1.5}{2} \cdot 0.5 + \frac{1.5}{2} \cdot 0.5 \\\
= 0.75 \cdot 0.5 + 0.75 \cdot 0.5 \\\
= 0.375 + 0.375 = 0.75 \\\
B_{4,2}(x=1.5) = \frac{x - t_4}{t_{6} - t_4} \cdot B_{4,1}(x) + \frac{t_{7} - x}{t_{7} - t_5} \cdot B_{5,1}(x) \\\
= \frac{1.5 - 1}{3 - 1} \cdot 0.5 + \frac{4 - 1.5}{4 - 2} \cdot 0 \\\
= \frac{0.5}{2} \cdot 0.5 + 0 \\\
= 0.25 \cdot 0.5 = 0.125 \\\
B_{5,2}(x=1.5) = \frac{x - t_5}{t_{7} - t_5} \cdot B_{5,1}(x) + \frac{t_{8} - x}{t_{8} - t_6} \cdot B_{6,1}(x) \\\
= \frac{1.5 - 2}{4 - 2} \cdot 0 + \frac{5 - 1.5}{5 - 3} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{6,2}(x=1.5) = \frac{x - t_6}{t_{8} - t_6} \cdot B_{6,1}(x) + \frac{t_{9} - x}{t_{9} - t_7} \cdot B_{7,1}(x) \\\
= \frac{1.5 - 3}{5 - 3} \cdot 0 + \frac{6 - 1.5}{6 - 4} \cdot 0 \\\
= 0 + 0 = 0 
$$
Alright, still with me? 

3. Now, let's calculate the third degree basis function at x = 1.5
$$
t_0 = -3, t_1 = -2, t_2 = -1, t_3 = 0, t_4 = 1, t_5 = 2, t_6 = 3, t_7 = 4, t_8 = 5, t_9 = 6 \\\
B_{0,3}(x=1.5) = \frac{x - t_0}{t_{3} - t_0} \cdot B_{0,2}(x) + \frac{t_{4} - x}{t_{4} - t_1} \cdot B_{1,2}(x) \\\
= \frac{1.5 - (-3)}{0 - (-3)} \cdot 0 + \frac{1 - 1.5}{1 - (-2)} \cdot 0 \\\
= 0 + 0 = 0 \\\
B_{1,3}(x=1.5) = \frac{x - t_1}{t_{4} - t_1} \cdot B_{1,2}(x) + \frac{t_{5} - x}{t_{5} - t_2} \cdot B_{2,2}(x) \\\
= \frac{1.5 - (-2)}{1 - (-2)} \cdot 0 + \frac{2 - 1.5}{2 - (-1)} \cdot 0.125 \\\
= 0 + \frac{0.5}{3} \cdot 0.125 \\\
= \frac{1}{6} \cdot 0.125 \\\
= 0.02083 \\\
B_{2,3}(x=1.5) = \frac{x - t_2}{t_{5} - t_2} \cdot B_{2,2}(x) + \frac{t_{6} - x}{t_{6} - t_3} \cdot B_{3,2}(x) \\\
= \frac{1.5 - (-1)}{2 - (-1)} \cdot 0.125 + \frac{3 - 1.5}{3 - 0} \cdot 0.75 \\\
= \frac{2.5}{3} \cdot 0.125 + \frac{1.5}{3} \cdot 0.75 \\\
= \frac{5}{6} \cdot 0.125 + \frac{1}{2} \cdot 0.75 \\\
= 0.104166\overline{6} + 0.375 \\\
= 0.4792 \\\
B_{3,3}(x=1.5) = \frac{x - t_3}{t_{6} - t_3} \cdot B_{3,2}(x) + \frac{t_{7} - x}{t_{7} - t_4} \cdot B_{4,2}(x) \\\
= \frac{1.5 - 0}{3 - 0} \cdot 0.75 + \frac{4 - 1.5}{4 - 1} \cdot 0.125 \\\
= \frac{1.5}{3} \cdot 0.75 + \frac{2.5}{3} \cdot 0.125 \\\
= \frac{1}{2} \cdot 0.75 + \frac{5}{6} \cdot 0.125 \\\
= 0.375 + 0.104166\overline{6} \\\
= 0.479166\overline{6} \\\
B_{4,3}(x=1.5) = \frac{x - t_4}{t_{7} - t_4} \cdot B_{4,2}(x) + \frac{t_{8} - x}{t_{8} - t_5} \cdot B_{5,2}(x) \\\
= \frac{1.5 - 1}{4 - 1} \cdot 0.125 + \frac{5 - 1.5}{5 - 2} \cdot 0 \\\
= \frac{0.5}{3} \cdot 0.125 + 0 \\\
= \frac{1}{6} \cdot 0.125 \\\
= 0.0208\overline{3} \\\
B_{5,3}(x=1.5) = \frac{x - t_5}{t_{8} - t_5} \cdot B_{5,2}(x) + \frac{t_{9} - x}{t_{9} - t_6} \cdot B_{6,2}(x) \\\
= \frac{1.5 - 2}{5 - 2} \cdot 0 + \frac{6 - 1.5}{6 - 3} \cdot 0 \\\
= 0 + 0 
= 0 
$$
Alright, let's look at `spliness:bs()` function in R and see if we get the same result


``` r
library(splines)
x_i <- 1.5
basis_matrix <- splines::bs(x_i, 
                           knots = c(-2, -1, 0, 1, 2, 3, 4, 5),  # interior knots
                           Boundary.knots = c(-3, 6),            # your boundary knots
                           degree = 3)

basis_matrix
```

```
##      1 2 3          4         5         6          7 8 9 10 11
## [1,] 0 0 0 0.02083333 0.4791667 0.4791667 0.02083333 0 0  0  0
## attr(,"degree")
## [1] 3
## attr(,"knots")
## [1] -2 -1  0  1  2  3  4  5
## attr(,"Boundary.knots")
## [1] -3  6
## attr(,"intercept")
## [1] FALSE
## attr(,"class")
## [1] "bs"     "basis"  "matrix"
```

Awesome!!! We have very similar numbers !!! But why are there so many columns? And they're filled with zeros, reminds me almost like padding. Apparently this is mainly to ensure no issues when `x` is very close to `boundary knots` is my understanding. And the way they add these padding depends on `degrees + 1` if you use `degree = 3`, add `1` to it and that would be how many repeats of the numbers of your boundary knots. 

Wow, that was really cool! Can't believe we calculated all those, with many many trial and error of course on pen and paper. Let's use `splines::bs()` and create basis matrix for our original dataset!

## Let's code {#code}

``` r
library(splines)

basis_matrix <- bs(x = df$x, df = 10, degree = 3, intercept = T)

basis_matrix |> head(10)
```

```
##              1           2           3         4           5          6
##  [1,] 0.000000 0.001710709 0.254088352 0.6432639 0.100937064 0.00000000
##  [2,] 0.000000 0.000000000 0.008978124 0.3970003 0.559853971 0.03416757
##  [3,] 0.000000 0.000000000 0.000000000 0.0000000 0.146190239 0.65598485
##  [4,] 0.000000 0.000000000 0.000000000 0.0000000 0.000000000 0.00000000
##  [5,] 0.000000 0.061617580 0.518423931 0.4100735 0.009885001 0.00000000
##  [6,] 0.000000 0.000000000 0.000000000 0.0000000 0.000000000 0.00000000
##  [7,] 0.000000 0.000000000 0.000000000 0.0000000 0.000000000 0.00000000
##  [8,] 0.000000 0.000000000 0.000000000 0.0000000 0.008305368 0.38042994
##  [9,] 0.000000 0.000000000 0.000000000 0.0000000 0.032566024 0.51323693
## [10,] 0.200424 0.595242195 0.192030599 0.0123032 0.000000000 0.00000000
##                 7            8         9         10
##  [1,] 0.000000000 0.0000000000 0.0000000 0.00000000
##  [2,] 0.000000000 0.0000000000 0.0000000 0.00000000
##  [3,] 0.197526778 0.0002981355 0.0000000 0.00000000
##  [4,] 0.044205251 0.3880099033 0.5304629 0.03732193
##  [5,] 0.000000000 0.0000000000 0.0000000 0.00000000
##  [6,] 0.059974278 0.4418574606 0.4799942 0.01817410
##  [7,] 0.009664164 0.1778373908 0.5976815 0.21481698
##  [8,] 0.556522931 0.0547417617 0.0000000 0.00000000
##  [9,] 0.435168766 0.0190282776 0.0000000 0.00000000
## [10,] 0.000000000 0.0000000000 0.0000000 0.00000000
```

``` r
attr(basis_matrix, "knots")
```

```
## [1] -3.5289455 -2.0677071 -0.7635657  0.5407687  2.1571925  3.6217023
```

``` r
attr(basis_matrix, "Boundary.knots")
```

```
## [1] -4.986853  4.999306
```
Alright, we have our basis matrix! The `bs()` function returns a matrix where each column corresponds to a basis function evaluated at the `x` values. The `df` parameter specifies the number of basis functions, and the `degree` parameter specifies the degree of the polynomial segments. The `intercept = T` argument adds an intercept term to the model.

Now, let's fit a linear regression model using the basis matrix as the design matrix. This is similar to how we would fit a GAM model, but we will use a linear regression model for simplicity.


``` r
lm_model <- lm(y ~ basis_matrix, data = df)

summary(lm_model)
```

```
## 
## Call:
## lm(formula = y ~ basis_matrix, data = df)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -1.60301 -0.35186 -0.00505  0.35426  1.69358 
## 
## Coefficients: (1 not defined because of singularities)
##                Estimate Std. Error t value Pr(>|t|)    
## (Intercept)     -0.8762     0.1327  -6.602 6.62e-11 ***
## basis_matrix1    1.7943     0.1974   9.090  < 2e-16 ***
## basis_matrix2    1.8904     0.1968   9.605  < 2e-16 ***
## basis_matrix3    1.3809     0.1933   7.143 1.77e-12 ***
## basis_matrix4   -0.2858     0.1688  -1.694   0.0907 .  
## basis_matrix5   -0.0927     0.1671  -0.555   0.5793    
## basis_matrix6    1.9814     0.1622  12.214  < 2e-16 ***
## basis_matrix7    1.7176     0.1867   9.201  < 2e-16 ***
## basis_matrix8    0.6788     0.1588   4.275 2.09e-05 ***
## basis_matrix9   -0.5299     0.2389  -2.219   0.0267 *  
## basis_matrix10       NA         NA      NA       NA    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.5136 on 990 degrees of freedom
## Multiple R-squared:  0.6565,	Adjusted R-squared:  0.6534 
## F-statistic: 210.3 on 9 and 990 DF,  p-value: < 2.2e-16
```

Alright, we have our linear regression model fitted using the basis matrix. 


``` r
df |>
  ggplot(aes(x=x,y=y)) +
  geom_point(alpha = 0.2) +
  geom_line(aes(y = predict(lm_model)), color = "blue", size = 1) +
  theme_bw()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="672" />

Look at that beauty!!! The blue curve is the fitted model using the basis spline. It captures the non-linear relationship between `x` and `y` very well, just like the GAM model we fitted earlier. The coefficients of the basis functions represent the weights assigned to each basis function, which determine the shape of the spline.

### Let's look at all the splines! {#visualize}

``` r
tibble(x = x, y = y) |>
  bind_cols(basis_matrix) |>
  mutate(
    intercept = lm_model$coefficients[1],  # Add this line!
    `1` = `1` * lm_model$coefficients[2],
    `2` = `2` * lm_model$coefficients[3],
    `3` = `3` * lm_model$coefficients[4],
    `4` = `4` * lm_model$coefficients[5],
    `5` = `5` * lm_model$coefficients[6],
    `6` = `6` * lm_model$coefficients[7],
    `7` = `7` * lm_model$coefficients[8],
    `8` = `8` * lm_model$coefficients[9],
    `9` = `9` * lm_model$coefficients[10]
  ) |> 
  mutate(total = intercept + `1` + `2` + `3` + `4` + `5` + `6` + `7` + `8` + `9`) |> 
  ggplot() +
  geom_point(aes(x=x, y=y), alpha = 0.1) +
  geom_line(aes(x=x, y=total), color = "black", size = 1.5, alpha = 0.8) +
  geom_hline(aes(yintercept = intercept), color = "red") +
  geom_line(aes(x, `1`), color = "blue") +
  geom_line(aes(x, `2`), color = "green") +
  geom_line(aes(x, `3`), color = "purple") +
  geom_line(aes(x, `4`), color = "orange") +
  geom_line(aes(x, `5`), color = "brown") +
  geom_line(aes(x, `6`), color = "pink") +
  geom_line(aes(x, `7`), color = "cyan") +
  geom_line(aes(x, `8`), color = "magenta") +
  geom_line(aes(x, `9`), color = "yellow") +
  geom_line(aes(x, `10`), color = "darkgreen") +
  labs(title = "B-spline, black = predicted values (sum of all splines + intercept)",
       subtitle = "y = sin(x) + rnorm(n, sd=0.5)",
       y = "y") +
  theme_minimal()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="672" />

Take note that colors other than `black` are intercept and also the splines. The `black` line is our predicted values, which is the sum of all the splines and the intercept. Notice I didn't use `predict` at all to form the `black` line, we basically summed ALL the weighted coefficients on x and that is our prediction! 🙌 Even though this is not a straight line, it's still linear in nature! This is fascinating! 

The first time time I heard about how we can use splines as predictors in linear regression was on [Richard McElreath's Statistical Rethinking](https://www.youtube.com/watch?v=F0N4b7K_iYQ&list=PLDcUM9US4XdPz-KxHM4XHt7uUVGWWVSus&index=4) with bayesian stats. At 52:15 he discussed why don't use polynomial and how b-spline is not as bad. 59:21 is when he talks about bspline. Highly recommend watching it!


``` r
library(cmdstanr)

stan_code <- "
data {
  int<lower=0> N;             
  int<lower=0> K;              
  matrix[N, K] B;              
  vector[N] y;                
}

parameters {
  vector[K] beta;               
  real<lower=0> sigma;         
}

transformed parameters {
  vector[N] mu;                
  mu = B * beta;               
}

model {
  // Priors
  beta ~ normal(0, 2);        
  sigma ~ exponential(1);      
  
  // Likelihood
  y ~ normal(mu, sigma);       
}

"

# Prepare data for Stan
stan_data <- list(
  N = n,
  K = 10,
  B = basis_matrix,
  y = y
)

# Write stan file
mod <- write_stan_file(stan_code)
model <- cmdstan_model(mod)

# Fit the model
fit <- model$sample(
  data = stan_data,
  chains = 4, 
  iter_sampling = 2000,
  iter_warmup = 1000,
  seed = 1,
  parallel_chains = 4
)

# Posterior
draws <- fit$draws(variables = c("beta", "mu"), format = "df", inc_warmup = F)

# data wrangling, select only mu
df_draw <- draws |>
  mutate(iter = row_number()) |>
  filter(iter %in% sample(1:8000, 1000, replace=F)) |> #sample 1000 iters
  select(iter, contains("mu")) |>
  pivot_longer(cols = contains("mu"), names_to = "mu", values_to = "value") |>
  mutate(idx = str_extract(mu, "\\d+")) |>
  left_join(df |> mutate(idx = row_number() |> as.character()), by = "idx") 
  
# plot
plot <- ggplot() +
  geom_line(data=df_draw, aes(x = x, y = value, group=iter), alpha = 0.009, color="blue") +
  geom_point(data=df,aes(x=x,y=y),alpha=0.2) +
  theme_bw()

plot
```

![](mcmc_plot.png)
What really connected my intuition was when I saw Richard's math formula when constructing a linear model! check out the book Statistical Rethinking page 117. 

$$
\begin{gather}
y_i \sim N(\mu_i, \sigma) \\\
\mu_i = \beta_0 + \sum_{i=1}^{m} \beta_i B_{i,k}(x_i) \\\
\beta_i \sim N(0, 2) \\\
\sigma \sim \text{Exponential}(1) \\\
\end{gather}
$$
This is exactly what we did in the code above! We constructed a linear model with basis splines as predictors, and we can see how the coefficients of the basis functions determine the shape of the spline. 

## Opportunities for improvement {#opportunity}
- `gam` has a more sophisticated penalty for the wiggliness of the spline, which is not captured in this simple linear regression model. 
- more to read up on `gam` on model diagnostics, multivariate splines, and how to interpret the results. 
- how to calculate edf
- `splines::bs()` function also has interesting boundary knot behavior 
- there exists other types of splines, such as natural splines and regression splines, which have different properties and applications.

## Lessons Learnt {#lesson}
- B-splines are a powerful tool for modeling non-linear relationships in regression analysis.
- The Cox deBoor algorithm provides an efficient way to compute B-spline basis functions recursively.
- In the future, if I don't understand certain thing, look at bayesian stats, they often have to construct model from the bottom up, this will help me understand the engine behind
- The `splines::bs()` function in R allows us to easily create B-spline basis matrices for regression analysis.


If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)


