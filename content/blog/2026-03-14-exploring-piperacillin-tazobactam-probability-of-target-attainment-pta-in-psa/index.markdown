---
title: Exploring Piperacillin/Tazobactam Probability of Target Attainment (PTA) in
  Pseudomonas
author: Ken Koon Wong
date: '2026-03-15'
slug: piptazo-psa
categories: 
- pkpd
- poppk
- piptazo
- pseudomonas
- r
- R
- pta
- mic
tags: 
- pkpd
- poppk
- piptazo
- pseudomonas
- r
- R
- pta
- mic
excerpt: "Exploring pip/tazo PTA for Pseudomonas using popPK simulation. Key finds: 30-min infusions fall short of 90% PTA at MIC 16; prolonged infusion helps, but neutropenic fever population sees the biggest drop in PTA. ~46% of susceptible PsA isolates carry blaOXA-2 — tazobactam matters more than I thought"
---

> Exploring pip/tazo PTA for Pseudomonas using popPK simulation. Key finds: 30-min infusions fall short of 90% PTA at MIC 16; prolonged infusion helps, but neutropenic fever population sees the biggest drop in PTA. ~46% of susceptible PsA isolates carry blaOXA-2 — tazobactam matters more than I thought

## Motivations 
We've learnt a bit of PK/PD last time, [here](https://www.kenkoonwong.com/blog/pkpd/). Let's apply that on Pip/tazo and Pseudomonas. An [FDA statement](https://www.fda.gov/drugs/development-resources/fda-rationale-piperacillin-tazobactam-breakpoints-pseudomonas-aeruginosa) Feb 2024 detailed that for susceptible dose dependent (SDD) breakpoint of 16 mcg/mL, we should utilize 4.5 g q6h over 3-hour infusion because the standard dosing of 4.5g IV every 6 hours over 0.5 hours do not adequate achieve > 90% PTA. There is also a mention on the limitation where the fT > mic of 50% was used to calculate PTA, which was not adequately validated for PsA. This is a great opportunity for us to take a look at this, now that we have a better understanding of what PTA and fT>mic mean from a data structure standpoint! 

First, we'll obtain the population PK parameters, make a model, and then perform the simulation, and visualize the PTA. We'll be exploring [A Pooled Pharmacokinetic Analysis for Piperacillin/Tazobactam Across Different Patient Populations: From Premature Infants to the Elderly](https://link.springer.com/article/10.1007/s40262-024-01460-6). This model is more sophisticated than the previous one as it's a pooled popPK model. We'll then compare the PTA of the recommended dosing and infusion time, compared to standard dosing of 30 mins. And then look at some maximum amount of fT>mic used in the literature, and then explore the PTA given the threshold of fT>mic. Also, a curious question is, why do we need tazobactam for pseudomonas when piperacillin itself has activity against it? Could it be because of co-resistance of beta lactamase? Let's take a look at all pseudomonas isolate that is pip/tazo susceptible and check for proportion of these beta lactamase genes in NCBI.

#### Disclaimer:
*This is purely for educational purposes. Not a medical advice. If you find something wrong, please let me know so I can correct and continue to learn.*

## Objectives:
- [Piptazo model](#model)
- [Probability of Target Attaintment](#pta)
- [Proportion of PsA in NCBI that would benefit from tazobactam](#gene)
- [Final thought](#final)
- [Oppotunities For Improvement](#opportunities)
- [Lessons Learnt](#lessons)

## Piptazo Model {#model}
<details>
<summary>LLM code</summary>

``` r
library(mrgsolve)
library(tidyverse)

mod <- mcode(model = "piptazo", code = '
$PARAM
// --- Fixed effects (Table 3) ---
// Piperacillin
theta_V1_PIP  = 10.4,   // L/70kg
theta_CL_PIP  = 10.6,   // L/h/70kg
theta_V2_PIP  = 11.6,   // L/70kg
theta_Q2_PIP  = 15.2,   // L/h/70kg

// Tazobactam
theta_V1_TAZ  = 10.5,   // L/70kg
theta_CL_TAZ  = 9.58,   // L/h/70kg
theta_V2_TAZ  = 13.7,   // L/70kg
theta_Q2_TAZ  = 16.8,   // L/h/70kg

// Shared maturation-decline parameters
MAT50_wk      = 54.2,   // weeks PMA at 50% maturation (shared)
gamma1        = 3.35,   // shape: maturation
DEC50_PIP_yr  = 89.1,   // years PMA at 50% decline, PIP
DEC50_TAZ_yr  = 61.6,   // years PMA at 50% decline, TAZ
gamma2        = 1.92,   // shape: decline (shared)

// SCR effect on CL (shared PIP+TAZ, Eq. 4)
theta_SCR     = 0.346,  // dL/mg

// Protein binding / DBS corrections (Eqs. 23-25)
fUNB_PIP      = 0.645,  // fraction unbound piperacillin
fDBS_PIP      = 0.368,  // DBS:plasma ratio PIP
fDBS_TAZ      = 0.448,  // DBS:plasma ratio TAZ

// Study-specific corrections (Eqs. 21-22)
// Set to 1.0 for general non-Sime use; 1.73 for Sime et al. CL, 0.512 for Sime et al. V2
theta_CL_Sime = 1.0,
theta_V2_Sime = 1.0,

// Patient covariates (defaults: 70kg, 35yr, SCR 0.83 mg/dL reference adult)
TBW           = 70,     // kg
PMA_yr        = 35,     // postmenstrual age, years
SCR           = 0.83    // serum creatinine, mg/dL

$CMT CENT_PIP PERI_PIP CENT_TAZ PERI_TAZ

$MAIN
// --- Eq. 16: Size scaling relative to 70kg reference ---
double FSIZE = TBW / 70.0;

// --- Eq. 17: Maturation function (PMA in weeks) ---
double PMA_wk = PMA_yr * 52.1775;
double FMAT = pow(PMA_wk, gamma1) /
              (pow(PMA_wk, gamma1) + pow(MAT50_wk, gamma1));

// --- Eqs. 18-19: Decline functions (PMA in years) ---
double FDEC_PIP = 1.0 - pow(PMA_yr, gamma2) /
                        (pow(PMA_yr, gamma2) + pow(DEC50_PIP_yr, gamma2));

double FDEC_TAZ = 1.0 - pow(PMA_yr, gamma2) /
                        (pow(PMA_yr, gamma2) + pow(DEC50_TAZ_yr, gamma2));

// --- Eq. 20: Standardised SCR (Colin et al. equation) ---
double SCR_std = exp(1.42 - (1.17 + 0.203 * log(PMA_yr / 100.0)) /
                             sqrt(PMA_yr / 100.0));

// --- Eq. 4: SCR effect on CL (shared for PIP and TAZ) ---
double FSCR = exp(-theta_SCR * (SCR - SCR_std));

// --- Individual PK parameters ---
// ETA index key (Table 3 / Eqs. 6-14):
//   ETA(1) = V1  (shared PIP + TAZ)
//   ETA(2) = CL_PIP
//   ETA(3) = CL_TAZ
//   ETA(4) = V2  (shared PIP + TAZ)
//   ETA(5) = Q2  (shared PIP + TAZ)

// PIP (Eqs. 6-9)
double V1_PIP = theta_V1_PIP * FSIZE * exp(ETA(1));
double CL_PIP = theta_CL_PIP * pow(FSIZE, 0.75) * FMAT * FDEC_PIP * FSCR
                * theta_CL_Sime * exp(ETA(2));
double V2_PIP = theta_V2_PIP * FSIZE * theta_V2_Sime * exp(ETA(4));

// Eq. 9: compartmental allometry for Q2_PIP
// Q2_i ∝ (V2_i_individual / V2_i_typical)^0.75
double Q2_PIP = theta_Q2_PIP *
                pow(V2_PIP / (theta_V2_PIP * FSIZE * theta_V2_Sime), 0.75) *
                exp(ETA(5));

// TAZ (Eqs. 11-14)
double V1_TAZ = theta_V1_TAZ * FSIZE * exp(ETA(1));
double CL_TAZ = theta_CL_TAZ * pow(FSIZE, 0.75) * FMAT * FDEC_TAZ * FSCR
                * exp(ETA(3));
double V2_TAZ = theta_V2_TAZ * FSIZE * exp(ETA(4));

// Eq. 14: compartmental allometry for Q2_TAZ
double Q2_TAZ = theta_Q2_TAZ *
                pow(V2_TAZ / (theta_V2_TAZ * FSIZE), 0.75) *
                exp(ETA(5));

$OMEGA
// ETA(1): IIV V1 shared PIP+TAZ [42.6% CV -> omega2 = log(0.426^2 + 1)]
0.1537

$OMEGA
// ETA(2): IIV CL_PIP [43.2%]
0.1598

$OMEGA
// ETA(3): IIV CL_TAZ [41.5%]
0.1480

$OMEGA
// ETA(4): IIV V2 shared PIP+TAZ [85.4%]
0.5218

$OMEGA
// ETA(5): IIV Q2 shared PIP+TAZ [65.6%]
0.3598

$SIGMA
// EPS(1): PIP proportional error [30.2% -> sigma = 0.302^2]
0.0912

// EPS(2): PIP additive error [0.147 mg/L -> sigma = 0.147^2]
0.0216

// EPS(3): TAZ proportional error [28.5% -> sigma = 0.285^2]
0.0812

// EPS(4): TAZ additive error [0 FIX per Table 3]
0.0000

$ODE
dxdt_CENT_PIP = -(CL_PIP / V1_PIP) * CENT_PIP
                - (Q2_PIP / V1_PIP) * CENT_PIP
                + (Q2_PIP / V2_PIP) * PERI_PIP;

dxdt_PERI_PIP =  (Q2_PIP / V1_PIP) * CENT_PIP
                - (Q2_PIP / V2_PIP) * PERI_PIP;

dxdt_CENT_TAZ = -(CL_TAZ / V1_TAZ) * CENT_TAZ
                - (Q2_TAZ / V1_TAZ) * CENT_TAZ
                + (Q2_TAZ / V2_TAZ) * PERI_TAZ;

dxdt_PERI_TAZ =  (Q2_TAZ / V1_TAZ) * CENT_TAZ
                - (Q2_TAZ / V2_TAZ) * PERI_TAZ;

$TABLE
// Eq. 10: PIP total plasma (proportional + additive error, Table 3)
double Cp_PIP_total   = (CENT_PIP / V1_PIP) * (1.0 + EPS(1)) + EPS(2);

// PD-relevant: unbound PIP (Eq. 23: fUNB = 0.645 for non-Sukarnjanaset)
// No residual error on this — it is derived deterministically for simulation
double Cp_PIP_unbound = fUNB_PIP * (CENT_PIP / V1_PIP);

// Eq. 15: TAZ total plasma (proportional + additive error; additive = 0 FIX)
double Cp_TAZ_total   = (CENT_TAZ / V1_TAZ) * (1.0 + EPS(3)) + EPS(4);

// DBS concentrations (Eqs. 24-25), applied to total plasma
double Cp_PIP_DBS = fDBS_PIP * (CENT_PIP / V1_PIP);
double Cp_TAZ_DBS = fDBS_TAZ * (CENT_TAZ / V1_TAZ);

$CAPTURE
Cp_PIP_total Cp_PIP_unbound Cp_TAZ_total
Cp_PIP_DBS Cp_TAZ_DBS
V1_PIP CL_PIP V2_PIP Q2_PIP
V1_TAZ CL_TAZ V2_TAZ Q2_TAZ
FSIZE FMAT FDEC_PIP FDEC_TAZ FSCR SCR_std
')
```
</details>

Explaination: 
- $PARAM: the parameters of the model, which include the fixed effects (theta) and the patient covariates (TBW, PMA_yr, SCR). The fixed effects are the typical values of the PK parameters for a 70kg, 35yr, SCR 0.83 mg/dL reference adult. The patient covariates are the total body weight (TBW), postmenstrual age in years (PMA_yr), and serum creatinine (SCR).
- $CMT: the compartments of the model, which include the central and peripheral compartments for both piperacillin (CENT_PIP, PERI_PIP) and tazobactam (CENT_TAZ, PERI_TAZ).
- $MAIN: the main block where the individual PK parameters are calculated based on the fixed effects and the patient covariates. This includes size scaling (FSIZE), maturation function (FMAT), decline functions (FDEC_PIP and FDEC_TAZ), standardized SCR (SCR_std), and then the individual PK parameters for piperacillin (V1_PIP, CL_PIP, V2_PIP, Q2_PIP) and tazobactam (V1_TAZ, CL_TAZ, V2_TAZ, Q2_TAZ).
- $OMEGA: the inter-individual variability (IIV) for the PK parameters, which are assumed to be log-normally distributed. The values are derived from the coefficients of variation (CV) reported in Table 3 of the paper.
- $SIGMA: the residual unexplained variability (RUV) for the observed concentrations, which include proportional and additive error for both piperacillin and tazobactam.
- $ODE: the ordinary differential equations that describe the change in drug amount in each compartment over time, based on the PK parameters.
- $TABLE: the block where the output variables are defined, including the total plasma concentrations of piperacillin and tazobactam (with error), the unbound piperacillin concentration (which is relevant for PD), and the DBS concentrations.


Alright, the above was LLM generated, including the model! It's quite good, but we have to verify it and recode from ground up and see if we understand it. The nice thing about this is that at least we have notes to compare and refer if we hit a road block. You can see mine below and I found starting from \$MAIN is helpful and just add all the \$PARAM and other equations as we build the model is very helpful! Also, we found out that the `CRstd` is from [here](https://link.springer.com/article/10.1007/s40262-018-0727-5) and the equation is a bit different from the paper. We also found that the back-calculated IIV values were a bit different. But it's a great draft overall! And we also noticed that there will be adjustments if we need to simualate neutropenic fever [Sime et al](https://pubmed.ncbi.nlm.nih.gov/24687508/) or critically ill during early sepsis[Sukarnjanaset et al](https://pubmed.ncbi.nlm.nih.gov/30963365/). We'll look at that in a bit.

<details>
<summary>my code</summary>

``` r
mod <- mcode(model = "piptazo_ken", code = '
$PARAM
theta_v1_pip = 10.4,
tbw = 70,
theta_cl_pip = 10.6, 
pma_year = 35,
gamma1 = 3.35,
gamma2 = 1.92,
scr = 0.82,
theta_scr = 0.346,
dec50_pip = 89.1,
theta_cl_sime = 1,
theta_v2_sime = 1,
funb_pip = 0.645,
fdbs_pip = 1,    // we are assuming we dont use dried bld sample
theta_v2_pip = 11.6,
theta_q2_pip = 15.2,
mat50 = 54.2


$CMT CENT_PIP PERI_PIP 

$MAIN
double fsize = tbw / 70;
double pma_week = pma_year * 52.17;
double fmat = pow(pma_week,gamma1) / (pow(pma_week,gamma1) + pow(mat50,gamma1));
double fdec_pip = 1 - (pow(pma_year, gamma2) / (pow(pma_year, gamma2) + pow(dec50_pip, gamma2)));
double scrstd = exp(1.42 - (1.17 + 0.203 * log(pma_year / 100.0)) / sqrt(pma_year / 100.0));
double fscr = exp(-theta_scr*(scr-scrstd));

double v1_pip = theta_v1_pip * fsize * exp(ETA(1));
double cl_pip = theta_cl_pip * pow(fsize, 0.75) * fmat * fdec_pip * fscr * theta_cl_sime * exp(ETA(2));
double v2_pip = theta_v2_pip * fsize * theta_v2_sime * exp(ETA(4));
double q2_pip = theta_q2_pip * pow(v2_pip/theta_v2_pip, 0.75) * exp(ETA(5));

$OMEGA
0.1667645 
0.1711123
0.1589037   // IIV CL for tazo ETA(3)
0.547726
0.3579094

$ODE
dxdt_CENT_PIP = -(cl_pip/v1_pip)*CENT_PIP - (q2_pip/v1_pip)*CENT_PIP + (q2_pip/v2_pip)*PERI_PIP;
dxdt_PERI_PIP = -(q2_pip/v2_pip)*PERI_PIP + (q2_pip/v1_pip)*CENT_PIP;

$TABLE
double free_pip = (CENT_PIP/v1_pip) * funb_pip;

$CAPTURE
free_pip')
```
</details>

Also, I only simulated piperacillin unbound concentration since the mic is focused mainly on that. And no point of including the proportional or additive residuals since we're not estimating the variance of the test result. The model looks smaller than the LLM generated. That being said, still a great exercise! Especially the ODE part.

## Probability of Target Attainment {#pta}

Ok, let's look at non critical care, non neutropenic febrile population with weight of 90kg and age 35 with Scr 0.83



<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="816" />

For easier visualization, I placed a red dashed red horizontal line to indicate PTA of 90%, and also dashed black vertical line to indicate mic of 16, the highest mic to be classified as susceptible to piptazo. We can see that both the 30 min infusion regardless of 4g had less than 90% PTA. Now, what if we increase the age and Scr a little bit to represent average population who will need piptazo. 


#### Age 50, Scr 1
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-5-1.png" width="816" />

OK, maybe on average, it might be OK with intermittent infusion as long as it's 4g. What if we look at critically ill population with early sepsis

#### Critically Ill 
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-6-1.png" width="816" />

Oh, that's interesting, I would expect it to be worse but what's showing here is the opposite. Looking at the calculation, it might be because of `funb_pip` == 1, which makes the free concentration higher. But in reality, this would also mean clearance is faster and higher as well. Since the way we code in the model doesn't account that, I'm not sure if we can make sense of this result. But we'll keep this because the paper actually questioned if fT > mic 50% might be too low for critically ill populations. We'll explore that in a little bit.

#### Neutropenic Fever
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="816" />

Wow, this is very dramatic. Even prolonged infusion except for 4g (3hr) q6 infusions had barely above 90% PTA.

## Maximum fT>mic used in the literature {#ftmic}
According to some literature that ft> mic 50% is not suitable for PsA, though there is no consensus on what the optimal threshold should be. I found some papers that used 70% or even 100%. Let's look at the PTA if we use these thresholds.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="816" />

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-9-1.png" width="816" />

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="816" />
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-11-1.png" width="816" />

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="816" />

OK, we are seeing the PTA drops quite a bit if fT>mic is 100%. This is when the critically ill population parameter might come in handy. Some even said that this population may need fT>4xmic 100% to achieve optimal outcome. So let's look at that as well.

#### fT > mic 100%
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-13-1.png" width="816" />

#### fT > 4 x mic 100%
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-14-1.png" width="816" />

Wow... 😵‍💫
When looking at the original paper, the number look quite similar to ours for extended infusion for both fT>mic 100% and fT>4xmic 100%. 

![](https://www.ncbi.nlm.nih.gov/core/lw/2.0/html/tileshop_pmc/tileshop_pmc_inline.html?title=Click%20on%20image%20to%20zoom&p=PMC3&id=11762590_40262_2024_1460_Fig5_HTML.jpg)


## Proportion of PsA in NCBI that would benefit from tazobactam {#gene}
How are we going to do this? It might not be 100% but we tried filtering PsA of piptazo susceptible and the overlap it with piperacillin resistant, but there were zero overlap. What if we grab all PsA piptazo susceptible and check for beta lactamase genes with exact match? 

[Over here](https://www.ncbi.nlm.nih.gov/pathogens/refgene/#allele:(blaTEM-1%20blaTEM-2%20blaTEM-3%20blaTEM-4%20blaTEM-5%20blaTEM-6%20blaTEM-7%20blaTEM-8%20blaTEM-9%20blaTEM-10%20blaTEM-12%20blaTEM-26%20blaSHV-1%20blaSHV-2%20blaSHV-5%20blaSHV-12%20blaCTX-M-1%20blaCTX-M-2%20blaCTX-M-3%20blaCTX-M-9%20blaCTX-M-14%20blaCTX-M-15%20blaCTX-M-27%20blaPER-1%20blaPER-2%20blaVEB-1%20blaVEB-9%20blaGES-1%20blaOXA-2%20blaOXA-10%20blaOXA-15%20blaPSE-4)) we search for `allele:(blaTEM-1 blaTEM-2 blaTEM-3 blaTEM-4 blaTEM-5 blaTEM-6 blaTEM-7 blaTEM-8 blaTEM-9 blaTEM-10 blaTEM-12 blaTEM-26 blaSHV-1 blaSHV-2 blaSHV-5 blaSHV-12 blaCTX-M-1 blaCTX-M-2 blaCTX-M-3 blaCTX-M-9 blaCTX-M-14 blaCTX-M-15 blaCTX-M-27 blaPER-1 blaPER-2 blaVEB-1 blaVEB-9 blaGES-1 blaOXA-2 blaOXA-10 blaOXA-15 blaPSE-4)` . 

Then run through the same script as [before](https://www.kenkoonwong.com/blog/cre/). Let's see what we find!



There were 212 isolates of PsA susceptible to piptazo, but only 124 isolates with assemblies. Of the 124 isolates we were able to grab the assemblies, we detected 46% (n=57) with `blaOXA-2`. Which means, there is a good chance that piperacillin would be hydrolyzed without the tazobactam!

## Final Thought {#final}
- Wow, these population PK and PK/PD studies are mathematically intense! High respect to those who were able to tease the signal out of the noise from all these studies. Definitely lots to learn! Now, I think I have a better understanding why CLSI and FDA had issued statements about mic 16 and piptazo dosing etc. This makes so much more sense now. 🙌 

## Opportunities For Improvement {#opportunities}
- get more literature on clinical outcomes and fT > mic of different thresholds, and same with PTA
- does tazobactam mic matter in this setting? 
- does albumin matter much here?
- what about cefepime PTA?
  
## Lessons learnt {#lessons}
- created an actual PTA plot of all the mics
- learnt to recreate model based on popPK study, thank goodness they provide equations on the paper!
- got a bit more comfortable with the model parameters in mrgsolve

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://rstats.me/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
