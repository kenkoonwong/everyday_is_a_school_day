---
title: Seeking Inspiration from Random Learning
author: Ken Koon Wong
date: '2022-09-19'
slug: 'random-learning'
categories: 
- R
- r
- random learning
- DT
- list.files
tags: 
- R
- r
- random learning
- DT
- list.files
excerpt: I didn't want to read the textbook in sequence. Hence, I figured that if I read a paragraph a day in a random chapter, I might be able to benefit from random learning!
---
![](featured.jpg)

# Inspiration
This was inspired by wanting to read a textbook [Mandell, Douglas, and Bennett's Principles and Practice of Infectious Diseases](https://www.amazon.com/Bennetts-Principles-Practice-Infectious-Diseases/dp/0323482554). But, I didn't want to read the textbook in sequence. Hence, I figured that if I read a paragraph a day in a random chapter, I might be able to benefit from random learning!  This is also great for idea generation for some of our mysterious cases when we are still building differential diagnoses. But, how do we do that? 


<p align="center">
  <img width="300" height="400" src="mandell.png">
</p>

<br>

# Thought process
- 2 different workstations (personal and work)
  - Hence I will have 2 different directories. Need a system for this
- Get all the pdf files of the textbook in my directory
- Randomly select 1 pdf
- Use `DT` to project the link to browser to read the pdf file

<br>

## 2 different workstations (personal and work)

```r
# Get Sys.info  
compname <- Sys.info()

# if the login is so_and_so, assign home as TRUE
if (compname["login"]=="so_and_so") {
  home <- TRUE } else { home <-FALSE }

# if home is TRUE then assign the following link
if (home) {
  pathurl <- "G:/My%20Drive/mandell/"
  path <- "G:/My Drive/mandell/"
} else {
  path <- "C:/Users/so_and_so/Documents/googledrive/mandell/"
  pathurl <- "C:/Users/so_and_so/Documents/googledrive/mandell/"
}
```
- you can skip this if you are only using 1 computer, or computers with the same login
- Obviously the `so_and_so` is a false login name, you will need to change that. 
- same with the `path` and `pathurl` as well, change it to whatever resource you want to point to
- Note to self: I have to insert `%20` in any white space of the directory in order for the URL to actually work

## Get all the pdf files of the textbook in my directory

```r
file <- list.files(paste0(path))
```

<p align="center">
  <img src="file.png">
</p>
 

## Randomly select 1 pdf

```r
ran <- sample(file,1)
```

<p align="center">
  <img src="random.png">
</p>

## Use `DT` to project the link to browser to read the pdf file

```r
library(tidyverse)
library(DT)

data <- tibble(link = paste0('<a  target=_blank href=file:///',pathurl, ran,'>',ran,'</a>' ))

datatable(data, escape=F)
```

![](dt.png)
<br>

Have to make sure that the `html` code `<a target=_blank href=file:///` and </a> sandwiches the `pathurl` and `ran` which is the actual file name


<br>

![](rightclick.png)
Then you can `right-click` on it and then click `Open link in browser` to open onto default PDF reader
<br>

# Conclusion/Lessons Learnt:
- Everyday random learning is fantastic! Sometimes it inspires me to think a bit differently when I approach a case
- Learnt to add `%20` to any white space if I want to use it as a URL link
- Learnt about `list.files`
- Learnt `<a target=_blank href=file:///`
- Learnt that I could use `DT` to project the URL after putting into a `tibble`
- Daily tips: I usually just highlight the end of paragraph where I left off and resume the next time if I stumble upon the same pdf
