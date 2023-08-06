library(tidyverse)
library(ipw)
library(broom)

# simulate data
{
set.seed(1)
n <- 100
z <- rnorm(n)
w <- 0.6*z + rnorm(n)
x <- 0.5*z + 0.2*w + rnorm(n)
y <- 0.5*x + 0.4*w  
collider <- -0.4*x + -0.4*y  

x1=ifelse(x>mean(x),1,0)
y1=ifelse(y>mean(y),1,0)

# correctly adjust z
df <- tibble(z=z,w=w,y=y1,x=x1, collider=collider)
}

# all models
m1 <- "y~x"
m2 <- "y~x+w"
m2_2 <- "y~x+z"
m3 <- "y~x+z+w"
m4 <- "y~x+z+w+collider"
m5 <- "y~x+z+collider"
m6 <- "y~x+w+collider"
m7 <- "y~x+collider"

# combine all models to a vector
m_all <- c(m1,m2,m2_2,m3,m4,m5,m6,m7)

# creating list of formulae
m_all_formula <- map(m_all, as.formula)

# create empty df of models
df_model <- tibble(formula=as.character(),estimate=as.numeric(),lower=as.numeric(),upper=as.numeric(),aic=as.numeric(),bic=as.numeric())
  
# for loop all models and get estimate and se
for (i in m_all) {
  formula <- as.formula(i)
  model <- glm(formula=formula,data=df)
  now_model <- model |> tidy() |> filter(term == "x")
  bic <- BIC(model)
  sd <- confint(model)
  df_model <- df_model |>
    add_row(tibble(formula=i,estimate=now_model$estimate,lower=sd[2,1],upper=sd[2,2],aic=model$aic,bic=bic))
}

# save all model info
save(df_model, file = "df_model.rda")
