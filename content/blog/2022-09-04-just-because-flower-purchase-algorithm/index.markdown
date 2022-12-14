---
title: Purchase Flower For Just Because Occasion. How `R` you doing it?
author: Ken Koon Wong
date: '2022-09-04'
slug: 'flower-algo'
categories: 
- R
- r
- just because
- monte carlo
- web scraping
- rvest
- reticulate
- python
- curl
- selenium
- chromedriver
tags:
- R
- r
- just because
- monte carlo
- web scraping
- rvest
- reticulate
- python
- curl
- selenium
- chromedriver
excerpt: Just Because in a true sense :D 
---

# Just Because == Randomness
Randomness can be difficult to simulate because we are biased. Not that thinking of buying your spouse 😍 flowers is a bad thing. What if you can preserve that idea and actualization by coding that! But how?

![](featured-flower.jpg)

## Thought Process:
1. [How often do you want to buy flowers for just because occasion?](#1-how-often-do-you-want-to-buy-flowers-for-just-because-occasion) 
2. [Set up randomness to that frequency of purchase](#2-set-up-randomness-to-that-frequency-of-purchase)
3. [Scrape the flower website](#3-scrape-the-flower-website) 
    1. Get all flower URLs
    2. Randomly select one kind of flower link
4. [Email you with one-click URL](#4-email-you-with-one-click-url) 
5. [Set a daily script run](#5-set-a-daily-script-run)

## 1. How often do you want to buy flowers for just because occasion?
Ok, say for example, you want to buy flowers on average every 2 weeks. So that is `52 / 2 = 26`. Let's also assume that we may occasionally buy flowers for other special occasions such as Valentine's day, Birthday, Anniversary etc. 

For **generosity purpose**, let's plan to buy flowers **24 times out of 365 days**. Goodness me, if it is $50 per purchase, we will be spending on average $1200 per year just on flowers! Anyway, it's for 💗 which should be priceless! 😆 

FYI, this is purely for example purposes. Please do not take this as a baseline or default.

## 2. Set up randomness to that frequency of purchase

```r
t <- rbinom(n = 1,size = 1,prob = 24/365)
```

With the above `rbinom` code, we are basically running a random generation of binomial distribution with the seeting `n` of 1 (return 1 result), `size` of 1 (only run 1 time), and the probability of giving a 1 is 24 times out of 365 days.

If `n` is set to 2, it will return a vector of 2 results. 

`t` will be either `0` or `1`. In our setting, we're going to choose `0` as not to buy flowers, and `1` as to buy flowers.

## 3. Scrape the flower website 

```r
library(tidyverse)
library(rvest)
library(reticulate)

if (t==1) { 

# amazon website of the flower store, you can choose any store, really
af <- "https://www.amazon.com/stores/Benchmark+Bouquets/page/42547BCC-0B74-4473-BA15-5AA10EB16169?ref_=ast_bln"

# import selenium from python
# py_install("selenium"), #uncomment this if you have not installed selenium
sel <- import("selenium")

# import webdriver
driver <- sel$webdriver

# Set chrome options
chrome_options <- sel$webdriver$ChromeOptions()
chrome_options$add_argument('--headless')
chrome_options$add_argument('--no-sandbox')

# For windows you may have to do the following
# chromedriver path
# path <- "" #insert your chromedriver path, if you have not downladed, go to https://chromedriver.chromium.org/downloads and select the version compatible to your chrome
# browse <- driver$Chrome(executable_path = path,options=chrome_options)

# set up browser, see above if this does not work
browse <- driver$Chrome(options=chrome_options)

# Go to af URL
browse$get(af)
Sys.sleep(3)

# Download the whole HTML code of the site
html <- browse$execute_script("return document.documentElement.outerHTML")

# Use rvest to scrape xpath
flower <- read_html(html) %>%
  html_nodes(xpath = "//*/div/div/div/div/ul/li/div[1]/a/@href") %>% # see comment 3.1
  html_text()

# Close your browser
browse$close()

# create the body of message to send via email
message <- paste("Subject: Flower\r\n\r\n",paste0(
  "Time to buy some flowers, Ken! 
  Thanks for keeping the family floral and happy ! :) ",
  "https://www.amazon.com",sample(flower,1)), # see comment 3.2
  collapse = "\r\n") 

} else { 
  # if t is not 1 then, message will be assigned this value
  message <- paste("Subject: Flower\r\n\r\n",paste0("none for today"),
                   collapse = "\r\n") 
  }
```

The codes are pretty self-explanatory.

- if `t` is 1, remember the `t` from rbinom? Then:
  - visit the website
  - get the whole html
  - comment 3.1: 
    - look for the URL to one of the flower links 
    - right click on it and click on `inspect`
![](inspect.jpg)
    - then right click on the highlighted `div` section and select `copy` and then `copy XPath`
<img src="xpath.jpg" width="600" height="380"/>
    - which you should see something like `//*[@id="ProductGrid-PMiOmKO"]/div/div/div/div/ul/li[2]/div[1]/a`
    - if you scroll back up to the code above the xpath used was `//*/div/div/div/div/ul/li/div[1]/a/@href`, the only differences are `no id` and `li` was without number, which gives us all of the different flower URLs
    - Tips: I generally will copy and paste 2 xpaths of interest and compare it side by side and then change the xpath accordingly to recognize all the URL I want. Also added `@href` to return the URL
  - comment 3.2: Sampling 1 of the many flower URLs scraped
  - create a generic body of email message 
  - if `t` is 0, then create a different generic body of email message

  
## 4. Email you with one-click URL 

```r
library(curl)

# you actually need a gmail account for this
from <- Sys.getenv("auto_email") 
to <- "timetogetyourspouseflower@automation.io" # please change to your email, this is just for kicks

# using for loop in case it goes to more than 1 email account
for (i in to) {
  
  send_mail(mail_from = from,mail_rcpt = i, smtp_server = "smtps://smtp.gmail.com:465", message = message,verbose = TRUE, username = Sys.getenv("auto_email_user"), password = Sys.getenv("auto_email_pass"))
  
  # setting 15 seconds because gmail uses 15 seconds to be able to send another email, i believe
  Sys.sleep(15)
}
```

Again, rather self-explanatory code we have above. It uses package `curl` to send a simple message which looks like this. 

Tips: you need to set up [Google App Password](https://support.google.com/accounts/answer/185833?hl=en) in order to get the password which I have saved in my `.Renviron`. [See this](https://cran.r-project.org/web/packages/httr/vignettes/secrets.html) for further reading on saving and retrieving your password in `.Renviron`, go to section `Environment Vairable`

<p align="center">
  <img width="800" height="100" src="email.jpg">
</p>

<br>

## 5. Set a daily script run

```bash
# I use Raspberry pi, on terminal, run this
crontab -e # comment 5.1

# add this to the script
15 9 * * * sudo Rscript /path/to/your/Rscript # comment 5.2

```

- comment 5.1: if you have never used [crontab](https://www.man7.org/linux/man-pages/man5/crontab.5.html) in bash before, check the manual out
- comment 5.2: `15 9 * * *` means everyday at 9.15am, run this code 
- Tips: Of course this is in Raspberry Pi, which uses Debian as OS. If you are windows user, please check out [Tasks Scheduler](https://www.windowscentral.com/how-create-automated-task-using-task-scheduler-windows-10)

<br> 

# Phewww... That's a lot of code
<p align="center">
  <img width="300" height="500" src="https://media.giphy.com/media/v65rDtklV9l6g/giphy-downsized-large.gif">
</p>

We can finally high-five ourselves! Pat your past, present and future self on the back because we have created a system that reminds us to be grateful to our spouse. 


# Conclusion/Lessons Learnt:
- `R` and `python` do work well together through `reticulate`
- Learn probability theory through real life
  - I realized that I don't always get a link every 2 weeks, sometimes I receive links back to back for several days! 
- There are ways to remind ourselves to be grateful. Why not use technology for this! 


This algorithm/coding is dedicated to my wife `Naomi Tyree`. Always so supportive, caring, and sometimes, just because ❤️
