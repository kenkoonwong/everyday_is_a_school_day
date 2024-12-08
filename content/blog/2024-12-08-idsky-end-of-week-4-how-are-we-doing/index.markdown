---
title: "#IDSky \U0001F98B Our Network 🕸️"
author: Ken Koon Wong
date: '2024-12-08'
slug: bluesky5
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
excerpt: "Wow, that was a fun project! 🦋 Post numbers have been high and stable. Engagement has also been great as well. It's an intentional and international effort. There are branches of other ID relevant tags with stable post frequencies as well. I think #IDSky is here to stay. What do you think?"
---
<script src="{{< blogdown/postref >}}index_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index_files/lightable/lightable.css" rel="stylesheet" />

> Wow, that was a fun project! 🦋 Post numbers have been high and stable. Engagement has also been great as well. It's an intentional and international effort. There are branches of other ID relevant tags with stable post frequencies as well. I think #IDSky is here to stay. What do you think?

![](network.png)

We're coming to an end of our #IDSky monitoring (end of week 4). It has been a fun and educational journey! Thanks for all the support, feedback, and pointers to making this insightful. Let's take a look at this in a few parts

<br>

## Objectives:
- [How Are We Doing?](#global)
- [Global Effort](#international)
- [Revelant Non-#IDSky Tags](#others)
- [Our Network](#network)
- [My Conclusion](#fin)
- [Acknowledgement/Lessons Learnt](#lessons)

## How Are We Doing? {#global}
<p align="center">
  <img src="all.png" alt="image" width="100%" height="auto">
</p>

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> week </th>
   <th style="text-align:right;"> median </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> min </th>
   <th style="text-align:right;"> lower25 </th>
   <th style="text-align:right;"> upper75 </th>
   <th style="text-align:right;"> max </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:right;"> 138 </td>
   <td style="text-align:right;"> 19.35139 </td>
   <td style="text-align:right;"> 116 </td>
   <td style="text-align:right;"> 137.0 </td>
   <td style="text-align:right;"> 160.5 </td>
   <td style="text-align:right;"> 172 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:right;"> 134 </td>
   <td style="text-align:right;"> 37.57976 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 101.5 </td>
   <td style="text-align:right;"> 151.0 </td>
   <td style="text-align:right;"> 200 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 136 </td>
   <td style="text-align:right;"> 39.79112 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 127.0 </td>
   <td style="text-align:right;"> 168.0 </td>
   <td style="text-align:right;"> 206 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 49 </td>
   <td style="text-align:right;"> 124 </td>
   <td style="text-align:right;"> 21.64651 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 104.0 </td>
   <td style="text-align:right;"> 130.0 </td>
   <td style="text-align:right;"> 139 </td>
  </tr>
</tbody>
</table>

How did we do? The past 4 weeks since the exodus, our #IDsky posts have been stable. With a median of 124 posts last week, still above 100, which is comforting. I think with this, coupled with the interaction of the posts we've observed, and also altmetric data of a few selected articles, I would be comfortable to say that the post frequency will continue to be stable. I can stop monitoring this now 🙌

<br>

## Global Effort 🌏 {#international}
<p align="center">
  <img src="idskyplot.png" alt="image" width="100%" height="auto">
</p>

<p align="center">
  <img src="idsky_barplot.png" alt="image" width="100%" height="auto">
</p>

Updating our international monitoring effort. Wow, it truly is an international effort! Thanks to all who have contributed to #IDSky! Please take note that we used agentic-assisted LLM to extract the country origin of users. I would say it is quite inaccurate in some where I had to manually change the country of users after confirming their locations. But the ones with high posts, those should be fairly accurate. Please let me know if they look funny, and I can always re-run the visualization.

<br>

## Revelant Non-#IDSky Tags {#others}
<p align="center">
  <img src="otheridsky_plot.png" alt="image" width="100%" height="auto">
</p>

Thanks to Jose who recommended us to monitor other non-IDsky tags, we are seeing posts that are not tagged with #IDsky and yet ID-relevant posts. Still looking stable! Definitely changed my way of finding relevant posts through feed generators! 

The first row are posts with the tag #IDsky plus other tags labeled on column name. The second row are posts without the tag #IDsky. They're very similar in frequency. Definitely do not rely solely on #IDsky if you're interested in other topics. 

Also please note that, these are not the only ID-relevant tags, there are #Liversky, #hepatitissky etc. Go explore! 

<br>

## Our Network {#network}
![](bluesky_network_full.gif)
Last but not least, our community network! How was this done? From the #IDSky monitoring, we extracted all the authors and then query their followers and also authors they are following, then merge all of them up and visuazlize via `threejs` a package by `Bryan Lewis` who is part of our Cleveland R User Group! #IDSky community network has 219999 vertices (nodes) and 1591044 edges (relationships). Please pay no special attention to the colors, they are only for aesthetics. Limitation, there were ~1-5% error rate while acquiring data. I tried my best to parse of the error and refill them with re-query. That said, wow, our #IDSky community network looks REALLY Cool!

<br>

## My Conclusion {#fin}
Wow, that was a fun project! 🦋 Post numbers have been high and stable. Engagement has also been great as well. It's an intentional and international effort. There are branches of other ID relevant tags with stable post frequencies as well. I think #IDSky is here to stay. What do you think?

<br>

## Acknowledgement/Lessons Learnt {#lessons}
- Found `ggsflabel` that has the repel function, learnt to set `max.overlap` in order to show labels that were hidden.
- Defensive programming, wow! Getting large data such as this is no easy feat. Days and days of debugging, alas, I felt I was able to write a code that is adaptable and yet flexible. Used `tryCatch` a lot lol.
- Learnt to visualize network graph with `threejs` package maintained by Bryan Lewis, from our very own Cleveland R User Community! Thanks to Alec Wong for the recommendation!
- Last but not least, the person who benefited the most for doing this was me! Thanks to #IDSky community for the influx of great ID news, articles, commentary, and discussion! Keep up the soild effort!

<br>

If you like this article:
  - please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)

