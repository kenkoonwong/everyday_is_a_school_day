---
title: 'My Reflection On ESICM Dathon 2023'
author: Ken Koon Wong
date: '2023-07-16'
slug: datathon23
categories: 
- datathon
- dowhy
- reticulate
- causality
- esicm
- rython
- econnml
- dataviz

tags: 
- datathon
- dowhy
- reticulate
- causality
- esicm
- rython
- econml
- dataviz

excerpt: I have learned a tremendous amount from everyone involved, including members from other teams. The entire experience has been truly enriching, and I thoroughly enjoyed every moment of it. I want to express my heartfelt gratitude to everyone involved for making this an exceptional learning journey. Thank you all!
---

>  I have learned a tremendous amount from everyone involved, including members from other teams. The entire experience has been truly enriching, and I thoroughly enjoyed every moment of it. I want to express my heartfelt gratitude to everyone involved for making this an exceptional learning journey. Thank you all!

<br>

[![](tweet.png)](https://twitter.com/anirbanb_007/status/1669867988323823616)

## Critical care? What's that got to do with you?
True, while my specialty—or should I say, lifelong learning interest—is Infectious Disease, I wouldn't go as far as calling myself an expert. However, there's another passion that has been driving my eagerness to learn: Data Science. Infectious Disease (ID) and Data Science share striking similarities. They both revolve around meta-learning, applying structured learning frameworks to gain knowledge in any desired subject.

So, here's the exciting part: this meta-learning approach can be applied to critical care too! Now, I must admit, my experience with ventilator settings is abysmal at best. But having incredible friends and fantastic intensivists like Anirban and Ping has motivated me to dive into the world of Critical Care Datathons. And let me tell you, it's not just educational—it's also a whole lot of fun! But seriously, where are all the ID datathons or hackathons? I'm still waiting, my fellow enthusiasts! Perhaps it's time for me to reach out to the Infectious Diseases Society of America (IDSA) and make it happen.

In a nutshell, while my expertise lies in Infectious Disease, the intriguing connection to critical care cannot be ignored. By embracing the principles of Data Science and meta-learning, I'm venturing into uncharted territory, spurred on by the support of amazing colleagues and my thirst for new challenges. Stay tuned, folks, as we explore the possibilities and push the boundaries of medical knowledge together!

## What do you think went well? 
### Rython + Collaborative spirit
This datathon provided a remarkable opportunity for me to learn and apply data science skills, utilizing both R and Python to our advantage. In my opinion, what truly stood out was the collaborative nature of our team. The synchronization of our thought processes and our shared commitment to exploring causality through "The Book of Why" were instrumental. It motivated us to adopt a comprehensive methodology and delve into the do-operator concept, along with leveraging the invaluable dowhy package that Ping discovered. Ultimately, these efforts greatly facilitated our exploration of the intricate relationships among the nodes.

### We're DAGging it
Additionally, the time and discussions invested in DAG construction were truly commendable. We have transcended superficial arguments and now engage in debates at a structural level, where every suggestion contributes to the reconstruction of the DAG. This collaborative effort proves instrumental in facilitating causal discovery and advancing our understanding.

### Stick to your role
One notable aspect that worked exceptionally well this time was our adherence to the leader's suggestions. With one person taking the lead, others followed suit and made valuable contributions. Whenever a clear path wasn't apparent, we spoke up to seek clarification and address any ambiguities. A prime example of this occurred during the final stages when I struggled to grasp Anirban's concept of hourly assessment of mechanical power. Through in-depth discussions, we were able to overcome this challenge and ultimately create a remarkable work of art called the [ATE-Targeted Mechanical Power Threshold Simulation](https://kenkoonwong.shinyapps.io/team4_vanguard_mp_sim/)

### Pretty plots & Shine with Shiny !
Using [theme_black](https://gist.github.com/jslefche/eff85ef06b4705e6efbc) really added some finesse to the plots. Gave the mechanical power a little omph! 

Faceted MP of different cohorts
![](ate_facet.png)

Shiny app on ATE-targeted MP threshold simulation:
[![](ate.png)](https://kenkoonwong.shinyapps.io/team4_vanguard_mp_sim/)

### Don't be afraid to reach out to the gurus! 
I decided to reach out to Judea Pearl to seek some clarifications, inspired by his groundbreaking work in "The Book of Why." Despite being uncertain whether he would respond, I figured I had nothing to lose. Much to my surprise, this revered figure in the field not only replied but took the time to address even my simplest question. I am in awe and offer my utmost respect and admiration to him.

#### DAG Transparency
I wholeheartedly support the practice of including DAG (Directed Acyclic Graph) submissions in all research endeavors. By doing so, both reviewers and readers gain insight into the underlying structure of causal inference. This transparency facilitates constructive refutation and debate, which I refer to as engaging at a structural level. At this level, arguments can revolve around the necessity of adjustment for unobserved confounders or the presence of adjusted colliders that affect the connectivity of the graph.
![](judea_tweet.png)

#### Noob question on do-Operator and continuous variable
![](judea_tweet2.png)
It is truly a delight that esteemed figures like Judea Pearl in the field of Causal Inference would take the time to respond to even the simplest of questions and offer guidance. This experience has given me a fresh perspective on how I should respond and interact with the next generation who reach out to me. I am inspired to embrace them with open arms, warmth, and a willingness to share knowledge and insights.


## What do you think can be improved for the next Datathon?
### More understanding of Causality
These two books will be my assignments to complete before the year comes to a close.
- [Causal Inference in Statistics - A Primer](https://www.amazon.com/Causal-Inference-Statistics-Judea-Pearl/dp/1119186846/ref=sr_1_1?keywords=causal+inference+in+statistics+a+primer&qid=1689519922&sprefix=causal+inference+%2Caps%2C96&sr=8-1)
- [Causal Inference and Discovery in Python: Unlock the secrets of modern causal machine learning with DoWhy, EconML, PyTorch and more](https://www.amazon.com/Causal-Inference-Discovery-Python-learning/dp/1804612987/ref=sr_1_1?keywords=causal+inference+and+discovery+in+python&qid=1689519968&sprefix=causal+inference+and+disc%2Caps%2C101&sr=8-1)

### Data Cleaning Structure: Avoiding Duplication and Ensuring Consistency
In our data analysis endeavors, it is essential to strive for efficiency and consistency. Rather than duplicating efforts, we should focus on replicating work. Implementing a standardized data cleaning template will prove invaluable for all team members, as it ensures that everyone is working with the same set of cleaned and transformed databases. This approach eliminates the need for redundant cleaning processes and guarantees that the resulting datasets are consistent across the team. By establishing a streamlined data cleaning structure, we can optimize our workflow and enhance the reliability of our outcomes.

### Comfortable with Python + NN
This is primarily for my personal development. As someone who primarily works with R, Python serves as my second language. However, we frequently use Python within R through reticulate. To broaden my versatility, I believe it's crucial for me to become more proficient in Python for tasks like data cleaning and wrangling. After all, being bilingual in programming languages has its advantages.

### Taking DataViz to the Next Level!
To further enhance our data visualization skills, I am eager to delve into the intricacies of ggplot. I plan to reach out to the Discord community and seek recommendations for advanced ggplot2 books. By delving into the finer details, we can elevate our DataViz game and create even more compelling and insightful visual representations of data.

## Lessons Learned:
- Explored and gained proficiency in new packages such as dowhy, econML, and bnlearn, which effectively implement the do-operator in practice.
- Committed to delving deeper into the two aforementioned books for continued learning and growth.
- Recognized the significance of data visualization and storytelling, irrespective of the complexity of our analyses. Effectively translating our findings into a concise and compelling 2-minute elevator speech is crucial.
- Found immense enjoyment in collaborating with others and engaging in discussions surrounding data science methodologies and their practical applications. These experiences serve as a source of inspiration and replenishment for my passion in the field.


<br>

If you like this article:
  - please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
