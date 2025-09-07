---
title: Building DNA Sequence Alignment With Needleman-Wunsch Algorithm From Scratch - A Note To My Self
author: Ken Koon Wong
date: '2025-09-07'
slug: dynamic-programming
categories: 
- r
- R
- alignment
- dynamic programming
- bioconductor
- Needleman-Wunsch
tags: 
- r
- R
- alignment
- dynamic programming
- bioconductor
- Needleman-Wunsch
excerpt: Ever wondered how DNA alignment actually works under the hood? 🧬 We coded the Needleman-Wunsch algorithm from scratch, working through scoring matrices by hand with simple examples like "CAT" vs "CT" before testing on real E. coli sequences. Pretty neat to see the magic happen! ✨
---

> Ever wondered how DNA alignment actually works under the hood? 🧬 We coded the Needleman-Wunsch algorithm from scratch, working through scoring matrices by hand with simple examples like "CAT" vs "CT" before testing on real E. coli sequences. Pretty neat to see the magic happen! ✨

## Motivations
We've looked at [detecting AMR genes](https://www.kenkoonwong.com/blog/amr/) and [phylogenetic analysis workflow](https://www.kenkoonwong.com/blog/phylo/) previously. As we like to look under the hood to see how things work, today, let's look at how the alignment actually works.  

#### Disclaimer:
*I am not a bioinformatician and do not work with genes directly, the articles and method presented is my attempt to get a better understanding on the method behind the aligment. Please take this with a grain of salt. Verify the information presented. If you noted some error in this article, please let me know so that I can learn! Also, these codes were not run during rmarkdown knitting because of significant delay for each knitting, however, the results posted here should be reprodicuble. Please again let me know if they are not* 

## Objectives
- [What is Alignment](#alignment)
- [What method can be used for Alignment?](#method)
- [Let's work through an example](#example)
  - [Step 1: Set Up Scores](#step1)
  - [Step 2: Calculate Scoring Matrix](#step2)
  - [Step 3: Traceback To Find Optimal Alingment](#step3)
- [Let's Try Our Code With More Examples](#more)
- [Opportunity for improvement](#opportunity)
- [Lessons Learnt](#lessons)

## What Is Alignment? {#alignment}
Sequence alignment is a fundamental technique in bioinformatics that arranges two or more biological sequences (like DNA, RNA, or protein sequences) to identify regions of similarity and difference. By introducing gaps represented by dashes, alignment algorithms position corresponding characters from different sequences in the same columns, revealing evolutionary relationships, functional similarities, and structural conservation. For example, aligning "CCCCCGGGGG" with "CCCGGG" might show that the shorter sequence is missing certain bases but shares a common core with the longer one. 

## What Method Can Be Used For Alignment? {#method}
Sequence alignment methods include dynamic programming algorithms like [Needleman-Wunsch](https://en.wikipedia.org/wiki/Needleman%E2%80%93Wunsch_algorithm) (global) and Smith-Waterman (local) that provide optimal but slow results, fast heuristic methods like BLAST and FASTA for database searching, progressive approaches like ClustalW for multiple sequences, and specialized techniques including dot-matrix visualization, structural alignment using 3D protein information, and profile-based methods with hidden Markov models. [source](https://en.wikipedia.org/wiki/Sequence_alignment)

Global alignment method such as [`Needleman-Wunsch`](https://en.wikipedia.org/wiki/Needleman%E2%80%93Wunsch_algorithm) should be a good one to learn from scratch with dynamic programming. This [youtube tutorial by Professor Hendrix](https://www.youtube.com/watch?v=b6xBvl0yPAY&themeRefresh=1) is very helpful in creating `scoring matrix`, `traceback matrix` and `optimal alignment`.

## Let's Work Through An Example {#example}
What we'll do here is we'll go through a simple example by hand, then write code that reresents that. I wouldn't be surprised if some of these are confusing, because they are, and it took me quite a few days working on paper to follow the procedure. If you find it confusing, please look at [youtube tutorial by Professor Hendrix](https://www.youtube.com/watch?v=b6xBvl0yPAY&themeRefresh=1), I found it very helpful. 

Let's set an example. We have 2 very simple sequences and having the end in mind will be beneficial IMO.

<p align="center">
  <img src="endinmind.png" alt="image" width="10%" height="auto">
</p>

As you can see above, we have 2 sequences. The first row is `CAT`, and the second row is `CT`. The `-` is what we call a `gap`. If the algorithm works, we will see the dynamic programming do its magic and automatically insert a gap on our second sequence


### Step 1: Set Up Scores {#step1}
<center>
<p>Match = +2</p>    
<p>Mismatch = -1</p>     
<p>Gap = -2</p> 
</center>

What the above mean is that, when we compare our first and second sequence for element, we will use these score to form our scoring matrix below. For example, if it's a match (e.g. `A-A`), we will `+2` from a diagonal score. If it's a mismatch, we will `-1` from diagonal score. Then we will just `-2` for the score above and on the left. Confusing? I'm with you. See below example for better visual procedure.


### Step 2: Calculate Scoring Matrix {#step2}
Having the end in mind, we should have this scoring matrix for our above sequences.

<p align="center">
  <img src="scoring_mat.png" alt="image" width="30%" height="auto">
</p>

But of course, when we first begin, we will have an empty matrix, like so. 

<p align="center">
  <img src="scoring_mat_empty.png" alt="image" width="30%" height="auto">
</p>

Let's view the steps all at a time, like so.

<p align="center">
  <img src="scoring_mat_step.png" alt="image" width="100%" height="auto">
</p>

Notice that the `matrix[1,1]` is always `0` and we name the column and row as `.`. Then, we fill `matrix[1,1:3]` with cumulative `-2`. Same goes to `matrix[1:4,1]`. Then, we start filling our first score on `matrix[2,2]` by finding the `maximum` of 3 calculations (`diagonal`, `up`, `left`), see picture for actual calculation above. To be explicit, for `matrix[2,2]`, we first assess if `column name` and `row name` of `matrix[2,2]` is a match or a mismatch. What do you think? `Matrix[2,2]` is `C-C`, hence a match! On diagonal (meaning `matrix[1,1]`), we all use `matrix[1,1]` score and `+2`. For the one above (up) `matrix[1,2]`, we will `-2`. Same goes with left `matrix[2,1]`, we will `-2`, since these are gaps. One thing that got me really confused are these ups and lefts. But remember, we will ALWAYS use these score and subtract by our gap penalty (in our case `-2`). After all these calculation, the max of these 3 (diag, up, left) is 2, which is from diag. Hence `matrix[2,2]` is `2`. Then, we'll move next to `matrix[3,2]` etc.   


<details>
<summary>Code: click to expand</summary>

``` r
nrow <- nchar(seq1)+1
ncol <- nchar(seq2)+1

mat <- matrix(nrow = nrow, ncol = ncol, dimnames = list(c(".",str_split_1(seq1,"")),c(".",str_split_1(seq2,""))))
                                                  
# gap penalty
mat[1,1:ncol] <- seq(0,-2*(ncol-1),-2)
mat[1:nrow,1] <- seq(0,-2*(nrow-1),-2)

# calc score
colname <- colnames(mat)
rowname <- rownames(mat)

row_list <- 2:nrow
col_list <- 2:ncol

for (i in row_list) {
  for (j in col_list) {
same <- ifelse(rowname[i]==colname[j], T, F)

## calc diag
if (same) {
  score_diag <- mat[i-1,j-1] + 2
} else {
  score_diag <- mat[i-1,j-1] - 1
}

## calc up
score_up <- mat[i-1,j] - 2 

## calc left
score_left <- mat[i,j-1] - 2

score_i <- max(score_diag, score_up, score_left)

mat[i,j] <- score_i
# print(mat)

  }
}
```
</details>


### Step 3: Traceback To Get Optimal Alignment {#step3}
Alright, our final scoring matrix is as such.

<p align="center">
  <img src="scoring_mat_filled.png" alt="image" width="30%" height="auto">
</p>

We first start at the bottom right grid, then follow the maximum score grid like so. 

<p align="center">
  <img src="trace_back.png" alt="image" width="100%" height="auto">
</p>

So, we first start off with bottom right grid. First assess if the column name and row name is the same, in this case it is, hence we align them up`T-T`. Next, we look at `diag`, `up`, and `left` and see which is the `maximum`. In this case, `1` is the highest, hence we move `up`. When we move `up`, it means, the `row name` persists while we place a `gap` on column name for our alignment. This took me a while to get the intuition, but notice that there is one row index reduction but the column index remains the same. That's why we insert a `gap` on our new column name sequence. Next, you do the same thing, and the max is the move diagonally to `matrix[2,2]`, and since the column namd and row name are the same `C-C`, we align them as such. 

There you go! That's the basics of Needleman-Wunsch Algorithm! 🙌

<details>
<summary>click to expand</summary>

``` r
library(tidyverse)
library(Biostrings)


ken_tedious_alignment <- function(seq1,seq2) {
{
nrow <- nchar(seq1)+1
ncol <- nchar(seq2)+1

mat <- matrix(nrow = nrow, ncol = ncol, dimnames = list(c(".",str_split_1(seq1,"")),c(".",str_split_1(seq2,""))))
                                                  
# gap penalty
mat[1,1:ncol] <- seq(0,-2*(ncol-1),-2)
mat[1:nrow,1] <- seq(0,-2*(nrow-1),-2)

# calc score
colname <- colnames(mat)
rowname <- rownames(mat)

row_list <- 2:nrow
col_list <- 2:ncol

for (i in row_list) {
  for (j in col_list) {
same <- ifelse(rowname[i]==colname[j], T, F)

## calc diag
if (same) {
  score_diag <- mat[i-1,j-1] + 2
} else {
  score_diag <- mat[i-1,j-1] - 1
}

## calc up
score_up <- mat[i-1,j] - 2 

## calc left
score_left <- mat[i,j-1] - 2

score_i <- max(score_diag, score_up, score_left)

mat[i,j] <- score_i
# print(mat)

  }
}


}


## now walk back - start where?
{
row_i <- nrow
col_i <- ncol

seq_instruct <- c()
same <- F

for (repeat_i in 1:(nrow-1)) {
  # print(paste("row: ",rowname[row_i]," ",row_i, " col: ",colname[col_i]," ",col_i))
if (colname[col_i]==rowname[row_i]) { 
  same <- T 
  
} else { same <- F }
# print(same)
  

if (is.null(seq_instruct)) { 
  if (same) {
  seq_instruct <- c(seq_instruct, "S")
  next}
  if (!same && (nrow>ncol)) {
    seq_instruct <- c(seq_instruct, "A")
  }
  if (!same && (ncol>nrow)) {
    seq_instruct <- c(seq_instruct, "-")
    # print("ncol>nrow")
  }
  # print("this should only show once")
  } 

## find max 
diag <- mat[row_i-1,col_i-1] #1
up <- mat[row_i-1,col_i] #2
left <- mat[row_i, col_i-1] #3

# print(seq_instruct)

max_score <- max(diag,up,left)
max_score_location <- which(c(diag,up,left) == max_score)
# print(max_score_location)
if (length(max_score_location) > 1) { max_score_location <- sample(max_score_location, 1) }

## match and find location for new start
if (max_score_location==1) { 
  row_i <- row_i - 1
  col_i <- col_i - 1
  # seq_instruct <- c(seq_instruct, "S")
  } 
if (max_score_location==2) {
  row_i <- row_i - 1
  # seq_instruct <- c(seq_instruct, "A")
} 
if (max_score_location==3) {
  col_i <- col_i - 1
  # seq_instruct <- c(seq_instruct, "-")
}

if (repeat_i!=1) {
  if (max_score_location==1) { seq_instruct <- c(seq_instruct, "S") }
  if (max_score_location==2) { seq_instruct <- c(seq_instruct, "A") }
  if (max_score_location==3) { seq_instruct <- c(seq_instruct, "-") }
}
# print(seq_instruct)
}
print(mat)
}



## turn instruction back to sequence
{
# seq_instruct
# max_length <- max(nrow-1,ncol-1)
seq1_align <- seq2_align <- vector(mode = "character", length=length(seq_instruct))
max_i <- length(seq_instruct)
i <- nrow
j <- ncol

for (count in 1:length(seq_instruct)) {
    if (seq_instruct[count]=="S") {
      seq1_align[max_i] <- rowname[i]
      seq2_align[max_i] <- colname[j]
      i <- i - 1
      j <- j - 1
    }
    if (seq_instruct[count]=="A") {
      seq1_align[max_i] <- rowname[i]
      seq2_align[max_i] <- "-"
      i <- i - 1
    }
    if (seq_instruct[count]=="-") {
      seq1_align[max_i] <- "-"
      seq2_align[max_i] <- colname[j]
      j <- j -1
    }
    max_i <- max_i - 1
}
}
  tryCatch(expr = {
  print(DNAString(seq1_align |> paste(collapse="")))
  print(DNAString(seq2_align |> paste(collapse=""))) 
  return(list(seq1_align, seq2_align))}
  , error=function(e) {
    print(seq1_align)
    print(seq2_align)}
  )
}



## Some examples, uncomment to try
# seq1 <- "dogcathorse"
# seq2 <- "dogcthrs"
# 
# seq1 <- "CCAGCCAGGACTACGTAAGTCA"
# seq2 <- "CCGCGGACTCGTATCA"
# ken_ted ious_alignment(seq1,seq2)
```
</details>

## Let's Try Our Code With More Sequences {#more}

``` r
seq1 <- "CCAGCCAGGACTACGTAAGTCA"
seq2 <- "CCGCGGACTCGTATCA"
ken_tedious_alignment(seq1,seq2)
```


<p align="center">
  <img src="example1.png" alt="image" width="60%" height="auto">
</p>

The first example with longer sequence. Not bad. Looks like it works.


``` r
seq1 <- "AAATCCATATGCCACAGA"
seq2 <- "AATTCGATCCATATATTTGCCAAATTCCAGA"
ken_tedious_alignment(seq1,seq2)
```

<p align="center">
  <img src="example2.png" alt="image" width="60%" height="auto">
</p>

Second example, we made seq1 shorter. Not bad too! It works!



``` r
seq1 <- "GATATAGCGGGTTTAACCGTTAAA"
seq2 <- "GATATAGCGGGTTTAACCGTT"
ken_tedious_alignment(seq1,seq2)
```

<p align="center">
  <img src="example3.png" alt="image" width="60%" height="auto">
</p>

Thirds example, we want to make sure we can have gaps towards the end. Yes, it works too! 


``` r
seq1 <- "dogcathorse"
seq2 <- "dgcthrs"
ken_tedious_alignment(seq1,seq2)
```

<p align="center">
  <img src="example4.png" alt="image" width="100%" height="auto">
</p>

Let's try just regular words and see if it works? Yes it does!

Now, here are a few examples that don't quite work that might be a good opportunity to debug

``` r
seq1 <- "GATATAGCGGGTTTAACCGTTAAA"
seq2 <- "AGCGGGTTTAACCGTT"
ken_tedious_alignment(seq1,seq2)
```


<p align="center">
  <img src="example5.png" alt="image" width="60%" height="auto">
</p>

Yea, that looks really wrong. 😑 Might be good to debug some other time! Now since the above sequences were just letters and randomly entered, let's check 2 Ecoli 16s rRNA sequences.


``` r
seq1 <- "TTGAAGAGTTTGATCATGGCTCAGATTGAACGCTGGCGGCAGGCCTAACACATGCAAGTCGAACGGTAACAGAAAGCAGCTTGCTGCTTTGCTGACGAGTGGCGGACGGGTGAGTAATGTCTGGGAAACTGCCTGATGGAGGGGGATAACTACTGGAAACGGTAGCTAATACCGCATAACGTCGCAAGACCAAAGAGGGGGACCTTCGGGCCTCTTGCCATCGGATGTGCCCAGATGGGATTAGCTTGTTGGTGGGGTAACGGCTCACCAAGGCGACGATCCCTAGCTGGTCTGAGAGGATGACCAGCCACACTGGAACTGAGACACGGTCCAGACTCCTACGGGAGGCAGCAGTGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCCATGCCGCGTGTATGAAGAAGGCCTTCGGGTTGTAAAGTACTTTCAGCGGGGAGGAAGGGAGTAAAGTTAATACCTTTACTCATTGACGTTACCCGCAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATACGGAGGGTGCAAGCGTTAATCGGAATTACTGGGCGTAAAGCGCACGCAGGCGGTTTGTTAAGTCAGATGTGAAATCCCCGGGCTCAACCTGGGAACTGCATCTGATACTGGCAAGCTTGAGTCTCGTAGAGGGGGGTAGAATTCCAGGTGTAGCGGTGAAATGCGTAGAGATCTGGAGGAATACCGGTGGCGAAGGCGGCCCCCTGGACGAAGACTGACGCTCAGGTGCGAAAGCGTGGGGAGCAAACAGGATTAGATACCCTGGTAGTCCACGCCGTAAACGATGTCGACTTGGAGGTTGTGCCCTTGAGGCGTGGCTTCCGGAGCTAACGCGTTAAGTCGACCGCCTGGGGAGTACGGCCGCAAGGTTAAAACTCAAATGAATTGACGGGGGCCCGCACAAGCGGTGGAGCATGTGGTTTAATTCGATGCAACGCGAAGAACCTTACCTGGTCTTGACATCCACGGAAGTTTTCAGAGATGAGAATGTGCCTTCGGGAACCGTGAGACAGGTGCTGCATGGCTGTCGTCAGCTCGTGTTGTGAAATGTTGGGTTAAGTCCCGCAACGAGCGCAACCCTTATCCTTTGTTGCCAGCGGCCCGGCCGGGAACTCAAAGGAGACTGCCAGTGATAAACTGGAGGAAGGTGGGGATGACGTCAAGTCATCATGGCCCTTACGACCAGGGCTACACACGTGCTACAATGGCGCATACAAAGAGAAGCGACCTCGCGAGAGCAAGCGGACCTCATAAAGTGCGTCGTAGTCCGGATTGGAGTCTGCAACTCGACTCCATGAAGTCGGAATCGCTAGTAATCGTGGATCAGAATGCCACGGTGAATACGTTCCCGGGCCTTGTACACACCGCCCGTCACACCATGGGAGTGGGTTGCAAAAGAAGTAGGTAGCTTAACCTTCGGGAGGGCGCTTACCACTTTGTGATTCATGACTGGGGTGAAGTCGTAACAAGGTAACCGTAGGGGAACCTGCGGTTGGATCACCTCCTT" 
seq2 <- "TTGAAGAGTTTGATCATGGCTCAGATTGAACGCTGGCGGCAGGCCTAACACATGCAAGTCGAACGGTAACAGGAAGAAGCTTGCTTCTTTGCTGACGAGTGGCGGACGGGTGAGTAATGTCTGGGAAACTGCCTGATGGAGGGGGATAACTACTGGAAACGGTAGCTAATACCGCATAACGTCGCAAGACCAAAGAGGGGGACCTTCGGGCCTCTTGCCATCGGATGTGCCCAGATGGGATTAGCTAGTAGGTGGGGTAACGGCTCACCTAGGCGACGATCCCTAGCTGGTCTGAGAGGATGACCAGCCACACTGGAACTGAGACACGGTCCAGACTCCTACGGGAGGCAGCAGTGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCCATGCCGCGTGTATGAAGAAGGCCTTCGGGTTGTAAAGTACTTTCAGCGGGGAGGAAGGGAGTAAAGTTAATACCTTTACTCATTGACGTTACCCGCAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATACGGAGGGTGCAAGCGTTAATCGGAATTACTGGGCGTAAAGCGCACGCAGGCGGTTTGTTAAGTCAGATGTGAAATCCCCGGGCTCAACCTGGGAACTGCATCTGATACTGGCAAGCTTGAGTCTCGTAGAGGGGGGTAGAATTCCAGGTGTAGCGGTGAAATGCGTAGAGATCTGGAGGAATACCGGTGGCGAAGGCGGCCCCCTGGACGAAGACTGACGCTCAGGTGCGAAAGCGTGGGGAGCAAACAGGATTAGATACCCTGGTAGTCCACGCCGTAAACGATGTCGACTTGGAGGTTGTGCCCTTGAGGCGTGGCTTCCGGAGCTAACGCGTTAAGTCGACCGCCTGGGGAGTACGGCCGCAAGGTTAAAACTCAAATGAATTGACGGGGGCCCGCACAAGCGGTGGAGCATGTGGTTTAATTCGATGCAACGCGAAGAACCTTACCTGGTCTTGACATCCACGGAAGTTTTCAGAGATGAGAATGTGCCTTCGGGAACCGTGAGACAGGTGCTGCATGGCTGTCGTCAGCTCGTGTTGTGAAATGTTGGGTTAAGTCCCGCAACGAGCGCAACCCTTATCCTTTGTTGCCAGCGGTCCGGCCGGGAACTCAAAGGAGACTGCCAGTGATAAACTGGAGGAAGGTGGGGATGACGTCAAGTCATCATGGCCCTTACGACCAGGGCTACACACGTGCTACAATGGCGCATACAAAGAGAAGCGACCTCGCGAGAGCAAGCGGACCTCATAAAGTGCGTCGTAGTCCGGATTGGAGTCTGCAACTCGACTCCATGAAGTCGGAATCGCTAGTAATCGTGGATCAGAATGCCACGGTGAATACGTTCCCGGGCCTTGTACACACCGCCCGTCACACCATGGGAGTGGGTTGCAAAAGAAGTAGGTAGCTTAACCTTCGGGAGGGCGCTTACCACTTTGTGATTCATGACTGGGGTGAAGTCGTAACAAGGTAACCGTAGGGGAACCTGCGGTTGGATCACCTCCTT"

seq_list <- ken_tedious_alignment(seq1,seq2)
idx <- which((seq1 |> str_split_1(""))!=(seq2 |> str_split_1("")))

for (i in idx) {
print(DNAString(paste(seq_list[[1]][(i-3):(i+3)],collapse="")))
print(DNAString(paste(seq_list[[2]][(i-3):(i+3)],collapse="")))
cat("------------------\n\n")
}
```


<p align="center">
  <img src="ecoli1.png" alt="image" width="100%" height="auto">
</p>


<p align="center">
  <img src="ecoli2.png" alt="image" width="40%" height="auto">
</p>

The above are the differences of the 2 strains and how our algorithm aligned them. Pretty neat!

## Final Thoughts
Wow, that was quite rewarding to go through the dynamic programming procedure. It was tedious but well worth the effort. I'm curious what other problems would benefit from this method? 🤔 Let me know if you have used this on non-bioinformatic related field! 

<br>

## Opportunity for Improvement {#opportunity}
- Learn more about local alignment, clustering, blast, etc
- Learn how `DECIPHER` aligns
- Learn how to make this more efficient
- Next stop would be distance calculation after alignment, and then growing tree 🌲

## Lessons Learnt {#lessons}
- Learnt the basics of DNA sequence alignment
- Coded the algorithm from scratch really helped me understand the procedure

<br>

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
