---
title: 'Setting Up A Cluster of Tiny PCs For Parallel Computing - A Note To Myself'
author: Ken Koon Wong
date: '2026-01-16'
slug: parallel-computing
categories: 
- r
- R
- future
- parallel computing
- cluster
- multicore
- tmle
- superlearner
tags: 
- r
- R
- future
- parallel computing
- cluster
- multicore
- tmle
- superlearner
excerpt: Enjoyed learning the process of setting up a cluster of tiny PCs for parallel computing. A note to myself on installing Ubuntu, passwordless SSH, automating package installation across nodes, distributing R simulations, and comparing CV5 vs CV10 performance. Fun project!
---
<script src="{{< blogdown/postref >}}index_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index_files/lightable/lightable.css" rel="stylesheet" />

> Enjoyed learning the process of setting up a cluster of tiny PCs for parallel computing. A note to myself on installing Ubuntu, passwordless SSH, automating package installation across nodes, distributing R simulations, and comparing CV5 vs CV10 performance. Fun project!

## Motivations
Part of something I want to learn this year is getting a little more into parallel computing. How we can distribute simulation computations across different devices. Lately, we have more reasons to do this because quite a few of our simulations require long running computation and leaving my laptop running overnight or several days is just not a good use it. We have also tried cloud computing as well and without knowing how those distributed cores are, well, distributed, it's hard for me to conceptualize how these are done and what else we could optimize. Hence, what is a better way of doing it on our own! Sit tight, this is going to be a bumpy one. Let's go!

![](parallel.jpg)

## Objectives
- [Which PCs to get?](#shop)
- [Install Ubuntu](install)
- [Align and fix IPs](network)
- [Passwordless ssh](#passwordless)
- [Send multiple commands via ssh](#commands)
  - [Install R](#r)
  - [Create A Template R script For Simulation](#template)
  - [Install Packages On All Nodes](#install-packages)
  - [Upload Rscript to Nodes](#upload)
  - [Run Rscript](#script)
  - [Extract data](#extract)
- [Compare time](#compare)
- [Opportunities for improvement](#opportunity)
- [Lessons learnt](#lessons)

## Which PCs to Get? {#shop}
<p align="center">
  <img src="https://p1-ofp.static.pub/medias/bWFzdGVyfHJvb3R8MTU0MzM5fGltYWdlL3BuZ3xoYzIvaDhhLzk4NDc0MDE3NDIzNjYucG5nfGI1ODRkYjMyY2JmYmIyODJiOWM1YTI1NzhjODBlOWNkYjJlYjgwMDMxMWE1ZTUzZDA1M2YwNDNlNWUxNDM4NmQ/lenovo-thinkcentre-m715-refresh-hero.png?width=400&height=400" alt="image" width="40%" height="auto">
</p>

Preferably something functional and cheap! Something like a used Lenovo M715q Tiny PCs or something similar. 

## Install Ubuntu {#install}
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ubuntu-logo-2022.svg/500px-Ubuntu-logo-2022.svg.png" alt="image" width="50%" height="auto">
</p>

1. Download [Ubuntu Server](https://ubuntu.com/download/server)
2. Create a bootable USB using [balenaEtcher](https://www.balena.io/etcher/)
3. When starting Lenovo up, press F12 continuously until it shows an option to boot from USB. If F12 does not work, reboot and press F1 to BIOS. Go to `Startup` Tab, change CSM Support to `Enabled`. Then set `Primary Boot Priority` to `USB` by moving priority to first. Then `F10` to save configuration and exit. It will then reboot to USB.
4. Make sure it's connected to internet via LAN for smoother installation.
5. Follow the instructions to install Ubuntu, setting username, password etc. Then reboot.
6. Make sure to remove USB drive, if you didn't it'll remind you. Et voila! 

The installations were very quick, compared to the other OS I've installed in the past. Very smooth as well. I thoroughly enjoyed seeting these up.

## Align and Fix IPs {#network}
For organizational purpose, make sure you go to your router setting and set your computer clusters to convenient IPs such as 192.168.1.101, 192.168.1.102, 192.168.1.103 etc. You may have to reboot your computer clusters after changing it on your router. 

## Passwordless SSH {#passwordless}
Next, you want to set up passwordless SSH. This is crucial for R to work! 

#### 1. Create a key

``` bash
ssh-keygen -t ed25519
```

#### 2. Send Copy of Key To Your Node

``` bash
ssh-copy-id -i .ssh/my_key.pub username1@192.168.1.101 
```

it will prompt you to enter your password, then after that you won't need a pssword to ssh in.

### Passwordless Sudo
This is optional. But if you're like me, don't want to repeat lots of typing on installation, and see if you can use bash or R to install packages, you'd need this.


``` bash
ssh -t username2@192.168.1.102 'echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$(whoami)'
```

It would prompt you to enter your password. You would have to do this for all your nodes 

## Send Multiple Commands Via SSH {#commands}
### Install R {#r}

``` bash
for host in username1@192.168.1.101 username2@192.168.1.102 username3@192.168.1.103; do
  ssh -t $host 'sudo apt update && sudo apt install -y r-base r-base-dev'
done
```

This is basically installing R on all of our clusters one after another.

### Create A Template R script For Simulation {#template}
Why do we do this? We want to take advantage of the `multicore` of each nodes as opposed to using `clusters` on `future` as the overhead network may add on to the time and makes optimization less efficiency. Instead, we will send a script to each node so that it can fork its own cores to run the simulation. Also, if we specify packages on our script, we can automate the process of installing these packages on our nodes. 

<details>
<summary>code</summary>

``` r
library(future)
library(future.apply)
library(dplyr)
library(SuperLearner)
library(ranger)
library(xgboost)
library(glmnet)

plan(multicore, workers = 4)

set.seed(1)

n <- 10000
W1 <- rnorm(n)
W2 <- rnorm(n)
W3 <- rbinom(n, 1, 0.5)
W4 <- rnorm(n)

# TRUE propensity score model
A <- rbinom(n, 1, plogis(-0.5 + 0.8*W1 + 0.5*W2^2 + 0.3*W3 - 0.4*W1*W2 + 0.2*W4))

# TRUE outcome model
Y <- rbinom(n, 1, plogis(-1 + 0.2*A + 0.6*W1 - 0.4*W2^2 + 0.5*W3 + 0.3*W1*W3 + 0.2*W4^2))

# Calculate TRUE ATE
logit_Y1 <- -1 + 0.2 + 0.6*W1 - 0.4*W2^2 + 0.5*W3 + 0.3*W1*W3 + 0.2*W4^2
logit_Y0 <- -1 + 0 + 0.6*W1 - 0.4*W2^2 + 0.5*W3 + 0.3*W1*W3 + 0.2*W4^2

Y1_true <- plogis(logit_Y1)
Y0_true <- plogis(logit_Y0)
true_ATE <- mean(Y1_true - Y0_true)

df <- tibble(W1 = W1, W2 = W2, W3 = W3, W4 = W4, A = A, Y = Y)

tune <- list(
  ntrees = c(500,1000),           
  max_depth = c(5,7),                  
  shrinkage = c(0.001,0.01)    
)

tune2 <- list(
  ntrees = c(250, 500, 1000),
  max_depth = c(3,5,7,9),
  shrinkage = c(0.001,0.005,0.01)
)

learners <- create.Learner("SL.xgboost", tune = tune, detailed_names = TRUE, name_prefix = "xgb")
learners2 <- create.Learner("SL.xgboost", tune = tune2, detailed_names = TRUE, name_prefix = "xgb")

# Super Learner library 
SL_library <- list(
  c("SL.xgboost", "SL.ranger", "SL.glm", "SL.mean"),
  c("SL.xgboost","SL.ranger"),
  c("SL.xgboost","SL.glm"),
  list("SL.ranger", c("SL.xgboost", "screen.glmnet")),
  c("SL.glmnet","SL.glm"),
  c("SL.ranger","SL.glm"),
  c(learners$names, "SL.glm"),
  c(learners$names, "SL.glmnet"),
  c("SL.gam","SL.glm"),
  c(learners2$names, "SL.glm"))

# sample
allnum <- START:END
n_sample <- length(allnum)
n_i <- 6000

# Function to run one TMLE iteration
run_tmle_iteration <- function(seed_val, df, n_i, SL_library) {
  set.seed(seed_val)
  data <- slice_sample(df, n = n_i, replace = T) |> select(Y, A, W1:W4)
  
  # Prepare data
  X_outcome <- data |> select(A, W1:W4) |> as.data.frame()
  X_treatment <- data |> select(W1:W4) |> as.data.frame()
  Y_vec <- data$Y
  A_vec <- data$A
  
  # Outcome model
  SL_outcome <- SuperLearner(
    Y = Y_vec,
    X = X_outcome,
    family = binomial(),
    SL.library = SL_library,
    cvControl = list(V = 5)
  )
  
  # Initial predictions
  outcome <- predict(SL_outcome, newdata = X_outcome)$pred
  
  # Predict under treatment A=1
  X_outcome_1 <- X_outcome |> mutate(A=1)
  outcome_1 <- predict(SL_outcome, newdata = X_outcome_1)$pred
  
  # Predict under treatment A=0
  X_outcome_0 <- X_outcome |> mutate(A=0)
  outcome_0 <- predict(SL_outcome, newdata = X_outcome_0)$pred
  
  # Bound outcome predictions to avoid qlogis issues
  outcome <- pmax(pmin(outcome, 0.9999), 0.0001)
  outcome_1 <- pmax(pmin(outcome_1, 0.9999), 0.0001)
  outcome_0 <- pmax(pmin(outcome_0, 0.9999), 0.0001)
  
  # Treatment model
  SL_treatment <- SuperLearner(
    Y = A_vec,
    X = X_treatment,
    family = binomial(),
    SL.library = SL_library,
    cvControl = list(V = 5)
  )
  
  # Propensity scores
  ps <- predict(SL_treatment, newdata = X_treatment)$pred
  
  # Truncate propensity scores 
  ps_final <- pmax(pmin(ps, 0.95), 0.05)
  
  # Calculate clever covariates
  a_1 <- 1/ps_final
  a_0 <- -1/(1 - ps_final)
  clever_covariate <- ifelse(A_vec == 1, 1/ps_final, -1/(1 - ps_final))
  
  epsilon_model <- glm(Y_vec ~ -1 + offset(qlogis(outcome)) + clever_covariate, 
                       family = "binomial")
  epsilon <- coef(epsilon_model)
  
  updated_outcome_1 <- plogis(qlogis(outcome_1) + epsilon * a_1)
  updated_outcome_0 <- plogis(qlogis(outcome_0) + epsilon * a_0)
  
  # Calc ATE
  ate <- mean(updated_outcome_1 - updated_outcome_0)
  
  # Calc SE
  updated_outcome <- ifelse(A_vec == 1, updated_outcome_1, updated_outcome_0)
  se <- sqrt(var((Y_vec - updated_outcome) * clever_covariate + 
                   updated_outcome_1 - updated_outcome_0 - ate) / n_i)
  
  return(list(ate = ate, se = se))
}

# Run iterations in parallel
for (num in 1:length(SL_library)) {
  if (num %in% c(1:9)) { next }
  cat(num)
  cat("TMLE iterations in parallel with 4 workers (multicore)...\n")
  start_time <- Sys.time()
  
  results_list <- future_lapply(START:END, function(i) {
    result <- run_tmle_iteration(i, df, n_i, SL_library[[num]])
    if (i %% 100 == 0) cat("Completed iteration:", i, "\n")
    return(result)
  }, future.seed = TRUE)
  
  end_time <- Sys.time()
  run_time <- end_time - start_time
  
  # Extract results
  predicted_ate <- sapply(results_list, function(x) x$ate)
  pred_se <- sapply(results_list, function(x) x$se)
  
  # Results
  results <- tibble(
    iteration = START:END,
    ate = predicted_ate,
    se = pred_se,
    ci_lower = ate - 1.96 * se,
    ci_upper = ate + 1.96 * se,
    covers_truth = true_ATE >= ci_lower & true_ATE <= ci_upper
  )
  
  # Summary stats
  summary_stats <- tibble(
    metric = c("true_ATE", "mean_estimated_ATE", "median_estimated_ATE", 
               "sd_estimates", "mean_SE", "coverage_probability", "bias"),
    value = c(
      true_ATE,
      mean(predicted_ate),
      median(predicted_ate),
      sd(predicted_ate),
      mean(pred_se),
      mean(results$covers_truth),
      mean(predicted_ate) - true_ATE
    )
  )
  
  # Create output directory if it doesn't exist
  if (!dir.exists("tmle_results")) {
    dir.create("tmle_results")
  }
  
  # Save detailed results (all iterations)
  write.csv(results, paste0("tmle_results/tmle_iterations",num,".csv"), row.names = FALSE)
  
  # Save summary statistics
  write.csv(summary_stats, paste0("tmle_results/tmle_summary",num,".csv"), row.names = FALSE)
  
  # Save simulation parameters
  sim_params <- tibble(
    parameter = c("n_population", "n_sample_iterations", "n_bootstrap_size", 
                  "SL_library", "n_workers", "runtime_seconds"),
    value = c(n, n_sample, n_i, 
              paste(SL_library[[num]], collapse = ", "), 
              4, as.numeric(run_time, units = "secs"))
  )
  write.csv(sim_params, paste0("tmle_results/simulation_parameters",num,".csv"), row.names = FALSE)
  
  # Save as RData for easy loading
  save(results, summary_stats, sim_params, true_ATE, file = paste0("tmle_results/tmle_results",num,".RData"))

}
```
</details>

What we did above is basically a template script (We are saving this as `par_test_script.R`), one where we can edit where to begin and end in terms of which iteration to start and end per node. And also instruction to save result. This is when we can put a little more effort in incorporating some instructions to inform us when task is completed (e.g., via email) and also it would also be nice to know what is the ETA of the entire task by perhaps benchmarking how long the first iteration took to complete, then multiple by total iters per node. Again, this can be sent via email, and also maybe only for the first node as opposed to all nodes, so we're not bombarded with messages beginning and the end. 🤣

### Install Packages On All Nodes {#install-packages}

``` r
## List all of our nodes
my_clusters <- list(
  c("username1@192.168.1.101"),
  c("username2@192.168.1.102"),
  c("username3@192.168.1.103"))


## Grab all of the packages needed on our script  
packages <- gsub("library\\(([^)]+)\\)", "\\1",grep("^library",readLines("par_test_script.R"),value = T))

## Create function to run sudo
remote_r_sudo <- function(host, r_code, intern = FALSE) {
  escaped <- gsub('"', '\\\\"', r_code)
  cmd <- sprintf("ssh %s 'sudo Rscript -e \"%s\"'", host, escaped)
  system(cmd, intern = intern)
}

## Loop over to install
for (cluster_i in my_clusters) {
  print(cluster_i)
  for (package in packages) {
  command <- sprintf('if (!require("%s")) install.packages("%s")', package, package)
  remote_r_sudo(cluster_i, command)
  }
}
```

Make sure your computer doesn't go to sleep with this. If this is the first time your nodes are installing these extensive libraries, it will take a while. Another way we can do this is to use `future_lapply` for all nodes and also `tmux` for all installations so that we don't need to rely on our local workstation to be turned on to continue with the installation. See below on how we used `tmux` to set and forget method.  

## Upload Rscript to Nodes {#upload}
Alright, now we have installed the appropriate packages above, let's upload scripts to our nodes.

#### Distribute Work

``` r
num_list <- list()
clust_num <- 3
total_loop <- 1000
div_iter <- total_loop/clust_num
final_iter <- total_loop #only use this for custom e.g., if one node did not work and it's in charge of 300:500, we can put 500 for this and set first_iter as 300
first_iter <- 1
last_iter <- round(div_iter,0) + first_iter

for (i in 1:clust_num) {
  if (i == clust_num) {
    num_list[[i]] <- paste0(first_iter,":",final_iter)
    next
  }
  num_list[[i]] <- paste0(first_iter,":",last_iter)
  first_iter <- round(first_iter + div_iter, 0) 
  last_iter <- round(last_iter + div_iter, 0)
}

num_list
```

```
## [[1]]
## [1] "1:334"
## 
## [[2]]
## [1] "334:667"
## 
## [[3]]
## [1] "667:1000"
```


``` r
for (i in 1:length(my_clusters)) {
  username <- sub("@.*","",my_clusters[[i]])
  system(sprintf("sed 's/START:END/%s/g' par_test_script.R > par_test_script1.R & scp par_test_script1.R %s:/home/%s/par_test_script1.R",num_list[[i]],my_clusters[[i]],username))
}
```

We'll iterate and insert the appropriate iters for each node and save it to `par_test_script1.R`. Then upload to each nodes with the code above.

#### Check set.seed in multicore

``` r
sample_df <- function(seed, df, n = 6000) {
  set.seed(seed)
  df_sample <- slice_sample(n = n, .data = df)
  return(df_sample)
}

future_lapply(100, function(x) sample_df(seed=x,df=df))
```

When we did the above on local computer and also in terminal with multicore. It's still the same! Woo hoo!

<p align="center">
  <img src="seed1.png" alt="image" width="60%" height="auto">
</p>

<p align="center">
  <img src="seed2.png" alt="image" width="60%" height="auto">
</p>

The interesting thing is I didn't have to set `future.seed = T` or `future.seed = some_number` for this. However, if we put a number on future.seed, it will return the reproducible data! This is great, next time I'll just use this seed and I don't have to use `set.seed(i)`. 🙌 

## Run Rscript {#script}

``` r
for (i in 1:length(my_clusters)) {
  # set your tmux new session name, here we call it "test"
  cluster_name <- "test"
  
  # terminate any existing tmux with the existing name
  system(sprintf("ssh %s 'tmux kill-session -t %s 2>/dev/null || true'", my_clusters[[i]], cluster_name))
  
  # create new tmux session
  system(sprintf("ssh %s 'tmux new-session -d -s %s'", my_clusters[[i]], cluster_name))
  
  # run rscript in tmux
  system(sprintf("ssh %s 'tmux send-keys -t %s \"Rscript par_test_script1.R > result_%d.txt\"' ENTER",
                 my_clusters[[i]], cluster_name, i))
}
```

The code above is quite self-explanatory. Once the above code is run and completed, there we have it! it should be running in the background! 🙌 You can do a spot check and see if it's actually running. Once completed, we'll extract the data.

## Extract Data {#extract}
Since we have 10 combinations we want to assess, we will set nums as 1:10 and get our data! On your template script you can set however you want to save your data, and for extraction, just look for those and download them, read and merge! Or however you want to do it.


``` r
nums <- 1:10
df <- tibble()
for (num in nums) {
  print(num)
for (i in 1:length(my_clusters)) {
  response <- system(sprintf("scp %s:tmle_results/simulation_parameters%d.csv simulation_parameters%d.csv", my_clusters[[i]], num, num), intern = F)
  if (response == 1) { next }
  df_i <- read_csv(paste0("simulation_parameters",num,".csv"), show_col_types = F) 
  sl_i <- df_i |> filter(parameter == "SL_library") |> pull(value)
  df <- rbind(df, df_i |> mutate(method = sl_i, num = num))
}
}

df_sim_param <- df
```




``` r
df <- tibble()
for (num in nums) {
for (i in 1:length(my_clusters)) {
  response <- system(sprintf("scp %s:tmle_results/tmle_iterations%d.csv tmle_iterations%d.csv", my_clusters[[i]], num, num), intern = F)
  if (response == 1) { print(paste0(my_clusters[[i]]," is missing num", num)) ; next }
  df_i <- read_csv(paste0("tmle_iterations",num,".csv"), show_col_types = F) |>
    mutate(num = num)
  df <- rbind(df, df_i)
}
}

df_iter <- df
```

> Take note that sometimes you may encounter issues, if for some reason the node is unable to complete the task, you can identify it then redistribute those tasks to the entire computer cluster.


## Compare Time {#compare}

 

Let's take at our compute time for 1 cluster, 3 cluster with 5-fold cv, 3 cluster with 10-fold cv. 




<table>
 <thead>
  <tr>
   <th style="text-align:left;"> method </th>
   <th style="text-align:right;"> hour_1clus_cv5 </th>
   <th style="text-align:right;"> hour_3clus_cv5 </th>
   <th style="text-align:right;"> hour_3clus_cv10 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.ranger, SL.glm, SL.mean </td>
   <td style="text-align:right;"> 4.02 </td>
   <td style="text-align:right;"> 1.4126466 </td>
   <td style="text-align:right;"> 2.5179200 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.ranger </td>
   <td style="text-align:right;"> 4.00 </td>
   <td style="text-align:right;"> 1.4136567 </td>
   <td style="text-align:right;"> 2.5108584 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.glm </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 0.1680019 </td>
   <td style="text-align:right;"> 0.3034212 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.ranger, c("SL.xgboost", "screen.glmnet") </td>
   <td style="text-align:right;"> 4.23 </td>
   <td style="text-align:right;"> 1.4960542 </td>
   <td style="text-align:right;"> 2.5165429 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.glmnet, SL.glm </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.1074466 </td>
   <td style="text-align:right;"> 0.1995869 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.ranger, SL.glm </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1.2544446 </td>
   <td style="text-align:right;"> 2.2254909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_500_5_0.001, xgb_1000_5_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, SL.glm </td>
   <td style="text-align:right;"> 3.29 </td>
   <td style="text-align:right;"> 1.8059939 </td>
   <td style="text-align:right;"> 3.3030737 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_500_5_0.001, xgb_1000_5_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, SL.glmnet </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1.8956873 </td>
   <td style="text-align:right;"> 3.4821903 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.gam, SL.glm </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.1094693 </td>
   <td style="text-align:right;"> 0.2072266 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_250_3_0.001, xgb_500_3_0.001, xgb_1000_3_0.001, xgb_250_5_0.001, xgb_500_5_0.001, xgb_1000_5_0.001, xgb_250_7_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_250_9_0.001, xgb_500_9_0.001, xgb_1000_9_0.001, xgb_250_3_0.005, xgb_500_3_0.005, xgb_1000_3_0.005, xgb_250_5_0.005, xgb_500_5_0.005, xgb_1000_5_0.005, xgb_250_7_0.005, xgb_500_7_0.005, xgb_1000_7_0.005, xgb_250_9_0.005, xgb_500_9_0.005, xgb_1000_9_0.005, xgb_250_3_0.01, xgb_500_3_0.01, xgb_1000_3_0.01, xgb_250_5_0.01, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_250_7_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, xgb_250_9_0.01, xgb_500_9_0.01, xgb_1000_9_0.01, SL.glm </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4.6127172 </td>
  </tr>
</tbody>
</table>

Looking at the time, we can definitely see the improvement of time from 1 cluster to 3 cluster. Take a look at our good old tuned xgboost and logistic regression, it took use previously for a quadcore 3.29 hours to complete, down to 1.8 hours. You'd imagine that if we use 3 pc's as a cluster, we would notice improvement to ~1.1 hours, but I guess not for xgboost. Will have to investigate this. But if we look at xgboost + logistic regression without tuning, we went from 0.47 hours to 0.17 hours which made sense! Very interesting. Now if we up our CV to 10 fold, then we see that it took longer (makes senses), but still better than using 1 quadcore. I've heard people said that if you increase your K-fold CV, you reduce your bias, but increase variance. Let's see if that's true in our case here.  

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> method </th>
   <th style="text-align:right;"> bias_3clus_cv5 </th>
   <th style="text-align:right;"> bias_3clus_cv10 </th>
   <th style="text-align:right;"> variance_3clus_cv5 </th>
   <th style="text-align:right;"> variance_3clus_cv10 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.ranger, SL.glm, SL.mean </td>
   <td style="text-align:right;"> -0.0007695 </td>
   <td style="text-align:right;"> -0.0007257 </td>
   <td style="text-align:right;"> 0.0001866 </td>
   <td style="text-align:right;"> 0.0001940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.ranger </td>
   <td style="text-align:right;"> -0.0007677 </td>
   <td style="text-align:right;"> -0.0007257 </td>
   <td style="text-align:right;"> 0.0001866 </td>
   <td style="text-align:right;"> 0.0001940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.glm </td>
   <td style="text-align:right;"> -0.0010481 </td>
   <td style="text-align:right;"> 0.0001018 </td>
   <td style="text-align:right;"> 0.0001586 </td>
   <td style="text-align:right;"> 0.0001617 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.ranger, c("SL.xgboost", "screen.glmnet") </td>
   <td style="text-align:right;"> -0.0008349 </td>
   <td style="text-align:right;"> -0.0007257 </td>
   <td style="text-align:right;"> 0.0001868 </td>
   <td style="text-align:right;"> 0.0001940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.glmnet, SL.glm </td>
   <td style="text-align:right;"> -0.0449075 </td>
   <td style="text-align:right;"> -0.0449065 </td>
   <td style="text-align:right;"> 0.0001502 </td>
   <td style="text-align:right;"> 0.0001503 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.ranger, SL.glm </td>
   <td style="text-align:right;"> -0.0007695 </td>
   <td style="text-align:right;"> -0.0007257 </td>
   <td style="text-align:right;"> 0.0001866 </td>
   <td style="text-align:right;"> 0.0001940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_500_5_0.001, xgb_1000_5_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, SL.glm </td>
   <td style="text-align:right;"> 0.0006449 </td>
   <td style="text-align:right;"> 0.0010681 </td>
   <td style="text-align:right;"> 0.0001491 </td>
   <td style="text-align:right;"> 0.0001504 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_500_5_0.001, xgb_1000_5_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, SL.glmnet </td>
   <td style="text-align:right;"> 0.0005986 </td>
   <td style="text-align:right;"> 0.0010492 </td>
   <td style="text-align:right;"> 0.0001502 </td>
   <td style="text-align:right;"> 0.0001511 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.gam, SL.glm </td>
   <td style="text-align:right;"> -0.0062967 </td>
   <td style="text-align:right;"> -0.0062967 </td>
   <td style="text-align:right;"> 0.0001537 </td>
   <td style="text-align:right;"> 0.0001537 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_250_3_0.001, xgb_500_3_0.001, xgb_1000_3_0.001, xgb_250_5_0.001, xgb_500_5_0.001, xgb_1000_5_0.001, xgb_250_7_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_250_9_0.001, xgb_500_9_0.001, xgb_1000_9_0.001, xgb_250_3_0.005, xgb_500_3_0.005, xgb_1000_3_0.005, xgb_250_5_0.005, xgb_500_5_0.005, xgb_1000_5_0.005, xgb_250_7_0.005, xgb_500_7_0.005, xgb_1000_7_0.005, xgb_250_9_0.005, xgb_500_9_0.005, xgb_1000_9_0.005, xgb_250_3_0.01, xgb_500_3_0.01, xgb_1000_3_0.01, xgb_250_5_0.01, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_250_7_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, xgb_250_9_0.01, xgb_500_9_0.01, xgb_1000_9_0.01, SL.glm </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0013250 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0001528 </td>
  </tr>
</tbody>
</table>

Wow, not too shabby! Indeed when we went from cv5 to cv10, we have reduced bias and slightly increased variance! How about that. Everything except gam + lr, which make sense because we don't really tune them. Though that being said, I wonder what's under the hood that controls the knot for gam in superlearner. Will need to check that out. With this, it looks like tuned xgboost + lr might have the best numbers. Well, now we've seen bias and variance, what about coverage?


<table>
 <thead>
  <tr>
   <th style="text-align:left;"> method </th>
   <th style="text-align:right;"> coverage_3clus_cv5 </th>
   <th style="text-align:right;"> coverage_3clus_cv10 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.ranger, SL.glm, SL.mean </td>
   <td style="text-align:right;"> 0.536 </td>
   <td style="text-align:right;"> 0.517 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.ranger </td>
   <td style="text-align:right;"> 0.536 </td>
   <td style="text-align:right;"> 0.517 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.xgboost, SL.glm </td>
   <td style="text-align:right;"> 0.811 </td>
   <td style="text-align:right;"> 0.799 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.ranger, c("SL.xgboost", "screen.glmnet") </td>
   <td style="text-align:right;"> 0.539 </td>
   <td style="text-align:right;"> 0.517 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.glmnet, SL.glm </td>
   <td style="text-align:right;"> 0.051 </td>
   <td style="text-align:right;"> 0.052 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.ranger, SL.glm </td>
   <td style="text-align:right;"> 0.536 </td>
   <td style="text-align:right;"> 0.517 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_500_5_0.001, xgb_1000_5_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, SL.glm </td>
   <td style="text-align:right;"> 0.882 </td>
   <td style="text-align:right;"> 0.878 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_500_5_0.001, xgb_1000_5_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, SL.glmnet </td>
   <td style="text-align:right;"> 0.881 </td>
   <td style="text-align:right;"> 0.876 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SL.gam, SL.glm </td>
   <td style="text-align:right;"> 0.926 </td>
   <td style="text-align:right;"> 0.926 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xgb_250_3_0.001, xgb_500_3_0.001, xgb_1000_3_0.001, xgb_250_5_0.001, xgb_500_5_0.001, xgb_1000_5_0.001, xgb_250_7_0.001, xgb_500_7_0.001, xgb_1000_7_0.001, xgb_250_9_0.001, xgb_500_9_0.001, xgb_1000_9_0.001, xgb_250_3_0.005, xgb_500_3_0.005, xgb_1000_3_0.005, xgb_250_5_0.005, xgb_500_5_0.005, xgb_1000_5_0.005, xgb_250_7_0.005, xgb_500_7_0.005, xgb_1000_7_0.005, xgb_250_9_0.005, xgb_500_9_0.005, xgb_1000_9_0.005, xgb_250_3_0.01, xgb_500_3_0.01, xgb_1000_3_0.01, xgb_250_5_0.01, xgb_500_5_0.01, xgb_1000_5_0.01, xgb_250_7_0.01, xgb_500_7_0.01, xgb_1000_7_0.01, xgb_250_9_0.01, xgb_500_9_0.01, xgb_1000_9_0.01, SL.glm </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.844 </td>
  </tr>
</tbody>
</table>
as not expecting gam + lr to have so much coverage! But looking at bias from the previous table, it's actually quite horrible. So it seems like gam + lr is assymetrical in its estimates, sometimes overestimating, sometimes underestimating, leading to a wider confidence interval, hence more coverage. But that being said, it's not a good estimator because of its bias. Tuned xgboost + glmnet seems to be the best bet here with low bias, low variance and decent coverage.
Wow, I was not expecting gam + lr to have so much coverage! But looking at bias from the previous table, it's actually quite horrible. Let's visualize it!

#### 5-fold CV 
<details>
<summary>code</summary>

``` r
library(tidyverse)

num_df <- sim_param_cv5_clus5 |>
  select(num, method)

df_coverage <- df_iter_cv5_clus3 |>
  group_by(num) |>
  arrange(ate) |>
  mutate(iter = row_number()) |>
  mutate(cover = case_when(
    covers_truth == F & ate < true_ATE ~ "right_missed",
    covers_truth == F & ate > true_ATE ~ "left_missed",
    covers_truth == T ~ "covered"
  )) |>
  select(num, cover) |>
  group_by(num, cover) |>
  tally() |>
  ungroup(cover) |>
  mutate(prop = n*100/sum(n)) |>
  pivot_wider(id_cols = num, names_from = "cover", values_from = "prop") |>
  mutate(text = paste0("right missed: ",right_missed,"% covered: ",covered,"% left missed: ",left_missed,"%")) |>
  select(num, text)

method <- tibble(
  num = c(1:9),
  method = c("xgb + rf + lr + mean","xgb + rf","xgb + lr","rf + (xgb + preprocess w glmnet)","glmnet + lr","rf + lr","tuned xgb + lr","tuned xgb + glmnet","gam + lr")
)

plot <- df_iter_cv5_clus3 |>
  group_by(num) |>
  arrange(ate) |>
  mutate(iter = row_number()) |>
  mutate(cover = case_when(
    covers_truth == F & ate < true_ATE ~ "right_missed",
    covers_truth == F & ate > true_ATE ~ "left_missed",
    covers_truth == T ~ "covered"
  )) |>
  ggplot(aes(x=iter,y=ate,color=cover)) +
  geom_point(alpha=0.2) +
  geom_errorbar(aes(x=iter,ymin=ci_lower,ymax=ci_upper), alpha=0.2) +
  geom_hline(aes(yintercept=0.0373518), color = "blue") +
  geom_text(data = df_coverage,
            aes(x = 500, label = text),
            y = -0.05,  
            inherit.aes = FALSE,
            size = 3,
            hjust = 0.5) +
  scale_color_manual(values = c("covered" = "#619CFF", 
                                  "left_missed" = "#F8766D", 
                                  "right_missed" = "#00BA38")) +
  theme_bw() +
  facet_wrap(.~num, ncol = 1,labeller = as_labeller(setNames(method$method, method$num))) +
  theme(legend.position = "bottom")
```
</details>
<br>
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-19-1.png" width="672" />

`lr`: logistic regression, `xgb`: xgboost, `rf` : random forest, `gam` : generalized additive model.    

Wow, look at gam + lr's assymetrical coverage! This is so true then when we're assessing, a point estimate of coverage is not adequate to assess the global usefulness of a method. We can see that this method is very bias indeed with asymmetrical tails. Since CV5 and CV10 do not have significant difference in coverage, we'll skip the visualization. 



## Opportunities for improvement {#opportunities}
- plenty of opportunities to turn our personal project into a package that will help us
- Use parallel computing on local to run system (such as installation) since this takes a lot of time
- Write function to let us know when tasks are completed
- Write function to estimate time of completion
- Write function to redistribute missing iterations
- learn openMPI
- make a package for the functions above so I can reuse in the future

## Lessons Learnt: {#lesson}
- used more `sprintf` with this learning experience when using with system. 
- learn that in `future_lapply` in multicore `future.seed=100 or whatever number` will help reproduce the same data
- Made a few pipeline to install packages on multiple nodes
- learnt set.seed in multicore works fine
- observed reduced bias with increase variance from cv5 to cv10





If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
