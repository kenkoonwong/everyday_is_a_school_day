---
title: "IDWeek 2022 Tweets Shiny App"
author: Ken Koon Wong
date: '2022-12-18'
slug: 'idweek22shiny'
categories: 
- IDweek 2022
- shiny
tags: 
- IDweek 2022
- shiny
excerpt: ⬆️ Learning =  organize \* [ ⬆️curiosity + ⬇️noise  ]
---

> Quick browing of #IDWeek2022 tweets and learn something more efficiently through shiny dashboard!


<p align="center">
  <img width="400" height="400" src="feature2.jpg">
</p>

## Tutorial on How to use this [Shiny App](https://kenkoonwong.shinyapps.io/idweek22/)
- [Dashboard Introduction](#dashboard-introduction)
- [Search through Table Column](#search-through-table-column)
- [Search with | aka OR operator](#search-with--aka-or-operator)
- [Search using Additional Function on the Side Menu](#search-using-additional-function-on-the-side-menu)
- [Negate Filter/Filter out function](#negate-filterfilter-out-function)
- [Limitations](#limitations)
- [Lessons learnt/Conclusions](#lessons-learntconclusions)


## Dashboard Introduction:
![](intro1.jpg)



1. **Search all columns**  
This function searches across all columns and filters out tweets with the keyword entered—the easiest to use.  
2. **Search individual columns**  
This function searches within the select column.  
3. **Additional searches**  
This function is essentially the same as Number 1.  
*Beware that this is overrides the searches in Number 1 and 2. So if this is used, please search through this first before using the search functions on the table*
4. **Negate Filter/Filter out function**  
This function is to negate the search keyword.  
*For example: "Show me all tweets WITHOUT the word \"CMV\" in it"*

## Search through Table Column
![](table_search.jpg)  
Notice how we have to put `[Tt]` in front of `ransplant` ? That is [Regular Expression](https://en.wikipedia.org/wiki/Regular_expression). It basically mean, "show me all tweets on this column with the word `Transplant` or `transplant`. 

## Search with | aka OR operator
![](table_search_or_topright.jpg)
Notice that we are using the top right search function, which will search across all columns and return the desired result.  

`[Tt]ransplant|hiv|HIV` keyword means: Return me any rows with the keywords `Transplant`, `transplant`, `hiv`, or `HIV`. So, if you are interested in HIV or Transplant topics, this is a good way of filtering out the relevant tweets.  

## Search using Additional Function on the Side Menu
![](side_search.jpg)
This function is the same as the top right search function. It searches across the columns.  

This is helpful when you want to search with **AND** operator. Meaning, if you want to filter the topics of interest `[Tt]ransplant|hiv|HIV|Hiv` on the side menu **AND** you want to only include `CMV` in the result. 

> Use side menu search to filter out topic of interet, then use search on table columns to refine your searches

## Negate Filter/Filter out function
![](side_search_negate.jpg)
After filtering out the topic of interest `[Tt]ransplant|hiv|HIV|Hiv`, and you want to **filter out** other topics, in this case [Tt]ecovirimat. Type in your keyword and the check the **Not** for it to work.  

> Negate function is helpful if you want to remove tweets off the result

## Give it a try!
[https://kenkoonwong.shinyapps.io/idweek22/](https://kenkoonwong.shinyapps.io/idweek22/)


## Limitations
- Menu search sticks but table search terms do not  
  - Hence if you want to use the menu search, use that first before the table
- need to know some Regular Expression knowledge
- Cannot confirm if tweet reflects accurate information, but sure creates curiosity to read and dive deep more

## Lessons learnt/Conclusions:
- `dplyr::if_any` function that `filter` across columns
  - very helpful in EDA
- Try searching `[Sstrep]` on the app
  - Step down to oral abx is OK
  - Bactrim + no strep coverage is a myth?
  - Group A Strep pharyngitis, 10 days 
- ⬆️ Learning =  organize \* [ ⬆️curiosity + ⬇️noise  ]

<br>

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
