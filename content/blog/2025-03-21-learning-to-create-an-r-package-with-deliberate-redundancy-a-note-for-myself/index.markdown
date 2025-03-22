---
title: "Learning To Create an R Package With Deliberate Redundancy \U0001F923 A Note
  For Myself"
author: Ken Koon Wong
date: '2025-03-22'
slug: rpackage1
categories: 
- r
- R
- package
- reticulate
tags: 
- r
- R
- package
- reticulate
excerpt: 🙈 Made a hilariously redundant R package for a simple OpenAI calls, but the real win was finally learning how to build an R package! 🛠️ Is it efficient? Absolutely not!Was it worth the time and experience? Yes! Will I do it again? Yes! Will it break? Yes! 🤣 
---

> 🙈 Made a hilariously redundant R package for a simple OpenAI calls, but the real win was finally learning how to build an R package! 🛠️ Is it efficient? Absolutely not!Was it worth the time and experience? Yes! Will I do it again? Yes! Will it break? Yes! 🤣

![](box.jpg)

## Motivations
We've been using a lot of LLM lately especially OpenAI GPT4omini via `reticulate`. Trying to load `reticulate` -> import OpenAI -> initialize it -> insert API_key etc again and again whenever we want to use it for a new project or new script, that's just very redundant, tedious and so on. 

Recently, with motivation from `Alec Wong` kindly recommending me to read [R Package](https://r-pkgs.org/) after I asked him a noob question "How does one test and make changes of an existing R package and pull request?" 🤣 The book is great! I really enjoy the first part, it actually teaches you how to create an R package right from the get go! Before it dives into the details. I found that to be extremely refreshing, because you can easily create an MVP right upfront for personal use by following a workflow! 🙌 

With the LLM in mind, and wanting to learn how to create an R package (ahem properly, best practice 🫡), why don't we try to make our very own package called `myopenai` !? Alright, there is already a brilliant package called `ellmer`, and my current project is most likey redundant (hence the title), but what a better way to start learning? And we're going to do it the inefficient way, via `reticulate` (this is when you see R experts shake their head of disbelief 🤭) instead of the http API! 🤣 Join me in learning how to create an R Package! 

Seriously though, this is not an efficient way of using openAI API... It's for demonstration purposes only. 

## The Original Code

``` r
reticulate::use_virtualenv("openai")
library(reticulate)

openai <- import("openai")
OpenAI <- openai$OpenAI

client = OpenAI(api_key = 'YOUR API KEY') ## change this to yours  

response <- client$chat$completions$create(
  model = "gpt-4o-mini",
  messages = list(dict(
    role = "system",
    content = "You are a summarizer. Please summarize the following abstract. 
    Include statistics.Use emoji to shorten characters. The summary must not 
    exceed 200 characters—if you reach 200 characters, stop immediately. 
    Do not add any extra commentary or exceed the 200-character limit."
  ), dict(
    role = "user",
    content = df_new[10,"item_description"] |> pull()
  )
  ),
  temperature = 0
)

(summary <- response$choices[[1]]$message$content)
```

The above was our previous code. Now we will use the above code, turn it into a function and hopefully at the end of the project we'll have a library called `myopenai` and we can call a function `chat()` and just need to insert the prompt, or pipe the prompt into the function. 

## Objectives:
- [The Workflow](#workflow)
  - [create_package()](#create)
  - [use_git()](#git)
  - [Write The Function](#function)
  - [use_r()](#use_r)
  - [load_all()](#load_all)
  - [check()](#check)
  - [Edit DESCRIPTION](#description)
  - [use_mit_license()](#license)
  - [Insert roxygen2 skeleton on function](#roxygen2)
  - [document()](#document)
  - [use_package()](#package)
  - [check() again and install()](#last)
- [Further Improvement](#improvement)
  - [Split Files To `Chat.R` and `utils.R`](#split)
  - [Add Unit Testing](#testing)
- [Acknowledgement](#ack)
- [Lessons Learnt](#lessons)

## The Workflow {#workflow}

A quick note for myself:
1. Load devtool, create_package()
2. use_git(), will likely need restart
4. load devtools again, write first function
6. use_r("function"), then insert function there
7. load_all()
8. check()
9. edit DESCRIPTION
10. use_mit_license()
12. insert roxygen2 skeleton on function, edit
13. document()
14. since we need other packages, use_package()
15. check()


## `usethis::create_package` {#create}

``` r
usethis::create_package("myopenai")
```

![](create_package_error.png)
You might see something like this if you already have a `.git` on the working directory, try to create a package in a new directory that doesn't have a parent directory with `.git` in it and it'll open to a new project session with basic, something like `usethiss::create_package("/Users/you/Document/myopenai")`. You will notice that you have basic files such as.

<p align="center">
  <img src="files.png" alt="image" width="40%" height="auto">
</p>


[Read here](https://r-pkgs.org/whole-game.html) for what the directories or files represent.

## `use_git` {#git}

``` r
library(devtools)

use_git()
```

You will receive 2 questions, basically if you want to use git for version control and also if you want to commit. Say yes to both. Then your project session will restart. Note that every time it restarts, you have to reload `devtools`

## Write A Function {#function}
Haven't figured out what is the best way to do this at yet, do we write a minimal functional code somewhere else and then copy it into project or just create an untitlted R script and write a minimal functional code before `use_r()` function? Anyway, for now just create an untitled script and start writing before we paste it in a more organized R file.


``` r
chat <- function(prompt="how are you?", system="", temp=0, max_tokens = 500L) {
  
  ## If virtualenv does not exist, create and install openai
  if (reticulate::virtualenv_exists(envname = "openai")==FALSE) {
    reticulate::virtualenv_create(envname = "openai", packages = c("openai"))
    }
  
  ## Start Env
  reticulate::use_virtualenv("openai")
  
  ## Initialize OpenAI
  OpenAI = reticulate::import("openai")$OpenAI
  client = OpenAI(api_key = "YOUR API KEY")

  ## Prompt
  response = client$chat$completions$create(
    model = "gpt-4o-mini",
    messages = list(reticulate::dict(
      role = "system",
      content = system
    ),
    reticulate::dict(
      "role" = "user",
      "content" = prompt
    )),
    temperature = temp,
    max_tokens = max_tokens
  )
  
  ## Response
  message = response$choices[[1]]$message$content

  return(message)
}
```

Alright, the above code is quite similar to our original, but at least now it's a function and we have some default parameters inserted so when we call `chat()` without any parameters in it, it will at least return something. Note above is not the efficient at all, best to communicate with openAI API is still via `httr2`, you will have much less dependencies. Also, note that above is again, not to most defensive coding practice either but we can improve from there, including setting your API key in `.Rprofile`. 

## `usethis::use_r()` {#use_r}

``` r
usethis::use_r("chat")
```

This will create a blank R file called `chat.R` in R folder. We then copy our minimal function code into this script. Do not run anything yet! That's the next step. We don't necessarily have to create an R script for every function. We should at least name it where it's machine & human readable, sort-friendly if date used [read here more on Tidy style guide](https://style.tidyverse.org/files.html). 

About organization? It's hard, like smart brevity
> It’s hard to describe exactly how you should organise your code across multiple files. I think the best rule of thumb is that if you can give a file a concise name that still evokes its contents, you’ve arrived at a good organisation. But getting to that point is hard. -Tidyverse style guide

## `devtools::load_all()` {#load_all}
On the console, enter the following:


``` r
devtools::load_all()
```

![](load_all.png)

This will make the entire package available / interactive. And that's when we can test our function and debug if there is error. As you can see in the above image, when we call `chat()` it returned a response. The book explains the difference between `source` and `running as a library`, [here](https://r-pkgs.org/whole-game.html#sec-whole-game-load-all)

## `devtools::check()` {#check}

``` r
devtools::check()
```

![](check.png)

The function `check()` is essential because it runs comprehensive tests to ensure all components of an R package work correctly, catching issues early when they're easier to fix. It validates that your package meets CRAN standards, maintaining code quality and preventing downstream problems for users. Regular checking establishes good development habits, especially before sharing your package with others or submitting it to repositories.

The above image showed that we have 2 warnings, let's fix it!

## Edit DESCRIPTION {#description}
Before we start to fix the 2 things above, let's edit our DESCRIPTION. 

![](description.png)

Feel free to edit title, description, author info

## `usethis::use_mit_license()` {#license}

``` r
# if you already loaded `devtools` you can just
use_mit_license()
```


<p align="center">
  <img src="license.png" alt="image" width="60%" height="auto">
</p>


## Insert roxygen2 skeleton on function {#roxygen2}
Click on the chat function area, then go to `Code > Insert Roxygen2 Skeleton`

<p align="center">
  <img src="roxygen2.png" alt="image" width="50%" height="auto">
</p>


Then it will look something like 

![](roxygen2_chunk.png)
Then you can edit it as such 

``` r
#' GPT4omini chat convenience
#'
#' @param system System Prompt
#' @param prompt User Prompt
#' @param temp Temperature
#' @param max_tokens Max Tokens
#'
#' @return String Response
#' @export
#'
#' @examples
#' chat("what is 2+2?")
chat <- function(prompt="how are you?", system="", temp=0, max_tokens = 500L) {

  ## If virtualenv does not exist, create and install openai
  if (reticulate::virtualenv_exists(envname = "openai")==FALSE) {
    reticulate::virtualenv_create(envname = "openai", packages = c("openai"))
  }
```

## `devtools::document()` {#document}

<p align="center">
  <img src="document.png" alt="image" width="50%" height="auto">
</p>

The `document()` function converts roxygen2 comments in your R source files into proper R documentation files, specifically creating the `.Rd` files needed for help pages and updating the NAMESPACE file. This process transforms human-readable special comments into the formal documentation structure required by R, making your package's functions discoverable and usable through the standard help system.

and when you do this 

``` r
?chat
```
you will see this

<p align="center">
  <img src="help.png" alt="image" width="80%" height="auto">
</p>

## `usethis::use_package()` {#package}

``` r
usethis::use_package("reticulate")
```

The `use_package()` function formally declares dependencies by adding packages to the `Imports` field in your package's DESCRIPTION file, allowing you to use functions from external packages like `reticulate`. 

## Let's Run `check()` Again and `install()` {#last}

``` r
devtools::check()
```

![](greenlight.png)

Yesh. Good sign!!! 


``` r
devtools::install()
```

and now you can go to Rstudio and the below code should work!


``` r
library(myopenai)

"what is 10 + 5?" |> chat()
```


```
## [1] "10 + 5 equals 15."
```

🙌🤘🤩 we did it!!! 

## Further Improvement Of The Package {#improvement}
### Split Files To `Chat.R` and `utils.R` {#split}
#### Chat.R

``` r
#' Set you Open API key
#'
#' @param key your API key
#'
#' @return set environment
#' @export
#'
#' @examples
#' \dontrun{
#' set_api_key("your-api-key-here")
#' }
set_api_key <- function(key=NULL) {
  if (is.null(key)) { cli::cli_abort("Need to insert API key on key parameter")}
  if (!is.null(key)) {
    key_old <- Sys.getenv("OPENAI_KEY")
    if (key==key_old) { cli::cli_alert_warning("Your previous API key is the same as the one currently provided") }

    if (key!=key_old) {
      set_env(key)
      cli::cli_alert_success("New API Key Inserted")
      rstudioapi::restartSession()
    }

    if (key_old=="") {
      set_env(key)
      cli::cli_alert_success("API Key Inserted")
      rstudioapi::restartSession()
    }
  }
}


#' GPT4omini chat convenience
#'
#' @param system System Prompt
#' @param prompt User Prompt
#' @param temp Temperature
#' @param max_tokens Max Tokens
#' @param api_key use `set_api_key` to set it in R environment
#'
#' @return String Response
#' @export
#'
#' @examples
#' chat("what is 2+2?")
chat <- function(prompt="how are you?", system="", temp=0, max_tokens = 500L, api_key = openai_api_key()) {

  # check to see if virtualenv is installed
  if (reticulate::virtualenv_exists(envname = "openai")==FALSE) {
    reticulate::virtualenv_create(envname = "openai", packages = c("openai"))
    rstudioapi::restartSession()
  }

  # check to see if there is api_key set
  if (api_key=="") { cli::cli_abort("No API key found. Need to insert API key by using {.code set_api_key()}") }

  ## Start Env
  reticulate::use_virtualenv("openai")

  ## Initialize OpenAI
  OpenAI = reticulate::import("openai")$OpenAI
  client = OpenAI(api_key = api_key)

  ## Prompt
  response = client$chat$completions$create(
    model = "gpt-4o-mini",
    messages = list(reticulate::dict(
      role = "system",
      content = system
    ),
    reticulate::dict(
      "role" = "user",
      "content" = prompt
    )),
    temperature = temp,
    max_tokens = max_tokens
  )

  ## Response
  message = response$choices[[1]]$message$content

  return(message)
}
```

#### utils.R

``` r
openai_api_key <- function() {
  key <- Sys.getenv("OPENAI_KEY")

  if (key=="") { cli::cli_abort("No API key found. Need to insert API key by using {.code set_api_key()}") }
  else {
    return(key)
  }
}

set_env <- function(key) {
  renviron_path <- file.path(Sys.getenv("HOME"), ".Renviron")

  api_key_entry <- paste0("OPENAI_KEY=",key)

  if (!file.exists(renviron_path)) {
    file.create(renviron_path)
  }
  
  # Read existing content
  existing_content <- readLines(renviron_path, warn = FALSE)

  if (!any(grepl("^OPENAI_KEY=", existing_content))) {
    # Append the new entry
    write(api_key_entry, renviron_path, append = TRUE)
  } else {
    # Replace existing entry
    existing_content[grepl("^OPENAI_KEY=", existing_content)] <- api_key_entry
    writeLines(existing_content, renviron_path)
  }
}
```

Read more from the book to get an intuition of why we have `chat.R` and `utils.R`. Basically, you want functions that get exported to be in `chat.R` or similar R file, and supportive functions that are not exported to be in `utils.R`, instead of all functions in 1 file, mainly for readability / organization. That's a really good idea. 

There are plenty more things to improve on. We can spend many hours revising this! Let's move on to `testing`

### Add Unit Testing {#testing}

``` r
use_test("chat")
```

This will create another folder (`tests`) and file (`test-chat.R`).

#### test-chat.R

``` r
test_that("chat(\"2+2?\") make sure it returns 4", {
  expect_equal(chat("what is 2+2? return answer only") |> as.numeric(), 4)
})
```

We then enter something like the above to make sure it returns the answer we want to make sure it works. And it will look something like this after.


``` r
test()
```

<p align="center">
  <img src="test.png" alt="image" width="50%" height="auto">
</p>


🙌🤘🤩 we did it!!! 


This is a great image of the actual workflow from the book. 

<p align="center">
  <img src="https://r-pkgs.org/diagrams/workflow.png" alt="image" width="100%" height="auto">
</p>

## Acknowledgement {#ack}
I am grateful of the book and also the style of putting the simple example right up front to stimulate curiosity and having the end in mind. That makes learning very inspirational. I also want to thank `Alec Wong` for guiding me to this book that pushed me to learn the workflow of creating an R package. Now I have some idea on how this works, it makes contributing to existing R packages a step closer!!! woo hoo!!! Not that I have much to contribute 🤣


## Lessons Learnt {#lessons}
- Learnt R package workflow/best practice (highly recommend a [read](https://r-pkgs.org/))
- Learnt `Sys.getenv`, and how to write it to R environment
- Learnt some basics of `cli` package
- Learnt `\dontrun{}` on roxygen2 example so that it doesn't execute the function. Before this my `set_api_key()` example kept setting OPENAI_KEY to `your-api-key-here` lol
- Learnt `grepl`, been always used to `str_detect` now at least we can use ReGex with base

<br>


If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)


