---
title: 'IDWeek2022: Tweets Analysis'
author: Ken Koon Wong
date: '2022-12-17'
slug: 'idweek2022'
categories: 
- idweek2022
- idweek22
- tweets
- twitter
- learning
tags: 
- idweek2022
- idweek22
- tweets
- twitter
- learning
excerpt: 'Thanks to #IDweek2022 Tweets! They warmed our hearts, kept us informed, and made us feel like we (those who could not attend) were part of it!'
---

> I am surprised that the peak tweets are on the 2nd day of the conference, Thursday, instead of Friday. The top tweets each day appeared to be from different users. 

![](wc_full_feature.jpg)
Wordcloud of all the `#IDweek2022` and `#IDweek22` tweets

IDWeek is a great conference to learn, share, and network with other providers who are interested and specialized in Infectious diseases. Even when you cannot attend the conference in person, the virtual presence and support are so helpful! In the Twitterverse, participants have tweeted so much useful information about the conferences they followed, which helped me know what is a hot topic in the meetings and which video seminar I should view to boost ID knowledge. 

If you want to look at the specific tweets, I have created a shiny app that helps me to glance through essential topics. Here is the [link](https://kenkoonwong.shinyapps.io/idweek22/)

### Disclaimer:
- These are actual tweets and not retweets
- There may be some tweets that are missing

# Thought Process:
- [Tweet counts by days](#tweet-counts-by-days) 
- [Top 50 Twitter Users Tweet Counts](#top-50-twitter-users-tweet-counts)
- [Tweets separated by dates](#tweets-separated-by-dates)
- [Word cloud separated by dates](#Word-cloud-separated-by-dates)
- [Looking at tweetiest period](#looking-at-tweetiest-period)
- [Conclusion/Lessons learnt](#Lessons-Learnt/Conclusion)
  
 







## Tweet counts by days 
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="960" style="display: block; margin: auto;" />

10/19 (Thursday) and 10/20 (Friday) had the most tweets! Distribution is quite normal per day. Tweets are the highest as the day warms up, and downtrends as the day wrap.

Interestingly, day three would be as high as day 2, but it isn't. Quite interesting. A high tweet count does not infer significant participation or is associated with the number of attendance. I would love to have concrete attendance data and try to correlate it with it. Well, maybe next time. 

<br>

## Top 50 Twitter Users Tweet Counts
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="960" style="display: block; margin: auto;" />

Holycow! `LordAlirezaF`, `SAIRABT`, and `IDWeek2022` leading the total tweets during the conference!

Can you find your name here? If you can, I thank you for creating a virtual IDweek presence for those who couldn't attend the conference in person!

## Tweets separated by dates 
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-5-1.png" width="1440" style="display: block; margin: auto;" />

Pretty plots! Let's dive deeper!

## Word cloud separated by dates


### 10-18-22
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="960" />

Pre-conference day, where workshops and board reviews happen. You see related terms such as `fellows`,`learn` etc. You also see the enthusiasm that people are flocking back to in-person conferences! It is an inspiring time for those fellows who could not attend ID week in person during the pandemic. I see great energy; a good start!

### 10-19-22
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="960" />

Day one of IDweek 2022. May the excitement begin!  

Lots of `dr`, I would assume, lots of physician references in the tweets. It also looks like people are interested in tweeting `HIV` related topics. Not surprisingly, our new IDSA president, Dr. Carlos del Rio's twitter handle has been mentioned many times by other users! Congratulations!  


### 10-20-22
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-9-1.png" width="960" />

Day two of IDweek 2022.   

Lots of multi-drug resistant topics with keywords such as `antibiotics`, `acinetobacter`, `fungal`,`amr` (antimicrobial resistance). Interestingly, this is the most tweeted day of the conference! Thanks `LordAlirezaF` for the succinct tweets of what is interesting on that day! Take a look at some example!  

![](lordalireza.jpg)
IDweek2022 Tweet Shiny App: filtered by LordAlirezaF [Click here to view all](https://kenkoonwong.shinyapps.io/idweek22/)

If you look closely, you see a username called `friendlycovid19`. This account uses pictures of people without masks and tweets about how ID doctors are not masked during the conference. Lol. It is funny and annoying at the same time. 

In our upcoming analysis, we will look at both including and excluding `friendlycovid19`

### 10-21-22
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="960" />

Day three of IDweek 2022.  

Interesting day. I see keywords such as `data`, `diagnostics` as more prominent. Statistics, data science, and informatics are hot topics for the day, which is fantastic! 

Other prominent keywords are `equity` which IDSA is doing a great job in DEI; and `fleming`, which I assume has to do with The Mold that Changed The World musical play.
 

### 10-22-22
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-11-1.png" width="960" />

Day 4 of IDWeek 2022  

Tweets are slowing down. We're all in awe as reflected by the high frequency keyword of `amazing`!

### 10-23-22
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="960" />

Day 5 of IDweek 2022  

It's a wrap!


## looking at tweetiest period
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-13-1.png" width="960" />

These numbers, in my opinion, make sense. Most people tweet about the conference during morning and afternoon time. Another interesting thing is there are people who tweet during owl time and early morning (I called it 5 am club)! Very dedicated indeed!



# IDweek 2022 Tweets Shiny App
Here is the website to the Shiny App. [https://kenkoonwong.shinyapps.io/idweek22/](https://kenkoonwong.shinyapps.io/idweek22/))

Example of searching keyword `hiv` on the top right corner
![](shiny_hiv.jpg)

You can also use Twitter to search for these keywords. For example, type in `#idweek2022` and `hiv`, should I think return the same tweets. But I thought it is easier to read the short snippets of tweets through Shiny App than Twitter. I also added a little filter myself called `relevant` to filter out the relevant topics to me (set to 1, not so relevant set to 0) for easy browsing. 

### Future blogs
I will be performing a further analysis to assess factors that contribute to Retweets and favorite. Stay tuned!

# Limitations
- Might have missed some tweets
- Did not include RTs
- Assumption that tweet information accurately reflects the content of the conference
- Tweet of the same day did not mean conference occurred on that day


## Things for the future
- I think we should have a social media infrastructure to place synopsis of each conference 

# Lessons Learnt/Conclusion
- I learnt a lot from the tweets! Thank you all who contributed!
- `wordcloud2` package makes better word count 
- `rtweet` is fantastic at pulling tweets but needs some work on `search_30days` function

