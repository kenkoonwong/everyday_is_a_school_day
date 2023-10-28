library(tidyverse)
library(meta)

meta_compare <- function(control,hr,hr_l,hr_u,df1,df,random=T) {
  
  control <- control
  hr <- hr
  treatment <- hr * control
  absolute_risk_reduction <- treatment - control 
  NNT <- 1/abs(absolute_risk_reduction) 
  
  ## NNT lower
  hr_l <- hr_l
  treatment_l <- hr_l * control
  arr_l <- treatment_l - control
  NNT_l <- ceiling(1/abs(arr_l))
  
  ## NNT upper
  hr_u <- hr_u
  treatment_u <- hr_u * control
  arr_u <- treatment_u - control
  NNT_u <- ceiling(1/abs(arr_u))
  
  nnt_ci_1 <- paste0(round(NNT)," [95%CI ",NNT_l, "-",NNT_u,"]")
  
  metap <- metaprop(event = event.c, n = n.c, data = df1, studlab = study, method.tau = "ML")
  if(random) {te_ran <- meta:::backtransf(metap$TE.random, sm = "PLOGIT")} else {te_ran <- meta:::backtransf(metap$TE.common, sm = "PLOGIT")}
  
  treatment2 <- hr * te_ran
  absolute_risk_reduction <- treatment2 - te_ran 
  NNT2 <- 1/abs(absolute_risk_reduction) # turn negative number to positive
  
  ## NNT lower
  treatment_l2 <- hr_l * te_ran
  arr_l2 <- treatment_l2 - te_ran
  NNT_l2 <- ceiling(1/abs(arr_l2))
  
  ## NNT upper
  treatment_u2 <- hr_u * te_ran
  arr_u2 <- treatment_u2 - te_ran
  NNT_u2 <- ceiling(1/abs(arr_u2))
  
  nnt_ci_2 <- paste0(round(NNT2)," [95%CI ",NNT_l2, "-",NNT_u2,"]")
  
  
  def <- metabin(event.c = event.c,n.c = n.c, event.e = event.t, n.e = n.t, studlab = study,data = df,sm="RR",level = 0.95,comb.fixed=T,comb.random=T,hakn = F)
  
  # new dataframe with newly assigned weights
  weights <- def$w.random / sum(def$w.random)
  
  df_new <-
    df |>
    add_column(weights = weights) |>
    mutate(total_weights = sum(weights),
           log_t = log(event.t/n.t)*weights,
           log_t = case_when(
             is.infinite(log_t) ~ log(0.5/n.t)*weights, # Haldane-Anscombe correction
             TRUE ~ log_t
           )) |>
    mutate(log_c = log(event.c/n.c)*weights,
           log_c = case_when(
             is.infinite(log_c) ~ log(0.5/n.c)*weights,
             TRUE ~ log_c
           )) |>
    drop_na()
  
  total_weights <- sum(df_new$weights)
  
  # average event prop on treatment
  prop_t <- exp(sum(df_new$log_t) / total_weights)
  
  # average event prop control
  prop_c <- exp(sum(df_new$log_c) / total_weights)
  
  # RR random effect?
  rr <- prop_t/prop_c
  
  # arr
  absolute_risk_reduction <- prop_t - prop_c 
  
  # NNT
  NNT3 <- 1/abs(absolute_risk_reduction)
  
  # NNT lower
  var_arr <- prop_t * (1-prop_t) / sum(df_new$n.t) + prop_c * (1-prop_c) / sum(df_new$n.c)
  nnt_l3 <- ceiling(1/abs(absolute_risk_reduction - 1.96*sqrt(var_arr)))
  
  # NNT upper
  nnt_u3 <- ceiling(1/abs(absolute_risk_reduction + 1.96*sqrt(var_arr)))
  
  nnt_ci_3 <- paste0(ceiling(NNT3)," [95%CI ",nnt_l3, "-",nnt_u3,"]")
  
  df_compare <- tibble(method=c("highest_weight","single_prop_pool","full"),prop_control=c(control,te_ran,prop_c),prop_treatment=c(treatment,treatment2,prop_t),nnt=c(nnt_ci_1,nnt_ci_2,nnt_ci_3),tau2=rep(def$tau2,3),I2=rep(def$I,3))
  
  return(df_compare)
}
