---
title: "Invest everyday, biweekly, or monthly?"
author: "Ken Koon Wong"
date: '2022-10-06'
slug: 'investbiweekly'
categories: 
- r
- R
- investment
- monte carlo
- dollar cost average
- index fund
- dividend
tags: 
- r
- R
- investment
- monte carlo
- dollar cost average
- index fund
- dividend
excerpt: Which strategy is the most optimal for dollar cost averaging? Let's play with data!
---

> `Biweekly` did great overall, Better at TIPS, short-term bond, real estate, international; `Monthly` is second best. Good at small, mid, large caps

<p align="center">
  <img width="400" height="300" src="featured.jpg">
</p>

If you want to automate your investment on index funds with a fixed amount every month, is there a better way to divide the investment? Such as once a month, everyday, or biweekly? I'm very curious about this.  

### Disclaimer:
I am not a financial adviser. Everything that I shared here were purely out of curiosity and to spark questions for experts to explore the idea further. Also, to utilize our data science skills to explore available data to inform one own's decision. Please take in any information at your own discretion. If you believe that the methodology is erroneous, please feel free to contact and educate me. I'm more than happy to learn from you!

# Thought Process:
- [Let's Look at FXAIX](#lets-look-at-fxaix)
- [It's Playtime !](#its-playtime-)
  - [Let's play with old data](#lets-play-with-old-data)
- [Data dive with Monte Carlo](#data-dive-with-monte-carlo)
  - [First 48 rows of Data](#first-48-rows-of-data)
  - [May the Best Strategy Win!](#may-the-best-strategy-win)
  - [Visualize our Winner](#visualize-our-winner)
  - [Is our winner a true winner?](#is-our-winner-a-true-winner)
  - [Bird's Eye View](#birds-eye-view)
  - [Zoom in on FXAIX](#zoom-in-on-fxaix)
- [Limitations/Oppurtunities for improvement](#limitationsoppurtunities-for-improvement)
- [Conclusion/Lessons Learnt](#conclusionlessons-learnt)
    
  
#### Load R Packages 

```r
library(tidyverse)
library(tidyquant)
library(kableExtra)
```
 

 
 
## Let's Look at FXAIX

```r
from <- "2018-01-01"
to <- "2022-10-1"


tq_get("FXAIX", from = from, to = to) %>%
  select(date,close) %>%
  ggplot(.,aes(x=date,y=close)) +
  geom_point(alpha = 0.5) +
  # geom_line(color = "blue") +
  theme_bw() +
  ggtitle("Fidelity S&P 500 closing prices")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="672" />

The visual does give us an idea that past performance is not indicative of future results. Look at the peaks and troughs, it sure looks like it has a life of its own. 


## It's Playtime !
### Let's play with old data

<p align="center">
  <img width="300" height="300" src="play.jpg">
</p>


Assuming that we  want to automatically invest \$200 per month, how would the return of investment look like with dividend reinvestment in daily, biweekly, and monthly strategy, if we had invested from 2018-01-01 to 2022-10-1. 

One strategy that most financial advisors would provide is to diverse one's portfolio. Lets diverse our portfolio to include bonds (short term, TIPS etc), small/mid/large caps, real estate, international indices, all through Fidelity. To make things simple, we are going to simulate contribution of the same amount, which is \$200 for each index fund. 

Hence, we have selected the following index funds:
- FIPDX (Fidelity® Inflation-Protected Bond Index Fund)
- FNSOX (Fidelity® Short-Term Bond Index Fund)
- FREL (Fidelity® MSCI Real Estate Index ETF)
- FSMDX (Fidelity® Mid Cap Index Fund)
- FSSNX (Fidelity® Small Cap Index Fund)
- FTIHX (Fidelity® Total International Index Fund)
- FUAMX (Fidelity® Intermediate Treasury Bond Index Fund)
- FXAIX (Fidelity® 500 Index Fund)

#### Tips/Disclaimers:
*You could potentially rewrite/change existing code to simulate DAvid Swenson's Asset allocation portfolio. To read more about David Swenson Yale Endowment Portfolio. [Click here](http://www.lazyportfolioetf.com/allocation/david-swensen-yale-endowment/)* 

*Also please note that I use Fidelity as an example for simplicity purposes. You could use other brokers such as Vanguard, iShares, etc,*

*Spend some time assessing all of their expense ratio too*


```r
x <- "FXAIX"
ticker(x)  
df <- df %>% 
  add_row(tibble(from=from,to=to,ticker=x,daily=daily_ri,biweekly=biweekly_ri,monthly=monthly_ri,daily_gain=percent_gain_daily_ri,biweekly_gain=percent_gain_biweeekly_ri,monthly_gain=percent_gain_monthly_ri)) 

holdings <- c("FXAIX","FIPDX", "FNSOX", "FREL","FSMDX","FSSNX","FTIHX","FUAMX")


for (i in holdings) {
  ticker(i)  
  df <- df %>% 
  add_row(tibble(from=from,to=to,ticker=i,daily=daily_ri,biweekly=biweekly_ri,monthly=monthly_ri,daily_gain=percent_gain_daily_ri,biweekly_gain=percent_gain_biweeekly_ri,monthly_gain=percent_gain_monthly_ri)) 
}
```

*my next blog will describe how to write the above function!*

![](100122.png)
Wow, this is pretty cool. It does look like biweekly investment is better than daily or month. In terms of gain, there is a slightly higher percentage than the rest. And also if there is a lost, it loses less as well (less negative). But is this real? Let's dive in

For clarity `daily_gain`, `biweekly_gain`, and `monthly_gain` units are in percentage. 

## Data dive with Monte Carlo:
Let's randomly pick 50 end dates after 1-1-2019 and see how well did biweekly investment do. Do you think there is a difference? I would imagine 50 random dates will give us some idea of the distribution of which has higher percentage gain. It will also, hopefully, captures some of the peaks and troughs. I estimated that each run of the `ticker()` function takes about 36 seconds to pull information. Fifty is a good number that will take about 25-26 minutes to finish accumulating data. 

### First 48 rows of Data

```r
df %>%
  print(n = 48)
```

![](48row.jpg)

<br>

### May the Best Strategy Win!

```r
df <- df %>%
  mutate(strategy = case_when(
    daily_gain > biweekly_gain & daily_gain > monthly_gain ~ "daily",
    biweekly_gain > daily_gain & biweekly_gain > monthly_gain ~ "biweekly",
    monthly_gain > daily_gain & monthly_gain > biweekly_gain ~ "monthly",
    TRUE ~ "dunno"
  )) 
```

Basically creating a new column with conditions that tells me which of the 3 investment strategy has the highest yield.


#### Sneak peek

```r
df %>%
  kbl() %>%
  kable_classic()
```


![](kable_df.png)

<br>

### Visualize our Winner

```r
df %>%
  ggplot(.,aes(x=strategy,fill=strategy)) +
  geom_histogram(stat = "count", col = "black", alpha = 0.8) +
  theme_bw() 
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="672" style="display: block; margin: auto;" />


Interesting! Biweekly seems to be ahead. Is it the same for all tickers?

<br>

### Is our winner a true winner?

<p align="center">
  <img width="500" height="250" src="medal.jpg">
</p>


```r
df %>%
  mutate(strategy = as.factor(strategy)) %>%
  group_by(ticker,strategy) %>%
  summarize(count = n()) %>%
  ggplot(.,aes(x=strategy,y=count, fill=strategy)) +
  geom_col(col = "black", alpha = 0.8) +
  theme_bw() +
  scale_x_discrete(drop=FALSE) +
  facet_wrap(.~ticker,scales = "free") 
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-9-1.png" width="672" style="display: block; margin: auto;" />



Not bad! 
- `Biweekly` does great overall, 4 out of 8.(FIPDX, FNSOX, FREL, FTIHX)
  - theme: TIPS, short-term bond, real estate, international
- `Monthly` is second best with 3 out of 8. (FSMDX, FSSNX, FXAIX)
  - theme: small, mid, large caps
- `Daily` is last, 1 out of 8. (FUAMX)
  - theme: intermediate treasury bond

If we were to explore further, being a winner does not mean you make \$\$\$. For some funds it just means you have less losses, let's find out more.

<br>

### Bird's Eye View

```r
df %>%
  # mutate(to = lubridate::ymd(to)) %>%
  select(-daily,-biweekly,-monthly,-strategy) %>%
  pivot_longer(cols = c("daily_gain","biweekly_gain","monthly_gain"), names_to = "strategy", values_to = "percent_gain") %>%
  ggplot(.,aes(x=to,y=percent_gain,fill=strategy)) +
  geom_col(alpha=0.9,position = "dodge") +
  # geom_line() +
  theme_bw() +
  facet_wrap(.~ticker,scales="free") +
  theme(axis.text.x = element_text(size = 4,angle = 45, hjust = 1)) 
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="1920" style="display: block; margin: auto;" />

[click here for bigger view](index_files/figure-html/unnamed-chunk-10-1.png)

Wow, very busy faceted graphs! What I've observed is that `biweekly` seems to have slightly higher percentage gain and less percentage losses when evaluated during a bear market. This is very helpful because if the plan is to have a fixed income at retirement, preparing for a bear market is probably a better strategy in my opinion.

<br>

### Zoom in on FXAIX


![](fxaix.png)


## Limitations/Oppurtunities for improvement
- First trade started on 2018-1-1. 
  - Future idea: randomly select starting date as well as end date. But the idea is to assess which of these strategies is best for dollar cost average 
- Only on index funds, except for ETF (FREL).
  - Future idea: change codes to assess a variety of stocks/mutual funds/ETF/bonds
- Only Fidelity Index funds. 
- No asset allocation.

<br>

## Conclusion/Lessons Learnt
- `biweekly` investing appears to have highest yield when compared the rest
  - `Biweekly` 4 out of 8.(FIPDX, FNSOX, FREL, FTIHX)
    - theme: TIPS, short-term bond, real estate, international
  - `Monthly` 3 out of 8. (FSMDX, FSSNX, FXAIX)
    - theme: small, mid, large caps
  - `Daily` 1 out of 8. (FUAMX)
    - theme: intermediate treasury bond
- helpful codes/erros
  - `scale_x_discrete(drop=FALSE)` to prevent dropping if the x factor has n = 0, so that it looks nice when visualizing
  - exited a knit early and because of `index.Rmarkdown.lock`, I was unable to knit further unless if I deleted the file
- When is the best time to start investing? 10 years ago. When is the second best? Today.

<br>

If you like this article:
  - please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/) or [GitHub](https://github.com/kenkoonwong/)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
