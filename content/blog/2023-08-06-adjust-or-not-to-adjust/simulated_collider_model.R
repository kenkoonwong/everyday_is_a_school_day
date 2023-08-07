library(tidyverse)
library(ipw)
library(broom)

# simulate data
{
set.seed(1)
n <- 1000
z <- rnorm(n)
w <- 0.6*z + rnorm(n)
x <- 0.5*z + 0.2*w + rnorm(n)
y <- 0.5*x + 0.4*w + rnorm(n)  
collider <- -0.4*x + -0.4*y + rnorm(n)  

df <- tibble(z=z,w=w,y=y,x=x, collider=collider)
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

# create empty df of models
df_model <- tibble(formula=as.character(),estimate=as.numeric(),lower=as.numeric(),upper=as.numeric(),bic=as.numeric())
  
# for loop all models and get estimate and se
for (i in m_all) {
  formula <- as.formula(i)
  model <- lm(formula=formula,data=df)
  now_model <- model |> tidy() |> filter(term == "x")
  bic <- BIC(model)
  sd <- confint(model)
  df_model <- df_model |>
    add_row(tibble(formula=i,estimate=now_model$estimate,lower=sd[2,1],upper=sd[2,2],bic=bic))
}

# save all model info
save(df_model, file = "df_model.rda")
