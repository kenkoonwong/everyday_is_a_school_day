---
title: What Happens If Our Model Adjustment Includes A Collider?
author: Ken Koon Wong
date: '2023-08-06'
slug: collider_adjustment
categories: 
- r
- R
- collider
- v structure
- adjust
- adjustment
- dag
- causality
tags: 
- r
- R
- collider
- v structure
- adjust
- adjustment
- dag
- causality
excerpt: "Beware of what we adjust. As we have demonstrated, adjusting for a collider variable can lead to a false estimate in your analysis. If a collider is included in your model, relying solely on AIC/BIC for model selection may provide misleading results and give you a false sense of achievement."
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

> Beware of what we adjust. As we have demonstrated, adjusting for a collider variable can lead to a false estimate in your analysis. If a collider is included in your model, relying solely on AIC/BIC for model selection may provide misleading results and give you a false sense of achievement.

<br>

![](feature.jpg)

### Let’s DAG out The True Causal Model

``` r
# Loading libraries
library(ipw)
library(tidyverse)
library(dagitty)
library(DT)

# Creating the actual/known DAG
dag2 <- dagitty('dag {
bb="0,0,1,1"
W [adjusted,pos="0.422,0.723"]
X [exposure,pos="0.234,0.502"]
Y [outcome,pos="0.486,0.498"]
Z [pos="0.232,0.264"]
collider [pos="0.181,0.767"]
W -> X
W -> Y
X -> Y
X -> collider
Y -> collider
Z -> W
Z -> X
}
')

plot(dag2)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-1-1.png" width="672" />

X: Treatment/Exposure variable/node.  
Y: Outcome variable/node.  
Z: Something… not sure what this is called 🤣.  
W: Confounder.  
collider: Collider, V-structure.

<br>

Let’s find out what is our minimal adjustment for total effect

``` r
adjust <- adjustmentSets(dag2)
adjust
```

    ## { W }

Perfect! We only need to adjust W. Now we know which node is correct to adjust, let’s simulate data!

``` r
set.seed(1)

# set number of observations
n <- 100
z <- rnorm(n)
w <- 0.6*z + rnorm(n)
x <- 0.5*z + 0.2*w + rnorm(n)
y <- 0.5*x + 0.4*w  
collider <- -0.4*x + -0.4*y  

# turning y and x into binary/categorical
x1=ifelse(x>mean(x),1,0)
y1=ifelse(y>mean(y),1,0)

# create a dataframe for the simulated data
df <- tibble(z=z,w=w,y=y1,x=x1, collider=collider)

datatable(df)
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-1" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100"],[-0.626453810742332,0.183643324222082,-0.835628612410047,1.59528080213779,0.329507771815361,-0.820468384118015,0.487429052428485,0.738324705129217,0.575781351653492,-0.305388387156356,1.51178116845085,0.389843236411431,-0.621240580541804,-2.2146998871775,1.12493091814311,-0.0449336090152309,-0.0161902630989461,0.943836210685299,0.821221195098089,0.593901321217509,0.918977371608218,0.782136300731067,0.0745649833651906,-1.98935169586337,0.61982574789471,-0.0561287395290008,-0.155795506705329,-1.47075238389927,-0.47815005510862,0.417941560199702,1.35867955152904,-0.102787727342996,0.387671611559369,-0.0538050405829051,-1.37705955682861,-0.41499456329968,-0.394289953710349,-0.0593133967111857,1.10002537198388,0.763175748457544,-0.164523596253587,-0.253361680136508,0.696963375404737,0.556663198673657,-0.68875569454952,-0.70749515696212,0.36458196213683,0.768532924515416,-0.112346212150228,0.881107726454215,0.398105880367068,-0.612026393250771,0.341119691424425,-1.12936309608079,1.43302370170104,1.98039989850586,-0.367221476466509,-1.04413462631653,0.569719627442413,-0.135054603880824,2.40161776050478,-0.0392400027331692,0.689739362450777,0.0280021587806661,-0.743273208882405,0.188792299514343,-1.80495862889104,1.46555486156289,0.153253338211898,2.17261167036215,0.475509528899663,-0.709946430921815,0.610726353489055,-0.934097631644252,-1.2536334002391,0.291446235517463,-0.443291873218433,0.00110535163162413,0.0743413241516641,-0.589520946188072,-0.568668732818502,-0.135178615123832,1.1780869965732,-1.52356680042976,0.593946187628422,0.332950371213518,1.06309983727636,-0.304183923634301,0.370018809916288,0.267098790772231,-0.54252003099165,1.20786780598317,1.16040261569495,0.700213649514998,1.58683345454085,0.558486425565304,-1.27659220845804,-0.573265414236886,-1.22461261489836,-0.473400636439312],[-0.996238963669524,0.152301867677485,-1.41229881599847,1.11519725368675,-0.456879980829601,1.27500623890184,1.0091649074743,1.35316905257276,0.72965416881844,1.4989430482256,0.271332247121532,-0.227738788513707,1.05953789021658,-1.97951628561687,0.467577807283899,-0.419768094851122,-0.329707026407874,0.287188423434621,0.98692104832668,0.179010310460899,0.0454289608506735,1.81232060560905,-0.169840418527754,-1.37316754756141,0.271704707523264,0.678989063334005,-0.167041708149524,-0.920085601806613,-0.968550511820829,-0.0735053361264976,0.875368171351942,-0.650567122665461,0.764099159568194,-1.55067710613653,-0.519677873307398,-1.78544656151739,-0.53755009906282,-0.563867942471718,0.00792044250933099,0.401008671227134,-2.01307358343216,1.02456630393666,-1.24679441096916,-0.129532482268191,-1.52917352177256,-1.17531609537072,2.30591572291044,0.478515374402501,-1.35370825772446,-1.11194089854605,0.689050629492896,-0.385775668665101,-0.11339655968919,-1.60698000510218,-0.627646089120863,0.113047642487835,0.779695917834009,-1.24774747058674,-1.04259507091904,1.78825786009509,1.86607103367531,-0.262191102552934,1.47232666617949,0.903223946643336,-1.06520697356059,2.31937784424907,-1.33800220747564,-0.545161733275077,-0.0524475990270808,1.51110534144964,2.59328411639916,-0.320165490659377,0.823434617516847,-0.637611514343082,-1.08618088251001,0.140141712999202,0.521664481699102,2.07590821963126,1.07199723325477,0.854195830673861,-1.57252466124915,0.90278840097908,0.926777001604574,-2.3813901093501,0.877390455225192,0.041015618012095,2.10244721433561,-0.948592353785245,-0.208200467978774,-0.765850222914099,-0.50261598003153,1.12673246307624,-0.0355066037026355,1.25050135769067,-0.255982713579958,-0.712892557468559,0.675202381769459,-1.35980671384678,-0.322792856621499,-0.665116432972507],[0,1,0,1,0,1,1,1,1,1,1,1,1,0,1,1,0,0,1,1,0,1,0,0,0,1,0,0,0,1,1,0,1,0,0,0,0,0,1,1,0,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,0,0,0,1,1,0,1,1,1,1,0,0,0,1,1,0,1,1,0,1,0,1,0,1,0,1,1,0,1,0,1,0,1,1,0,1,1,1,1,0,1,0,0,0],[0,1,1,1,0,1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,1,1,1,1,1,0,1,0,1,1,0,1,1,0,0,0,1,1,0,0,1,0,1,0,1,1,1,1,0,0,0,1,1,0,0,1,0,1,0,1,0,1,0,0,1,0,0,0,1,1,1,1,0,1,1,0,1,1,1,1,0,0],[0.221241949259606,-1.11106149193875,-0.305820807862595,-0.592294791263968,1.40021538426316,-1.60945818555761,-0.829034589880645,-0.925181147837357,-0.368997858877666,-0.634152591128018,-0.430881880667483,-0.305602896092299,0.129849611288485,2.04079925265445,-1.06110402195535,-0.780831866036844,0.282419387859257,0.388410231597331,-0.908049035467591,-0.201467801157917,0.751517723574249,-0.743369775598016,0.403366022535102,1.18587356999245,0.431918375106585,-1.2551634606253,0.292189552128198,1.66215773102748,0.29632309659873,-0.262706361787776,-0.0612109331916824,1.94634751555695,0.0540397733921639,0.108026520340809,0.59446163720022,0.683330652617915,-0.0676914233213752,0.887552226053121,-0.990291562062323,-0.338028735513961,0.188631281798235,-0.831334701903789,0.00592517350076116,0.396494703152608,-0.0629834391192262,1.74143602066372,-0.428156547054939,-0.211141756693132,0.512414797866922,-0.565267211613835,-0.394099076229798,0.0473245431471577,-0.0287919829066115,0.937361935224446,-0.671496689528254,-1.31351032377783,1.33370931488155,0.318965946511743,-0.103823912442584,-0.205035186728731,-1.81359290212661,0.3187278185658,-0.448574878185745,-0.775749219542216,-0.510536464210674,-0.868096426806381,1.16943861263307,0.426446803763907,0.167329113591419,-0.510995400808531,-0.713412861390392,0.0660027657282267,0.0973346562628845,-1.13073961514759,0.586613661775485,-0.804797910767981,1.36039589499384,-1.0261866013035,0.467285473714103,-0.614200755297744,0.372029431724138,0.0322899798248705,-1.40747883752761,1.54459827229511,-0.0754846012072584,0.489273824207809,-0.506708007144845,-0.210249935873691,-0.312930801667927,-0.468787105421948,0.537559682138531,-0.903667606521088,-0.484677890363644,0.295549930421635,-1.47143244904514,-0.0486046081386002,-0.265438403852756,-0.0203565019972245,0.488105205188889,0.511742044024278]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>z<\/th>\n      <th>w<\/th>\n      <th>y<\/th>\n      <th>x<\/th>\n      <th>collider<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>

The reason we converted `x` and `y` into binary variables was to replicate a question that is often encountered in our research. In many cases, both the treatment and outcome are binary. Hence, the transformation. However, it is possible to keep the variables as they are and use linear regression instead of logistic regression, which I’ll be using shortly. Additionally, I used the `mean` to binarize both variables into `1` or `0` because they were approximately normally distributed, and I wanted to balance them. You can experiment with different threshold values if needed.

<br>

### Simple Model (y \~ x)

``` r
model_c <- glm(y~x, data=df)
summary(model_c)
```

    ## 
    ## Call:
    ## glm(formula = y ~ x, data = df)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -0.8148  -0.1739   0.1852   0.1852   0.8261  
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.17391    0.05721   3.040  0.00304 ** 
    ## x            0.64090    0.07786   8.232 8.11e-13 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for gaussian family taken to be 0.15058)
    ## 
    ##     Null deviance: 24.960  on 99  degrees of freedom
    ## Residual deviance: 14.757  on 98  degrees of freedom
    ## AIC: 98.441
    ## 
    ## Number of Fisher Scoring iterations: 2

Note that our true `x` `coefficient` is `0.5`. Our current naive model shows 0.6409018

### Correct Model (y \~ x + w) ✅

``` r
model_cz <- glm(y~x + w, data=df)
summary(model_cz) 
```

    ## 
    ## Call:
    ## glm(formula = y ~ x + w, data = df)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -0.6073  -0.2124  -0.0082   0.2211   0.5647  
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.25054    0.04420   5.668 1.48e-07 ***
    ## x            0.48667    0.06158   7.903 4.32e-12 ***
    ## w            0.24174    0.02808   8.609 1.34e-13 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for gaussian family taken to be 0.08623743)
    ## 
    ##     Null deviance: 24.960  on 99  degrees of freedom
    ## Residual deviance:  8.365  on 97  degrees of freedom
    ## AIC: 43.677
    ## 
    ## Number of Fisher Scoring iterations: 2

Wow, even the correct model models `x` coefficient of 0.4866734. Not bad with an `n` of 100

### Alright, What About Everything Including Collider (y \~ x + z + w + collider) ❌

``` r
model_czwall <- glm(y~x + z + w + collider, data=df)
summary(model_czwall)  
```

    ## 
    ## Call:
    ## glm(formula = y ~ x + z + w + collider, data = df)
    ## 
    ## Deviance Residuals: 
    ##      Min        1Q    Median        3Q       Max  
    ## -0.53681  -0.23608  -0.00639   0.20049   0.50698  
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.354932   0.054370   6.528 3.25e-09 ***
    ## x            0.273625   0.090835   3.012  0.00332 ** 
    ## z            0.004099   0.039375   0.104  0.91731    
    ## w            0.192690   0.032518   5.926 4.97e-08 ***
    ## collider    -0.198703   0.066765  -2.976  0.00370 ** 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for gaussian family taken to be 0.07997983)
    ## 
    ##     Null deviance: 24.9600  on 99  degrees of freedom
    ## Residual deviance:  7.5981  on 95  degrees of freedom
    ## AIC: 38.06
    ## 
    ## Number of Fisher Scoring iterations: 2

😱 `x` is now 0.2736252. Not good!

### Let’s Visualize All Models

``` r
load("df_model.rda")

df_model |>
  mutate(color = case_when(
    str_detect(formula, "collider") ~ 1,
    TRUE ~ 0
  )) |>
  ggplot(aes(x=formula,y=estimate,ymin=lower,ymax=upper)) +
  geom_point(aes(color=as.factor(color))) +
  geom_linerange(aes(color=as.factor(color))) +
  scale_color_manual(values = c("grey","red")) +
  coord_flip() +
  geom_hline(yintercept = 0.5) +
  theme_minimal() +
  theme(legend.position = "none") 
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="672" />

The red lines represent models with colliders adjusted. It’s important to observe that none of these models contain the true value within their 95% confidence intervals. Adjusting for colliders can lead to biased estimates, particularly when the colliders directly affect both the treatment and outcome variables. Careful consideration should be given to the inclusion of colliders in the analysis to avoid potential distortions in the results.”

<br>

### Let’s check IPW

``` r
ipw <- ipwpoint(
  exposure = x,
  family = "binomial",
  link = "logit",
  denominator = ~ w,
  data = as.data.frame(df))

model_cipw <- glm(y ~ x, data = df |> mutate(ipw=ipw$ipw.weights), weights = ipw)
summary(model_cipw)
```

    ## 
    ## Call:
    ## glm(formula = y ~ x, data = mutate(df, ipw = ipw$ipw.weights), 
    ##     weights = ipw)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -1.3954  -0.3649   0.3050   0.3581   1.5342  
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.25974    0.06371   4.077 9.29e-05 ***
    ## x            0.46462    0.08946   5.194 1.12e-06 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for gaussian family taken to be 0.3980486)
    ## 
    ##     Null deviance: 49.746  on 99  degrees of freedom
    ## Residual deviance: 39.009  on 98  degrees of freedom
    ## AIC: 131.05
    ## 
    ## Number of Fisher Scoring iterations: 2

`x` is now 0.4646218. Quite similar to before. What if we just try a collider?

``` r
ipw <- ipwpoint(
  exposure = x,
  family = "binomial",
  link = "logit",
  denominator = ~ collider,
  data = as.data.frame(df))

model_cipw2 <- glm(y ~ x, data = df |> mutate(ipw=ipw$ipw.weights), weights = ipw)
summary(model_cipw2)
```

    ## 
    ## Call:
    ## glm(formula = y ~ x, data = mutate(df, ipw = ipw$ipw.weights), 
    ##     weights = ipw)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -1.9717  -0.3421   0.3829   0.3835   1.9563  
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.34073    0.07161   4.758 6.73e-06 ***
    ## x            0.27633    0.09741   2.837  0.00554 ** 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for gaussian family taken to be 0.315229)
    ## 
    ##     Null deviance: 33.429  on 99  degrees of freedom
    ## Residual deviance: 30.892  on 98  degrees of freedom
    ## AIC: 156.91
    ## 
    ## Number of Fisher Scoring iterations: 2

Youza! `x` is now 0.2763335 with `collider`. NOT GOOD !!!

Some clinical examples of adjusting for colliders that lead to d-connection include situations where the treatment and outcome have a common cause that is also adjusted for, such as when the outcome is mortality and the collider is the recurrence of a medical condition. In this scenario, adjusting for the common cause (recurrence of the condition) could lead to d-connection because both the treatment and mortality can directly affect the recurrence of the medical condition (where recurrence would likely decrease when mortality occurs).”

<br>

### What If We Just Use Stepwise Regression?

``` r
datatable(df_model |> select(formula,aic,bic), 
          options = list(order = list(list(2,"asc"))))
```

<div class="datatables html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-2" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8"],["y~x","y~x+w","y~x+z","y~x+z+w","y~x+z+w+collider","y~x+z+collider","y~x+w+collider","y~x+collider"],[98.4413842061163,43.6766908669759,88.3845405451404,44.9747167280328,38.0603026532588,67.5128947315415,36.0717095720958,68.1296300154782],[106.256894764081,54.0973716109283,98.8052212890928,58.0005676579732,53.6913237691874,80.538745661482,49.0975605020363,78.5503107594306]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>formula<\/th>\n      <th>aic<\/th>\n      <th>bic<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"order":[[2,"asc"]],"columnDefs":[{"className":"dt-right","targets":[2,3]},{"orderable":false,"targets":0}],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>

Wow, when sorted in ascending order, the first 2 lowest AIC values are associated with models that include colliders! This is surprising! It highlights the importance of caution when using stepwise regression or automated model selection techniques, especially if you are uncertain about the underlying causal model. Blindly relying on these methods without understanding the causal relationships can lead to misleading results.

<br>

### Lessons learnt

- Having a well-defined Causal Estimand is crucial! It requires careful consideration of the clinical context and the specific question you want to address.
- Blindly adjusting for all available variables can be dangerous, as it may lead to spurious correlations. Selecting variables to adjust for should be guided by domain knowledge and causal reasoning.
- If you’re interested in accessing the code for all of the models [click here](simulated_collider_model.R)

<br>

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
