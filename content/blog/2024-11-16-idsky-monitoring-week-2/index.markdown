---
title: "#IDSky \U0001F98B Week 2 - How Does It Look?"
author: Ken Koon Wong
date: '2024-11-16'
slug: bluesky2
categories: 
- idtwitter
- idxpost
- idxposts
- idmastodon
- idsky
- infectious disease
tags: 
- idtwitter
- idxpost
- idxposts
- idmastodon
- idsky
- infectious disease
excerpt: "How's #IDSky doing on week 2? Pretty great! We're seeing steady posts worldwide, strong US-UK participation, and even outpacing Twitter metrics. The ID community isn't just dropping by - they're making BlueSky their new digital home."
---

> How's #IDSky doing on week 2? Pretty great! We're seeing steady posts worldwide, strong US-UK participation, and even outpacing Twitter metrics. The ID community isn't just dropping by - they're making BlueSky their new digital home.

## Week 2 Of #IDSky, How Does It Look?
![](monitor.png)



Last data queried was `11/16/24 21:05 EST`. From the plot, it seems like we're still going strong! Since `11/9/24` #IDSky daily posts were maintaed at median 138 (+/-19.7). It looked like `11/15/24` was the most of the week at 164. Don't mind the `11/17/24` since the timezone on the data was set at `UTC`, it's not a complete data.

#### #IDSky Posts Frequency
<p align="center">
  <img src="bluesky.png" alt="image" width="40%" height="auto">
</p> 

Since I had some API access on X/Twitter left (will be expiring soon), I was able to take a look at what #IDTwitter/IDxPosts post numbers were. Here it is.     

#### #IDTwitter/IDxPosts Posts Frequency
<p align="center">
  <img src="twitter.png" alt="image" width="50%" height="auto">
</p> 

If there are just a bunch of numbers, they are. Basically these are total posts with #IDTwitter/IDxposts on the text. What do you think? Which is higher? #IDSky !!! 

What were the conditions of query for these posts? We included retweets/reposts. So both were compared on a level playing field. But I just realized this... 

RT on twitter will include all the texts of the original tweet... Repost/Quote on bluesky doesn't, unless if the author tags idsky again. That means, the #idtwitter #idxposts counts are inflated compared to the #idsky counts on bluesky. 

For example:
`Twitter:` if this post `(#idtwitter look at this article...)` were retweeted twice, the counter will pick up `(RT: #idtwitter look at this article...)` 2 more times, making it 3 total.

`Bluesky`: if this post `(#idsky look at this article...)` were reposted twice without any tags, the counter won't pick up the reposts, making it 1 total.

Which means... #IDsky could have a higher posting frequency than it looks! 


## Is #IDSky A Global Thing? Yes! 🙌
![](plot.png)

Don't mind the color palette, or the lack of. Anything in white and without the country's names means there were no post from author from that country. If there is 1 or more there will be color, which starts from `pink`, `blue`, `purple`, `green`. The legend on right shows the numbers of posts from the country. 

Wow, this is very international! I purposefully have `green` to be the color of highest frequency to highlight the high posts between `USA` and `UK`. 


![](idsky_barplot.png)

Here is a bar plot of the top 10 countries sorted by the highest post counts. Not too surprised about `USA`, but it's nice to see the `USA-UK` relationship is quite strong! Keep up the great bond! I don't think this is just UK, I do believe if I were to lump the `European` countries, we'll see a strong `US-Europe` relationship too! Not to mention `Canada` and `Australia` too! 

There were about 38 missing data of the country where the author's from. There is some limitation of the method I used. Since BlueSky does not include location information like Twitter did (though these are also self-inputted), I had to resort to LLM-assisted country allocation. Since there were descriptions listed by the authors, I first use GPT4-mini to interpret the description and see if it can give me a country, if it cannot, it will automatically resort to search engine result page (SERP) API and then it will plug in the top 5 searches of the display name and description, and see if it was able to allocate a country. I will create another blog post on the details of the code if technical people are interested. I have still yet to audit this, but the USA, Canada and UK data should be quite accurate, the data on others I need to audit.

## So, What Do You Think?
Well, the momentum initially was great, but to be transparent, I was concerned about the frequency of #IDsky posts initially were mainly from greetings, welcome, and introduction as people joined. However, after this week, I'm confident that the #IDSky community is here to stay! We are seeing more ID related contents, more discussions as people are comfortable with the user experience, more connectivity and visibility. 

## What's Next?
We will continue to monitor the posts frequency for another 3 weeks (including this week), if the counts are the same or higher, I think we know the answer. 🦋❤️ 

<br>





If you like this article:
  - please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
