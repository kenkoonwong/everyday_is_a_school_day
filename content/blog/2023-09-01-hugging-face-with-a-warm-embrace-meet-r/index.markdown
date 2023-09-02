---
title: "Hugging Face \U0001F917, with a warm embrace, meet R️ ❤️ "
author: Ken Koon Wong
date: '2023-09-01'
slug: huggingface
categories: 
- r
- R
- hugging face
- bert
- finbert
- transformers
- reticulate
tags: 
- r
- R
- hugging face
- bert
- finbert
- transformers
- reticulate
excerpt: I'm delighted that R users can have access to the incredible Hugging Face pre-trained models. In this demonstration, we provide a straightforward example of how to utilize them for sentiment analysis using GPT-generated synthetic data from evaluation comments. Let's go!
---

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core/js/jquery.dataTables.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core/js/jquery.dataTables.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core/js/jquery.dataTables.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core/js/jquery.dataTables.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core/js/jquery.dataTables.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>

> I’m delighted that R users can have access to the incredible Hugging Face pre-trained models. In this demonstration, we provide a straightforward example of how to utilize them for sentiment analysis using GPT-generated synthetic data from evaluation comments. Let’s go!

## Interesting Problem 😎

What if you’re faced with a list of survey comments that you need to sift through? Apart from reading them one by one, is there a method that could potentially introduce a new perspective and expedite this process? Are there any models available for performing sentiment analysis?

## Objectives:

- [Brief Intro to Transfomers Python Module & Hugging Face](#brief-intro-to-transfomers-python-module-hugging-face)
- [Installing Transformers and Loading Module](#installing-transformers-and-loading-module)
- [Load Reuter Dataset](#load-reuter-dataset)
- [Load Pre-trained Model & Predict](#load-pre-trained-model-predict)
  - BERT vs FinBERT
- [Predict GPT4 generated comments 🤖](#predict-gpt4-generated-comments-)
- [Acknowledgement](#acknowledgement)
- [Lessons learnt](#lessons-learnt)

## Brief Intro to Transfomers Python Module & Hugging Face

#### `Transformers`

<p align="center">
<img src="transformers.jpg" alt="image" width="50%" height="auto">
</p>

In comes `Transformers`, which provides APIs and tools to easily download and train state-of-the-art pretrained models. Using pretrained models can reduce your compute costs, carbon footprint, and save you the time and resources required to train a model from scratch. These models support common tasks in different modalities, such as: NLP, computer vision, audio, and multimodal. `Transformers` support framework interoperability between PyTorch, TensorFlow, and JAX. Pretty cool, right!? But wait, this is a python 🐍 API! No fear, as before, we’ve demonstrated how `R` is able to use `python` modules with ease. Let’s code!

<p align="center">
<img src="feature.png" alt="image" width="50%" height="auto">
</p>

#### About Hugging Face 🤗

[Hugging Face](https://huggingface.co/) is a technology company specializing in natural language processing (NLP) and machine learning, best known for its [Transformers](https://huggingface.co/docs/transformers/index) library, an open-source collection of pre-trained models and tools that simplify the use of advanced NLP techniques. Established in 2016, the company has become a significant contributor to the field of AI, democratizing access to state-of-the-art models like BERT, GPT-2, and many others. Their platform allows developers, researchers, and businesses to easily implement complex NLP tasks such as sentiment analysis, text summarization, and machine translation. With a robust community of users contributing to its ecosystem, Hugging Face has become a go-to resource for those looking to harness the power of machine learning for language-based tasks.

## Installing Transformers and Loading Module

``` r
library(reticulate)
library(tidyverse)
library(DT)

# install transformers
# py_install("transformers", pip = T) # remember to uncomment and do this first

# load transformers module 
transformer <- import("transformers")
autotoken <- transformer$AutoTokenizer
autoModelClass <- transformer$AutoModelForSequenceClassification
```

The above code when loading `transformers` resemble the below in `python`

``` python
from transformers import AutoTokenizer, AutoModelForSequenceClassification
```

## Load Reuter Dataset

``` r
# load data
df <- read_csv("reuters_headlines2.csv") |>
  head(10)

# extract the headlines section
df_list <- df |>
  pull(Headlines)
```

## Load Pre-trained Model & Predict

![](hf_trend.png)
When you go to Hugging Face Model section, click on text classification and then sort by most likes. The above is a snapshot of that. Through wisdom of crowd, I think the top liked pre-trained models might be good ones to try out! Let’s give them a try!

#### Load model

``` r
tokenizer <- autotoken$from_pretrained("distilbert-base-uncased-finetuned-sst-2-english")
model <- autoModelClass$from_pretrained("distilbert-base-uncased-finetuned-sst-2-english")
```

#### Let’s look at what the model predicts

``` r
model$config$id2label
```

    ## $`0`
    ## [1] "NEGATIVE"
    ## 
    ## $`1`
    ## [1] "POSITIVE"

Ahh, ok. For `distilbert-base-uncased-finetuned-sst-2-english`, the output would be `negative` which is `0` or `positive` which is `1`.

#### Let’s feed our data onto `tokinzer` and see what is in it?

``` r
inputs <- tokenizer(df_list, padding=TRUE, truncation=TRUE, return_tensors='pt') # pt stands for pytorch

inputs$data
```

    ## $input_ids
    ## tensor([[  101,  3956,  2000,  2224,  3424,  1011,  7404,  6627,  2000,  4675,
    ##          21887, 23350,  1005,  8841,  4099,  1005,   102,     0,     0],
    ##         [  101,  1057,  1012,  1055,  1012,  4259,  2457,  2000,  3319,  9531,
    ##           1997, 14316,  3860,  4277,   102,     0,     0,     0,     0],
    ##         [  101, 24547, 28637,  3619,  2000,  2485,  2055,  3263,  5324,  1999,
    ##           2142,  2163,   102,     0,     0,     0,     0,     0,     0],
    ##         [  101,  2762,  1005,  1055,  2482,  3422, 16168,  4520, 20075, 29227,
    ##           2000,  6366,  6206,  7937,  4007,  1024,  3189,   102,     0],
    ##         [  101,  2859,  2758,  1057,  1012,  1055,  1012,  2323,  2425,  7608,
    ##           2000,  2689, 11744,  1999,  6629,  5216,   102,     0,     0],
    ##         [  101, 21396,  6290,  4152,  2117,  6105,  4895, 23467,  2075,  7045,
    ##           7708,  2011,  1057,  1012,  1055,  1012, 17147,   102,     0],
    ##         [  101, 10321, 20202,  1999,  2148,  3792,  2000,  3789,  2006,  2586,
    ##           3989,  1024,  1059,  2015,  3501,   102,     0,     0,     0],
    ##         [  101,  3119,  1011,  7591, 15768,  2006, 14607,  2004, 12503, 21094,
    ##            102,     0,     0,     0,     0,     0,     0,     0,     0],
    ##         [  101,  4717,  2884,  4487,  3736,  9397, 25785,  2015,  2007,  2117,
    ##           1011,  4284,  3463,  1010, 17472,  3105,  7659,   102,     0],
    ##         [  101,  2317,  2160,  1005,  1055, 23524,  2758,  1005,  2093,  9326,
    ##           2017,  1005,  2128,  2041,  1005,  2005,  1062,  2618,   102]])
    ## 
    ## $attention_mask
    ## tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    ##         [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]])

Interesting! `input_ids` are the numerical representations of the tokens in your input sequence(s). The first value 101 is the special token \[CLS\], which is often used as a sequence classifier in models like BERT. `attention_mask` tensor indicates which positions in the input sequence should be attended to and which should not (usually padding positions). A `1` means the position should be used in the attention mechanism, while a `0` usually signifies padding or another value to be ignored.

Now let’s dive into the tokenization of the data

``` r
df_list[1:5]

input$data[[1]][0:4] # notice that python begins with 0
```

![](df_input.png)
Above is a snapshot of my console that showed the actual words and the tokens. It looks like token `2000` is `to`. Note that the tokens begin with `101` and end with `102`.

In transformer models like BERT, certain special tokens are often used to help the model understand the task it should perform. These special tokens are represented by special IDs. The 101 and 102 tokens are such special tokens, and they have particular meanings:

`101` represents the `[CLS] (classification)` token. This is usually the first token in a sequence and is used for classification tasks. For tasks like sequence classification, the hidden state corresponding to this token is used as the aggregate sequence representation for classification.

`102` represents the `[SEP] (separator)` token. This token is used to separate different segments in a sequence. For instance, if you’re inputting two sentences into BERT for a task like question-answering or natural language inference, the \[SEP\] token helps the model distinguish between the two sentences.

As practice, what tokens are `U.S.`? Hover [here](## "U is 1057, . is 1012, S is 1055 , . is 1012") for answer.

#### Let’s Check The Prediction

``` r
## reticulate does not have ** function to pass the params
outputs <- model(inputs$input_ids, attention_mask=inputs$attention_mask)

outputs
```

    ## $logits
    ## tensor([[ 2.1572, -1.8241],
    ##         [-1.6254,  1.5929],
    ##         [ 1.3497, -1.1460],
    ##         [ 3.3878, -2.8804],
    ##         [ 3.8068, -3.1309],
    ##         [ 2.1719, -1.8269],
    ##         [ 1.6600, -1.5161],
    ##         [ 2.0822, -1.8792],
    ##         [ 4.2344, -3.4873],
    ##         [ 1.8456, -1.4874]], grad_fn=<AddmmBackward0>)

Ahh, these are in `logits`. Also, noted that we cannot do `model(**inputs)` like in python, we’d have to pass in individual parameters.

#### Load `torch` and change to probability

``` r
torch <- import("torch")
predictions <- torch$nn$functional$softmax(outputs$logits, dim=1L)

predictions
```

    ## tensor([[9.8168e-01, 1.8320e-02],
    ##         [3.8484e-02, 9.6152e-01],
    ##         [9.2384e-01, 7.6159e-02],
    ##         [9.9811e-01, 1.8920e-03],
    ##         [9.9903e-01, 9.6959e-04],
    ##         [9.8199e-01, 1.8008e-02],
    ##         [9.5992e-01, 4.0076e-02],
    ##         [9.8132e-01, 1.8679e-02],
    ##         [9.9956e-01, 4.4292e-04],
    ##         [9.6555e-01, 3.4454e-02]], grad_fn=<SoftmaxBackward0>)

Yes! There’re in probabilities now. But how do we turn these tensors into `tibble` ?

``` r
# turn tensor to list
pred_table <- predictions$tolist()

# map list into dataframe
table <- map_dfr(pred_table, ~ tibble(positive = .[2], negative = .[1]))

datatable(table)
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-1" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10"],[0.0183197911828756,0.961516141891479,0.0761592611670494,0.00189198448788375,0.000969592190813273,0.0180078409612179,0.0400755144655704,0.0186794977635145,0.000442916440078989,0.0344544686377048],[0.981680274009705,0.0384838953614235,0.923840761184692,0.99810802936554,0.999030470848083,0.981992125511169,0.959924459457397,0.981320440769196,0.999557077884674,0.965545475482941]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>positive<\/th>\n      <th>negative<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>

Awesome! Looks like at least the coding worked. Let’s combine the comments and the scores to check.

``` r
df |>
  head(10) |>
  select(Headlines) |>
  add_column(table) |>
  datatable()
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-2" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10"],["Israel to use anti-terror tech to counter coronavirus 'invisible enemy'","U.S. Supreme Court to review scope of investor protection laws","Walgreens to close about 200 stores in United States","Germany's car watchdog sets Audi ultimatum to remove illegal diesel software: report","China says U.S. should tell airlines to change websites in Taiwan row","Sulzer gets second license unblocking assets frozen by U.S. sanctions","Boeing technicians in South Carolina to vote on unionization: WSJ","Trade-sensitive stocks on ropes as uncertainty weighs","Mattel disappoints with second-quarter results, announces job cuts","White House's Navarro says 'three strikes you're out' for ZTE"],[0.0183197911828756,0.961516141891479,0.0761592611670494,0.00189198448788375,0.000969592190813273,0.0180078409612179,0.0400755144655704,0.0186794977635145,0.000442916440078989,0.0344544686377048],[0.981680274009705,0.0384838953614235,0.923840761184692,0.99810802936554,0.999030470848083,0.981992125511169,0.959924459457397,0.981320440769196,0.999557077884674,0.965545475482941]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>Headlines<\/th>\n      <th>positive<\/th>\n      <th>negative<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>

wow, most news are quite negative. 🤣 Not sure if `distilbert-base-uncased-finetuned-sst-2-english` is the best pre-trained model for these data.

#### Let’s check out `ProsusAI/finbert`

``` r
tokenizer <- autotoken$from_pretrained("ProsusAI/finbert")
model <- autoModelClass$from_pretrained("ProsusAI/finbert")
inputs <- tokenizer(df_list, padding=TRUE, truncation=TRUE, return_tensors='pt')
outputs <- model(inputs$input_ids, attention_mask=inputs$attention_mask)
predictions <- torch$nn$functional$softmax(outputs$logits, dim=1L)
pred_table <- predictions$tolist()
table <- map_dfr(pred_table, ~ tibble(positive = .[1], negative = .[2], neutral = .[3]))

df |>
  select(Headlines) |>
  add_column(table) |>
  datatable()
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-3" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10"],["Israel to use anti-terror tech to counter coronavirus 'invisible enemy'","U.S. Supreme Court to review scope of investor protection laws","Walgreens to close about 200 stores in United States","Germany's car watchdog sets Audi ultimatum to remove illegal diesel software: report","China says U.S. should tell airlines to change websites in Taiwan row","Sulzer gets second license unblocking assets frozen by U.S. sanctions","Boeing technicians in South Carolina to vote on unionization: WSJ","Trade-sensitive stocks on ropes as uncertainty weighs","Mattel disappoints with second-quarter results, announces job cuts","White House's Navarro says 'three strikes you're out' for ZTE"],[0.183859378099442,0.0340717695653439,0.0255753565579653,0.0202136300504208,0.0427913889288902,0.450336873531342,0.0409622043371201,0.0479289814829826,0.00827102083712816,0.162613943219185],[0.0159921813756227,0.0841075852513313,0.71194314956665,0.463679313659668,0.220349356532097,0.0185313206166029,0.357321619987488,0.858825743198395,0.965990364551544,0.112648434937],[0.800148487091064,0.881820619106293,0.262481451034546,0.516107141971588,0.736859261989594,0.53113180398941,0.601716220378876,0.0932452529668808,0.0257386285811663,0.724737644195557]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>Headlines<\/th>\n      <th>positive<\/th>\n      <th>negative<\/th>\n      <th>neutral<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>

I like the additional option of `neutral`. This might actually be very helpful for our actual problem in evaluation comments.

## Predict GPT4 generated comments 🤖

#### First, Generate Data

![](gpt.png)

#### Second, Use `finBERT` for Sentiment Analysis

``` r
eval_df <- read_csv("eval_comment.csv") |> 
  pull(comment)

inputs <- tokenizer(eval_df, padding=TRUE, truncation=TRUE, return_tensors='pt')
outputs <- model(inputs$input_ids, attention_mask=inputs$attention_mask)
predictions <- torch$nn$functional$softmax(outputs$logits, dim=1L)
pred_table <- predictions$tolist()
table <- map_dfr(pred_table, ~ tibble(positive = .[1], negative = .[2], neutral = .[3]))

df_final <- tibble(comment = eval_df) |>
  add_column(table) |>
  select(-negative) |>
  mutate(positive = positive + neutral) |>
  select(-neutral)

datatable(df_final)
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-4" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40"],["This employee consistently meets deadlines and always delivers high-quality work.","The employee often comes in late and seems disengaged during team meetings.","She is an excellent communicator and facilitates team discussions well.","He rarely contributes to brainstorming sessions and seems uninterested in collective goals.","She has been instrumental in completing the project on time.","Lacks the initiative to independently solve problems, often waiting for instructions.","This employee is a natural leader and always takes responsibility for his tasks.","He tends to miss deadlines and disregards the quality of his deliverables.","She consistently goes above and beyond, even completing tasks that are not her responsibility.","He struggles with effective communication, often leaving team members confused.","Always punctual and shows high dedication towards her work.","This employee's lack of organizational skills has negatively impacted the team's performance.","She has strong technical skills that have greatly benefited the team.","He often speaks over others in meetings and disregards their ideas.","This employee is highly skilled and a great asset to the team.","He is resistant to adopting new methodologies and technologies.","She is proactive in identifying and solving problems.","Fails to maintain a positive work attitude and impacts team morale.","He has the ability to simplify complex problems and find effective solutions.","This employee tends to gossip, creating a toxic environment.","She shows a high level of commitment and follows through on her tasks.","His work is often filled with errors that require correction.","This employee is a fantastic mentor and helps junior staff grow.","He takes criticism poorly and is unresponsive to feedback.","She consistently contributes innovative ideas during team meetings.","He frequently distracts others, impacting productivity.","This employee has significantly improved in the past year.","She does not adhere to company policies and procedures.","He is excellent in managing his time and resources.","The employee has been late in submitting monthly reports repeatedly.","She effectively balances individual tasks with group responsibilities.","He tends to rush through his tasks, compromising on quality.","This employee exhibits strong problem-solving skills and a can-do attitude.","Fails to keep up with set targets and responsibilities.","She has a pleasant personality and gets along well with colleagues.","This employee is often absent, affecting the workflow of the team.","He is diligent and meticulous, paying attention to every detail.","She ignores constructive criticism and is resistant to change.","This employee has a high level of technical expertise that has boosted our productivity.","He lacks the ability to effectively manage stress, impacting his work quality."],[0.979647427797318,0.211425594054163,0.989689916372299,0.553054120391607,0.988595381379128,0.48320303671062,0.983169794082642,0.546161592006683,0.956617742776871,0.257375363260508,0.980079166591167,0.0348524637520313,0.989589489996433,0.400606855750084,0.988072454929352,0.9213907122612,0.986681133508682,0.0402136016637087,0.988790392875671,0.143399827182293,0.987338244915009,0.416887853294611,0.989213764667511,0.317372597754002,0.988875702023506,0.0616473099216819,0.985007768496871,0.709061464294791,0.988208100199699,0.102424623444676,0.97433964908123,0.227521287277341,0.986971527338028,0.120847786776721,0.982507735490799,0.0707869594916701,0.974687516689301,0.552506092935801,0.990622006356716,0.0550779569894075]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>comment<\/th>\n      <th>positive<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":2},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>

Wow, not bad! If we put a threshold of `0.9` or more to screen out negative comments we might do pretty good!

#### Third, `datatable` with `backgroundColor` conditions for Aesthetics 📊

``` r
datatable(df_final, options = list(columnDefs = list(list(visible = FALSE, targets = 2)))) |>
  formatStyle(columns = "comment",
              backgroundColor = styleInterval(cuts =
                c(0.5, 0.95), values =
                c('#FF000033', '#FFA50033', '#0000FF33')
              ),
                valueColumns = "positive")
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-5" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-5">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40"],["This employee consistently meets deadlines and always delivers high-quality work.","The employee often comes in late and seems disengaged during team meetings.","She is an excellent communicator and facilitates team discussions well.","He rarely contributes to brainstorming sessions and seems uninterested in collective goals.","She has been instrumental in completing the project on time.","Lacks the initiative to independently solve problems, often waiting for instructions.","This employee is a natural leader and always takes responsibility for his tasks.","He tends to miss deadlines and disregards the quality of his deliverables.","She consistently goes above and beyond, even completing tasks that are not her responsibility.","He struggles with effective communication, often leaving team members confused.","Always punctual and shows high dedication towards her work.","This employee's lack of organizational skills has negatively impacted the team's performance.","She has strong technical skills that have greatly benefited the team.","He often speaks over others in meetings and disregards their ideas.","This employee is highly skilled and a great asset to the team.","He is resistant to adopting new methodologies and technologies.","She is proactive in identifying and solving problems.","Fails to maintain a positive work attitude and impacts team morale.","He has the ability to simplify complex problems and find effective solutions.","This employee tends to gossip, creating a toxic environment.","She shows a high level of commitment and follows through on her tasks.","His work is often filled with errors that require correction.","This employee is a fantastic mentor and helps junior staff grow.","He takes criticism poorly and is unresponsive to feedback.","She consistently contributes innovative ideas during team meetings.","He frequently distracts others, impacting productivity.","This employee has significantly improved in the past year.","She does not adhere to company policies and procedures.","He is excellent in managing his time and resources.","The employee has been late in submitting monthly reports repeatedly.","She effectively balances individual tasks with group responsibilities.","He tends to rush through his tasks, compromising on quality.","This employee exhibits strong problem-solving skills and a can-do attitude.","Fails to keep up with set targets and responsibilities.","She has a pleasant personality and gets along well with colleagues.","This employee is often absent, affecting the workflow of the team.","He is diligent and meticulous, paying attention to every detail.","She ignores constructive criticism and is resistant to change.","This employee has a high level of technical expertise that has boosted our productivity.","He lacks the ability to effectively manage stress, impacting his work quality."],[0.979647427797318,0.211425594054163,0.989689916372299,0.553054120391607,0.988595381379128,0.48320303671062,0.983169794082642,0.546161592006683,0.956617742776871,0.257375363260508,0.980079166591167,0.0348524637520313,0.989589489996433,0.400606855750084,0.988072454929352,0.9213907122612,0.986681133508682,0.0402136016637087,0.988790392875671,0.143399827182293,0.987338244915009,0.416887853294611,0.989213764667511,0.317372597754002,0.988875702023506,0.0616473099216819,0.985007768496871,0.709061464294791,0.988208100199699,0.102424623444676,0.97433964908123,0.227521287277341,0.986971527338028,0.120847786776721,0.982507735490799,0.0707869594916701,0.974687516689301,0.552506092935801,0.990622006356716,0.0550779569894075]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>comment<\/th>\n      <th>positive<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"visible":false,"targets":2},{"className":"dt-right","targets":2},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\nvar value=data[2]; $(this.api().cell(row, 1).node()).css({'background-color':isNaN(parseFloat(value)) ? '' : value <= 0.5 ? \"#FF000033\" : value <= 0.95 ? \"#FFA50033\" : \"#0000FF33\"});\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

Notice that I had to set a threshold of `0.95` to ensure all negative comments are captured. Meaning, only comments with sentiment of more than `0.95` will have blue background. If anything between `0.5` and `0.95` it would be yellow. Anything less than `0.5` will be red.

<p align="center">
<img src="yes.jpg" alt="image" width="50%" height="auto">
</p>

We’re done !!! Now we know how to access `Hugging Face` pre-trained model through `transformers`! This opens up another realm of awesomeness!

## Acknowledgement

- This [Colab](https://colab.research.google.com/drive/1jEHhU5_x4oQkelW3p__fY2y0m3-z7Y5P?usp=sharing) link really had helped me to modify some of the codes to make it work in `R`
- Thanks to my brother Ken S’ng, who inspired me to explore hugging face with his previous python script
- Thanks to chatGPT for generating synthetic evaluation data!
- Of course, last but not least, the wonderful open-source community of Hugging Face! 🤗

## Lessons learnt

- Markdown hover text can be achieved through `[](## "")`
- Changing alpha of hex code can be achieved through chatGPT prompt.
- There are tons of great pre-trained models in Hugging Face, can’t wait to explore further!

<br>
<br>

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
