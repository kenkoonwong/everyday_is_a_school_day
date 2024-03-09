---
title: My Simple Understanding of Total Effect = Direct Effect + Indirect Effect (via Mediator)
author: Ken Koon Wong
date: '2024-03-03'
slug: totaleffect
categories: 
- r
- R
- total effect
- direct effect
- indirect effect
- mediator
- causal inference
- Notes
tags: 
- r
- R
- total effect
- direct effect
- indirect effect
- mediator
- causal inference
- Notes
excerpt: I've struggled with differentiating between total, direct, and indirect effects, so this blog/note serves as a personal reference to solidify my understanding and make future amendments as needed. While there are comprehensive articles available, this is a simplified explanation for myself and potentially others
---

> I've struggled with differentiating between total, direct, and indirect effects, so this blog/note serves as a personal reference to solidify my understanding and make future amendments as needed. While there are comprehensive articles available, this is a simplified explanation for myself and potentially others

![](feature.jpeg)

## Objectives
- [Reason For This Note](#reason)
- [DAG it out](#dag)
- [Example](#example)
- [Simulate](#sim)
- [Calculate](#calc)
- [Lessons learnt](#learnt)


## Reason For This Note {#reason}
I've always had problem understanding the difference between total, direct, and indirect effect, even though it should sound fairly straightforward (mind you it is), but I still had problem grasping the intuition behind. Hence, this blog/note is to write down what I understand, so that I can refer to in the future, make more notes or amendments, if I found out certain things/concepts that I've noted are wrong. There are great articles out there, this is not an attempt to re-create that but more so a note for myself, perhaps others as well, for a simpler explaination of the concept.


## DAG It Out {#dag}
<p align="center">
  <img src="dag.png" alt="image" width="80%" height="auto">
</p>

Here we have:     
`X` : Treatment    
`Y` : Outcome       
`Z` : Mediator    
`b` : Path Coefficient of the effect of X on Y     
`c` : Path Coefficient of the effect of X on Z    
`d` : Path Coefficient of the effect of Z on Y

The total effect here would be `b + cd`. If we are interested in direct effect, then it would be just `b`. If we're interested in the indirect effect then it would `cd`, which is essentially total effect minus direct effect. The DAG displayed above has a partial mediator as opposed to full mediator such as this. 

<p align="center">
  <img src="full_med.png" alt="image" width="50%" height="auto">
</p>

The above all made sense mathematically but the problem I couldn't quite grasp is when do we want to know the direct vs the total effect? I think have exammples will be helpful to get a glimpse of the intution. 

## Examples {#example}
A quick search on the internet, I was able to find a few examples using mediation analysis to look at direct effect of interest. In my mind at least, having some examples would be helpful to conceptualize the intuition behind total effect, direct effect, and indirect effect.     

1. [Causal effects and immune cell mediators between prescription analgesic use and risk of infectious diseases: a Mendelian randomization study](https://www.frontiersin.org/journals/immunology/articles/10.3389/fimmu.2023.1319127/full)
![](analgesic.png)
From my understanding, with this study, the idea is to assess if there is any direct causal relationship between analgesics and infection. As some analgesics have tendencies to suppress immune system, one would like to know is the relationship all mediated through low immunesuppressed status, or there is some direct relationship between analgesics and infection. 


<br>

2. [The mediating factors in the relationship between lower urinary tract symptoms and health-related quality of life](https://bmcresnotes.biomedcentral.com/articles/10.1186/s13104-017-2928-7)
![](uti.png)
Same thing here, the study assess whether change in severity of UTI itself is the cause of change of quality of life without mediation of change in mental health, basically assessing direct causal effect as opposed to total effect.

<br>

3. [A chain mediation model on COVID-19 symptoms and mental health outcomes in Americans, Asians and Europeans](https://www.nature.com/articles/s41598-021-85943-7)
![](covid.png)
Here is another interesting study design that looked at whether the physical symptoms resembling COVID-19 infection would be positively associated with adverse mental health outcomes. 

Other things that I could think of, which could be possible new research area (there may already have been studies done on these, I may not have looked hard enough), such as: 

<p align="center">
  <img src="uti_abx.png" alt="image" width="50%" height="auto">
</p>

or CDI and symptom resolution mediated by absence of toxin.    
<p align="center">
  <img src="cdi.png" alt="image" width="50%" height="auto">
</p>

or certain antimicrobial and respiratory symptom improvement.
<p align="center">
  <img src="resp.png" alt="image" width="50%" height="auto">
</p>

Here is a non-medical example by Aleksander Molak, the author of [Causal Inference and Discovery in Python: Unlock the secrets of modern causal machine learning with DoWhy, EconML, PyTorch and more](https://www.amazon.com/Causal-Inference-Discovery-Python-learning/dp/1804612987/ref=sr_1_1?crid=3SXO9DSBQJO0&dib=eyJ2IjoiMSJ9.Q-huGwTFky1V1O7_BJ79vzyjDzYMCOmLPMOyKaDqukcXzAixNj4NSKHPVkjm-bf_dwppbsogVn849NkFqocaX5PggMvdrevjif5lvM8ke_u4UJjDBOLb9czRSaMrpJzQVyfDf9Oa_3O7vIDBrOboDDnkqSL0GdUlb2in4JGTbAtYYXokWItWZdsEDknclyHi4xBizko-ylqvhViW6LCnGN2e_AOQFIuRMZcF1GHQ22k.ylJ-jdHUOqLptj9Gf4Rw0QxnSflFYmuOi8A7Qj0GCzs&dib_tag=se&keywords=causal+discovery&qid=1710021436&sprefix=causal+discovery%2Caps%2C108&sr=8-1)

<p align="center">
  <img src="alek.png" alt="image" width="80%" height="auto">
</p>

What a guy! He took time to explain simple things like these. This is truly inspiring. What a role model! The marketing campaign made sense!

## Simulation {#sim}
Let's revisit out DAG. 
<p align="center">
  <img src="dag.png" alt="image" width="80%" height="auto">
</p>

We will simulate these variables as continuous data. 


```r
library(tidyverse)
library(kableExtra)

set.seed(1)
n <- 1000
x <- rnorm(n)
z <- 0.5*x + rnorm(n,0,0.05)
y <- 0.25*x + 0.4*z + rnorm(n)

tibble(x,z,y) |>
  head() |>
  kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> x </th>
   <th style="text-align:right;"> z </th>
   <th style="text-align:right;"> y </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> -0.6264538 </td>
   <td style="text-align:right;"> -0.2564787 </td>
   <td style="text-align:right;"> -1.1453545 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1836433 </td>
   <td style="text-align:right;"> 0.1474183 </td>
   <td style="text-align:right;"> -1.8173768 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.8356286 </td>
   <td style="text-align:right;"> -0.4613532 </td>
   <td style="text-align:right;"> 1.2262523 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.5952808 </td>
   <td style="text-align:right;"> 0.8081770 </td>
   <td style="text-align:right;"> 1.2413609 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.3295078 </td>
   <td style="text-align:right;"> 0.1682237 </td>
   <td style="text-align:right;"> 0.0938165 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.8204684 </td>
   <td style="text-align:right;"> -0.4933666 </td>
   <td style="text-align:right;"> 0.2939539 </td>
  </tr>
</tbody>
</table>

#### Total Effect Model

```r
total <- lm(y ~ x)
summary(total)
```

```
## 
## Call:
## lm(formula = y ~ x)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -3.5516 -0.6371 -0.0202  0.6911  2.8081 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  0.01556    0.03261   0.477    0.633    
## x            0.49932    0.03152  15.841   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.031 on 998 degrees of freedom
## Multiple R-squared:  0.2009,	Adjusted R-squared:  0.2001 
## F-statistic: 250.9 on 1 and 998 DF,  p-value: < 2.2e-16
```

Here we can see that the total effect of a change in `y` related to a one-unit change of `x` is 0.4993191. On the DAG, this is `b + cd`. But how do we find `b`, `c` and `d` respectively?

## Calculate {#calc}
#### Finding `c`
<p align="center">
  <img src="x_z.png" alt="image" width="50%" height="auto">
</p>

We changed the `outcome` to `z` and there is no open bias path because there is a collider. Hence, we can model it directly as `z ~ x`


```r
x_z <- lm(z ~ x)
summary(x_z)
```

```
## 
## Call:
## lm(formula = z ~ x)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.162422 -0.033598 -0.000688  0.037770  0.182216 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -0.0008093  0.0016452  -0.492    0.623    
## x            0.5003216  0.0015904 314.581   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.05202 on 998 degrees of freedom
## Multiple R-squared:   0.99,	Adjusted R-squared:   0.99 
## F-statistic: 9.896e+04 on 1 and 998 DF,  p-value: < 2.2e-16
```

And we get 0.5003216. On the DAG, this is `c`.

#### Finding `d`
<p align="center">
  <img src="z_y.png" alt="image" width="50%" height="auto">
</p>

Now, we changed both the exposure and outcome to `z` (exposure) and `y` (outcome). Do you see the red warning color of `x` and its edges? This means there there is a bias path. We need to adjust for `x` in order to get a more accurate estimate of `d`.


```r
z_y <- lm(y ~ z + x)
summary(z_y)
```

```
## 
## Call:
## lm(formula = y ~ z + x)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -3.6151 -0.6564 -0.0223  0.6815  2.8132 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  0.01624    0.03260   0.498    0.618
## z            0.84034    0.62709   1.340    0.181
## x            0.07888    0.31533   0.250    0.803
## 
## Residual standard error: 1.031 on 997 degrees of freedom
## Multiple R-squared:  0.2024,	Adjusted R-squared:  0.2008 
## F-statistic: 126.5 on 2 and 997 DF,  p-value: < 2.2e-16
```

Here, we get 0.8403406. On the DAG, this is `d`.

#### Finding `b`
To estimate `b`, we will need to adjust for `z` our partial mediator. The model is essentially the same as `z_y`, the coefficient of x is `b`, which is 0.0788785

#### Total effect = `b` + `c*d`

```r
x_z$coefficients[['x']]*z_y$coefficients[['z']] + z_y$coefficients[['x']]
```

```
## [1] 0.4993191
```

If you want to know why the `indirect effect` is `c*d`, please check out this section [Why Coef Z * Coef X??? Addendum 2-23-24](https://www.kenkoonwong.com/blog/frontdoor/).

Let's check our `total effect` model to see if we the same number!

```r
round(total$coefficients[['x']],6) == round((x_z$coefficients[['x']]*z_y$coefficients[['z']] + z_y$coefficients[['x']]),6)
```

```
## [1] TRUE
```

Yes! We did! I had to round the numbers up 6 decimal points, otherwise it will be `FALSE` 🤣.

## Lessons Learnt {#learnt}
- Finally making sense of total, direct, and indirect effects, I think


#### Side Note:
As I'm reading different coaching books for my coaching notes, I see total effects, direct effects, indirect effects, mediators everywhere! This is kind of fun! 

<p align="center">
  <img src="coaching.png" alt="image" width="80%" height="auto">
</p>

The graph above was taken from the book `Helping People Change` which they adapted from R. E. Boyatzis and K. Akrivou, “The Ideal Self as the Driver of Intentional Change,” Journal of Management Development 25, no. 7 (2006): 624–642. Blue circled are mediators.

Happy identifying! 

If you like this article:
  - please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
