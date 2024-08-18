---
title: Gemini 1.5 Flash Better Than RAG? Let's Check It Out In R!
author: Ken Koon Wong
date: '2024-08-17'
slug: gemini
categories: 
- r
- R
- gemini
- google
- llm
- llm_as_a_judge
- reticulate
- dotenv
- idsa
tags: 
- r
- R
- gemini
- google
- llm
- llm_as_a_judge
- reticulate
- dotenv
- idsa
excerpt: Overall, I am quite impressed with the responses! With minimal prompt engineering, document cleaning! It was able to return accurate responses, and even separated different conditions and provided appropriate treatment options. It was also able to return the correct response for tricky questions that our RAG was not able to. It definitely has potential! 
---

<link href="{{< blogdown/postref >}}index_files/htmltools-fill/fill.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core/js/jquery.dataTables.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>

> Overall, I am quite impressed with the responses! With minimal prompt engineering, document cleaning! It was able to return accurate responses, and even separated different conditions and provided appropriate treatment options. It was also able to return the correct response for tricky questions that our RAG was not able to. It definitely has potential!

![](feature.jpeg)

## Objectives

- [Gemini Flash 1.5 Replacing RAG?](#gemini-flash-15-replacing-rag)
- [Minimal Reproducible Code](#minimal-reproducible-code)
- [Response](#response)
- [LLM-as-a-judge](#llm-as-a-judge)
- [Limitations](#limitations)
- [Lessons learnt](#lessons-learnt)

## Gemini 1.5 Flash Replacing RAG?

Gemini 1.5 Flash is a powerful model designed for high-volume, low-latency AI tasks. It boasts a massive `1 million token context window`, enabling the processing of extensive data like lengthy documents, videos, or codebases. That also means that you can attach documents directly and not worry about RAG where we would generally use an embedding model and store it in vectorstore, and then have a retriever to search similarity using whichever parameter we set. But what is the catch? That’s sending a lot of tokens all at once! It can be quite expensive, isn’t it? Let’s take a look at price of the free version.

![](specs.png)

Here is the [link](https://ai.google.dev/pricing) in case they changed their pricing.

For our purpose, it seems like the FREE version would work just fine! It seems like there are limits, 15 requests per minute, 1 million tokens per minute and 1500 requests per day. That’s a lot of tokens!

But, is this really better than RAG? Let’s find out. If you want to check out our previous play with Llama 3, take a look at [this](https://www.kenkoonwong.com/blog/llm-rag/). We discussed how RAG works, you can look at the prior responses there. Here, we will use LLM-as-a-judge to assess the relevance, factual accuracy and succicntness of the reponse Gemini Flash 1.5 generated. How well do you think it’s going to perform?

Before you begin, [remember to get your Gemini API key](https://ai.google.dev/gemini-api/docs/api-key)

## Minimal Reproducible Code

``` r
library(tidyverse)
library(reticulate)

# Step 1: Create a virtual environment, if you've already created one please move on the step 2. This is a best practice. 
virtualenv_create(envname = "gemini")

## Step 1.1: Install the appropriate modules
py_install(c("google-generativeai","langchain","langchain-community","pypdf","python-dotenv"), pip = T, virtualenv = "gemini")

# Step 2: Use the virtual environment
use_virtualenv("gemini")

# Step 3: Import installed modules
dotenv <- import("dotenv")
genai <- import("google.generativeai")
langchain_community <- import("langchain_community")
PyPDFLoader <- langchain_community$document_loaders$PyPDFLoader
langchain <- import("langchain")
PromptTemplate <- langchain$prompts$PromptTemplate

# Step 4: Load your API keys onto a .env file - see https://pypi.org/project/python-dotenv/
dotenv$load_dotenv(dotenv_path = ".env")

# Step 5: Load PDF of interest
loader = PyPDFLoader("amr-guidance-4.0.pdf")
documents = loader$load()

# Step 6: Setup Gemini
genai$configure() #if you're skipping dotenv, insert your API key here

llm <- genai$GenerativeModel(
  'gemini-1.5-flash', 
  generation_config=genai$GenerationConfig(
  max_output_tokens=2000L,
  temperature=0
))

# Step 7 (optional): Test
llm$generate_content(contents = "hello") # you should see a return of text and tokens etc.

# Step 8: Prompt
prompt_text = "
You are a question and answer assistant. Given the context below, answer the question.

Context: {text}

Question: {question}    
"

prompt = PromptTemplate(template=prompt_text, input_variables=list("text", "question"))

questions = c(
  "What is the preferred treatment of CRE?",
  "What is the preferred treatment of ESBL-E?",
  "Can we use fosfomycin in ESBL Klebsiella?",
  "Can we use fosfomycin in ESBL Ecoli?",
  "What is the preferred treatment of stenotrophomonas?",
  "What is the preferred treatment of DTR Pseudomonas?",
  "Which organisms require two active agent when susceptibility is known?",
  "Can we use gentamicin in pseudomonas infection?",
  "Can we use tobramycin to treat pseudomonas infection?",
  "Why is there carbapenemase non-producing organism?",
  "Can we use oral antibiotics for any of these MDRO?",
  "What is the preferred treatment of MRSA?",
  "What is the preferred treatment of CRAB?",
  "Can fosofmycin be used for pyelonephritis?",
  "Is IV antibiotics better than oral antibiotics?"
)

content = prompt$format(
  text=documents,
  question=questions
)

# Step 9: Generate Content / aka Langchain lingo == invoke
response <- llm$generate_content(contents=content)

# Step 10: Let's simulate a streaming response 🤪
print_keystrokes <- function(text) {
  for (char in strsplit(text, "")[[1]]) {
    cat(char) # Print the character
    Sys.sleep(0.005) # Optional delay for visual effect
  }
  cat("\n") # Add a newline at the end
}

print_keystrokes(response$text)
```

## Response

![](gemini.gif)
OK, we don’t really need step 10, it’s actually more for show 🤪 But, what do you think? Is it better than our prior RAG?

Let’s take a closer look here:

1.  **What is the preferred treatment of CRE?**
    - For infections caused by Enterobacterales isolates that are NOT carbapenemase producing that exhibit susceptibility to meropenem and imipenem (i.e., MICs ≤1 µg/mL), but are not susceptible to ertapenem (i.e., MICs ≥1 µg/mL), the use of extended-infusion meropenem (or imipenem-cilastatin) is suggested.
    - For infections caused by Enterobacterales isolates that are NOT carbapenemase producing and that do not exhibit susceptibility to any carbapenem, ceftazidime-avibactam, meropenem-vaborbactam, and imipenem-cilastatin-relebactam are preferred treatment options.
    - For infections caused by CRE if KPC production is present: Meropenem-vaborbactam, ceftazidime-avibactam, and imipenem-cilastatin-relebactam are preferred treatment options. Cefiderocol is an alternative option.
    - For infections caused by CRE if NDM or other MBL production is present: Ceftazidime-avibactam in combination with aztreonam, or cefiderocol as monotherapy, are preferred treatment options.
    - For infections caused by CRE if OXA-48-like production is present: Ceftazidime-avibactam is the preferred treatment option. Cefiderocol is an alternative treatment option.

> First of all, I didn’t even specify which conditions and Gemini was able to return responses for different conditions. Something we definitely did not see with our previous WizardLM model. The response overall also appeared to be quite accurate.

2.  **What is the preferred treatment of ESBL-E?**
    - For uncomplicated cystitis: Nitrofurantoin and TMP-SMX are preferred treatment options.
    - For pyelonephritis or cUTI: TMP-SMX, ciprofloxacin, or levofloxacin are preferred treatment options. Ertapenem, meropenem, and imipenem-cilastatin are preferred agents when resistance or toxicities preclude the use of TMP-SMX or fluoroquinolones.
    - For infections outside of the urinary tract: Meropenem, imipenem-cilastatin, or ertapenem are preferred. For critically ill patients and/or those with hypoalbuminemia, meropenem or imipenem-cilastatin are preferred.

> Impressive! It separated different conditions and accurately returned uncomplicated cysitis vs pyelonephritis and its treatment. Also impressive to caution ertapenem use in the setting of hypoalbuminemia in critically ill patients, offered the appropriate treatment. Wow! I’m starting to like what I’m seeing so far.

3.  **Can we use fosfomycin in ESBL Klebsiella?**
    - No, fosfomycin is not suggested for the treatment of infections caused by Klebsiella pneumoniae.

> Correct!

4.  **Can we use fosfomycin in ESBL Ecoli?**
    - Yes, oral fosfomycin is an alternative treatment option exclusively for uncomplicated cystitis caused by E. coli, including if carbapenem resistant.

> Yup!

5.  **What is the preferred treatment of stenotrophomonas?**
    - Two approaches are preferred:
      - The use of two of the following agents: cefiderocol, minocycline, TMP-SMX, or levofloxacin.
      - The combination of ceftazidime-avibactam and aztreonam.

> This response is quite amazing! Our previous RAG can’t get accurate response without removing reference and also use proper term such as “s. maltophila”, but Gemini was able to return the correct response without requiring any additional cleaning!

6.  **What is the preferred treatment of DTR Pseudomonas?**
    - Ceftolozane-tazobactam, ceftazidime-avibactam, and imipenem-cilastatin-relebactam are preferred options for infections outside of the urinary tract. Cefiderocol is an alternative treatment option.
    - For uncomplicated cystitis: Ceftolozane-tazobactam, ceftazidime-avibactam, imipenem-cilastatin-relebactam, and cefiderocol are the preferred treatment options. Tobramycin or amikacin (as a single dose) are alternative treatment options.
    - For pyelonephritis or cUTI: Ceftolozane-tazobactam, ceftazidime-avibactam, imipenem-cilastatin-relebactam, and cefiderocol are preferred treatment options. Once-daily tobramycin or amikacin are alternative agents.
    - For DTR P. aeruginosa that produce metallo-β-lactamase enzymes: Cefiderocol is the preferred treatment.

> Looks about right.

7.  **Which organisms require two active agents when susceptibility is known?**
    - The document suggests using two active agents for the treatment of S. maltophilia infections, at least until clinical improvement is observed.
    - It also suggests using at least two agents for the treatment of CRAB infections, at least until an appropriate clinical response is observed.

> OK, this is a tricky one! Because no matter how I tweaked it, I couldn’t get the right answer to return both stenotrophomonas and CRAB, but Gemini was able to! Truly impressive!

8.  **Can we use gentamicin in pseudomonas infection?**
    - Yes, gentamicin is an alternative option for the treatment of DTR P. aeruginosa pyelonephritis or cUTI. However, as of 2023, there are no longer breakpoints for gentamicin for P. aeruginosa.

> Wait a minute, why is it “yes” for this question? It is interesting that it was able to return the second sentence.

9.  **Can we use tobramycin to treat pseudomonas infection?**
    - Yes, tobramycin is an alternative option for the treatment of DTR P. aeruginosa pyelonephritis or cUTI. It may also be helpful for completing treatment courses (e.g., transitioning from another agent for terminal doses) given its prolonged duration of activity in the renal cortex and the convenience of once daily dosing.

> Cool beans!

10. **Why is there carbapenemase non-producing organism?**
    - Carbapenemase non-producing CRE may be the result of amplification of non-carbapenemase β-lactamase genes (e.g., ESBL genes) with concurrent outer membrane porin disruption.

> A bit confused. why ESBL in CRE? 🧐

11. **Can we use oral antibiotics for any of these MDRO?**
    - Yes, oral antibiotics can be used for some MDRO infections, but only after appropriate clinical response is achieved and if susceptibility to an appropriate oral agent is demonstrated.
    - For example, transitioning to oral TMP-SMX, ciprofloxacin, or levofloxacin should be considered for ESBL-E, AmpC-E, and CRE infections outside of the urinary tract.

> Sure

12. **What is the preferred treatment of MRSA?**
    - The document does not discuss MRSA treatment.

> Good return! Did not hallucinate or try to return an answer, with very minimal prompt engineering!

13. **What is the preferred treatment of CRAB?**
    - The preferred regimen is sulbactam-durlobactam in combination with a carbapenem (i.e., imipenem-cilastatin or meropenem). An alternative regimen is high-dose ampicillin-sulbactam (total daily dose of 9 grams of the sulbactam component) in combination with at least one other agent (i.e., polymyxin B, minocycline \> tigecycline, or cefiderocol), if sulbactam-durlobactam is not available.

> Not bad!

14. **Can fosofmycin be used for pyelonephritis?**
    - No, fosfomycin is not suggested for the treatment of pyelonephritis or cUTI given its limited renal parenchymal concentrations.

> Alright!

15. **Is IV antibiotics better than oral antibiotics?**
    - The document does not explicitly state that IV antibiotics are better than oral antibiotics. However, it does suggest transitioning to oral therapy whenever possible, particularly if the following criteria are met: (1) susceptibility to an appropriate oral agent is demonstrated, (2) the patient is hemodynamically stable, (3) reasonable source control measures have occurred, and (4) concerns about insufficient intestinal absorption are not present.

> Not too shabby too!

## LLM As A Judge

![](judge.jpg)
Using an LLM as a judge to evaluate other LLMs’ responses involves leveraging advanced language models to assess output quality across various dimensions. Key aspects to evaluate include relevance, coherence, factual accuracy, completeness, language quality, reasoning, creativity, safety, and task-specific criteria. The process requires careful prompt engineering, model selection, and consistency checks. Evaluators should consider relevance to the query, logical structure, factual correctness, comprehensiveness, grammar, reasoning quality, originality, ethical considerations, and metacognitive awareness. Implementing this approach necessitates designing clear evaluation criteria, using few-shot examples, and developing a robust scoring system while remaining mindful of potential biases in the judge model itself.

In our use case, we will assess the relevance, factual accuracy, and also succintness of the response. The whole point of using LLM as a tool to chat with document is basically to get the essence of the context, hence I do not want it to return the whole text, but more so a concise output to help me either gain knowledge efficiently, or ask more questions. Either way, that’s great for life-long learning!

Let’s use Anthropic Claude Sonnet 3.5 to assess Gemini’s Flash 1.5’s response 🤣

<div class="datatables html-widget html-fill-item" id="htmlwidget-1" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"],["CRE treatment","ESBL-E treatment","Fosfomycin in ESBL Klebsiella","Fosfomycin in ESBL E. coli","Stenotrophomonas treatment","DTR Pseudomonas treatment","Two active agents","Gentamicin in Pseudomonas","Tobramycin in Pseudomonas","Carbapenemase non-producing","Oral antibiotics for MDRO","MRSA treatment","CRAB treatment","Fosfomycin for pyelonephritis","IV vs. oral antibiotics"],[0.97,0.95,1,1,1,0.98,0.95,0.93,0.95,0.97,0.95,1,0.98,1,0.9],[0.98,0.97,1,0.97,0.98,0.97,0.97,0.97,0.98,1,0.93,1,0.97,0.98,0.95],[0.83,0.9,1,0.93,0.95,0.85,0.93,0.9,0.87,1,0.9,1,0.9,0.95,0.87]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>Question<\/th>\n      <th>Relevance<\/th>\n      <th>Accuracy<\/th>\n      <th>Succinctness<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4]},{"orderable":false,"targets":0},{"name":" ","targets":0},{"name":"Question","targets":1},{"name":"Relevance","targets":2},{"name":"Accuracy","targets":3},{"name":"Succinctness","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\nvar value=data[2]; $(this.api().cell(row, 2).node()).css({'color':'black','background-color':isNaN(parseFloat(value)) ? '' : value <= 0.87 ? \"rgb(255,255,255)\" : value <= 0.9 ? \"rgb(244,244,255)\" : value <= 0.9 ? \"rgb(232,232,255)\" : value <= 0.924 ? \"rgb(221,221,255)\" : value <= 0.93 ? \"rgb(210,210,255)\" : value <= 0.95 ? \"rgb(198,198,255)\" : value <= 0.95 ? \"rgb(187,187,255)\" : value <= 0.95 ? \"rgb(176,176,255)\" : value <= 0.966 ? \"rgb(164,164,255)\" : value <= 0.97 ? \"rgb(153,153,255)\" : value <= 0.97 ? \"rgb(142,142,255)\" : value <= 0.97 ? \"rgb(131,131,255)\" : value <= 0.98 ? \"rgb(119,119,255)\" : value <= 0.98 ? \"rgb(108,108,255)\" : value <= 0.98 ? \"rgb(97,97,255)\" : value <= 1 ? \"rgb(85,85,255)\" : value <= 1 ? \"rgb(74,74,255)\" : value <= 1 ? \"rgb(63,63,255)\" : value <= 1 ? \"rgb(51,51,255)\" : \"rgb(40,40,255)\"});\nvar value=data[3]; $(this.api().cell(row, 3).node()).css({'color':'black','background-color':isNaN(parseFloat(value)) ? '' : value <= 0.87 ? \"rgb(255,255,255)\" : value <= 0.9 ? \"rgb(244,244,255)\" : value <= 0.9 ? \"rgb(232,232,255)\" : value <= 0.924 ? \"rgb(221,221,255)\" : value <= 0.93 ? \"rgb(210,210,255)\" : value <= 0.95 ? \"rgb(198,198,255)\" : value <= 0.95 ? \"rgb(187,187,255)\" : value <= 0.95 ? \"rgb(176,176,255)\" : value <= 0.966 ? \"rgb(164,164,255)\" : value <= 0.97 ? \"rgb(153,153,255)\" : value <= 0.97 ? \"rgb(142,142,255)\" : value <= 0.97 ? \"rgb(131,131,255)\" : value <= 0.98 ? \"rgb(119,119,255)\" : value <= 0.98 ? \"rgb(108,108,255)\" : value <= 0.98 ? \"rgb(97,97,255)\" : value <= 1 ? \"rgb(85,85,255)\" : value <= 1 ? \"rgb(74,74,255)\" : value <= 1 ? \"rgb(63,63,255)\" : value <= 1 ? \"rgb(51,51,255)\" : \"rgb(40,40,255)\"});\nvar value=data[4]; $(this.api().cell(row, 4).node()).css({'color':'black','background-color':isNaN(parseFloat(value)) ? '' : value <= 0.87 ? \"rgb(255,255,255)\" : value <= 0.9 ? \"rgb(244,244,255)\" : value <= 0.9 ? \"rgb(232,232,255)\" : value <= 0.924 ? \"rgb(221,221,255)\" : value <= 0.93 ? \"rgb(210,210,255)\" : value <= 0.95 ? \"rgb(198,198,255)\" : value <= 0.95 ? \"rgb(187,187,255)\" : value <= 0.95 ? \"rgb(176,176,255)\" : value <= 0.966 ? \"rgb(164,164,255)\" : value <= 0.97 ? \"rgb(153,153,255)\" : value <= 0.97 ? \"rgb(142,142,255)\" : value <= 0.97 ? \"rgb(131,131,255)\" : value <= 0.98 ? \"rgb(119,119,255)\" : value <= 0.98 ? \"rgb(108,108,255)\" : value <= 0.98 ? \"rgb(97,97,255)\" : value <= 1 ? \"rgb(85,85,255)\" : value <= 1 ? \"rgb(74,74,255)\" : value <= 1 ? \"rgb(63,63,255)\" : value <= 1 ? \"rgb(51,51,255)\" : \"rgb(40,40,255)\"});\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

Wow, not too shabby! Even Claude agreed for the most part. I basically attached the pdf on Claude Sonnet 3.5, and then wrote a prompt below:

`you are an LLM as a judge. Evaluate the answers here and provide a score from 0 to 1 of the relevance, factual accuracy, succinct, of the response to the question. Assess it 3 times for each metrics and average out the scores. Attached is the context being used to answer the questions.`

Then pasted the Gemini’s response and had Claude output schema to data.frame, and use DT heatmap, hence the colored DT datatable! ❤️

## Limitations

- The free version of Gemini 1.5 Flash does use your data for further improvement of their product.
- The response is rather short, from my experience when I used Anthropic Claude Sonnet 3.5 with RAG, it actually provided more context and digestion of retrieved document.
- There is no R version, but we can definitely leverage the power of `reticulate` to access all `python modules`

## Lessons learnt

- Learnt how to use Gemini 1.5 Flash in R via reticulate
- learnt `dotenv` in python
- learnt how to perform LLM-as-a-judge

Overall, I am quite impressed with the responses! With minimal prompt engineering, document cleaning! It was able to return accurate responses, and even separated different conditions and provided appropriate treatment options. It was also able to return the correct response for tricky questions that our RAG was not able to. It definitely has potential!

We haven’t explored context caching yet here but if there is a long context you can upload the file and use context caching for a lower price. See [this](https://ai.google.dev/gemini-api/docs/caching?lang=python)

Lastly, is it better than RAG? Well, it depends. I think for documents + prompt + query does not exceed 1 Million tokens per minute, maybe. Otherwise, RAG appears to be more effective and also there is a better way to ensure what context were retrieved, unlike this. So, there you have it, if you want a plug and play without understanding the what is going on under the hood, this might be a good one for you! Otherwise, if you’re like me who is nosy and want to know what’s going on, might still want to stick with RAG for a bit. 🤣

<br>

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
