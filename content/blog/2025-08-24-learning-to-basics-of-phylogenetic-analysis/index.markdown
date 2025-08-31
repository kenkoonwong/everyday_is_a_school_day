---
title: Learning The Basics of Phylogenetic Analysis
author: Ken Koon Wong
date: '2025-08-31'
slug: phylo
categories: 
- r
- R
- phylgenetic analysis
- bioconductor
- DECIPHER
- alignment
- ape
- barrnap
- rapidnj
- figtree
- ggtree
tags: 
- r
- R
- phylgenetic analysis
- bioconductor
- DECIPHER
- alignment
- ape
- barrnap
- rapidnj
- figtree
- ggtree
excerpt: 🧬🔬 Explore phylogenetic analysis from genome to tree! Basic workflow with R/Bioconductor. Learnt to work with large genomic dataset. Extract 16S rRNA from 10K+ E.coli strains using dataset dehydrate, barrnap for extraction, rapidNJ for tree building & FigTree for visualization.
---

> 🧬🔬 Explore phylogenetic analysis from genome to tree! Basic workflow with R/Bioconductor. Learnt to work with large genomic dataset. Extract 16S rRNA from 10K+ E.coli strains using dataset dehydrate, barrnap for extraction, rapidNJ for tree building & FigTree for visualization.

## Movitation:
After that [last hands-on experience on Bioconductor](https://www.kenkoonwong.com/blog/amr/), we will continue our journey in phylogenetic analysis. I've always been intrigued in how biologists piece these phylogenetic tree together and I want to know the big idea of how this is done. We'll again be using Bioconductor. Let's go! 

#### Disclaimer:
*I am not a bioinformatician and do not work with genes directly, the articles and method presented is my attempt to get a birds eye view on how we went from different isolates to piecing them together onto a single tree. Please take this with a grain of salt. Verify the information presented. If you noted some error in this article, please let me know so that I can learn! Also, some of the analysis results were not run during rmarkdown knitting because that causes a significant delay, however, the results posted here should be reprodicuble. Please again let me know if they are not* 

## The End Goal:
1. Get a basic workflow of how this is done
2. Assess Many Many Ecoli strains
3. Assess Different Genus on a single tree

Looks quite doable! Along the line, we may have some deeper dive to look at the machinery behind. Ultimately, we want to visualize beuatiful trees! 🌴 Like this. 

![](figtree_phylo.jpeg)

## Objectives:
- [What is phylogenetic analysis?](#phylo)
- [The workflow](#workflow)
  - [Extract 16S rRna](@16s)
  - [Align](#align)
  - [Distance Calculation](#distance)
  - [Tree construction](#tree)
  - [Visualizing Phylogenetic tree](#dataviz)
- [Ecoli Large Dataset](#ecoli)
- [Other Genus](#others)
- [Opportunities for improvement](#opportunity)
- [Lessons Learnt](#lesson)

## What is phylogenetic analysis? {#phylo}
Phylogenetic analysis is a method used to study the evolutionary relationships between organisms. It involves comparing genetic sequences, such as DNA or RNA, to infer how species are related through common ancestry. This analysis can help identify how different organisms have evolved over time and can be particularly useful in [contact tracing, outbreak assessment](https://journals.asm.org/doi/10.1128/microbiolspec.ame-0006-2018). [Here is a quick wiki](https://en.wikipedia.org/wiki/Phylogenetics)

#### Let's Download ALL Ecoli Fasta
One of our [previous opportunity improvement](https://www.kenkoonwong.com/blog/amr/) is to learn to use [NCBI dataset CLI](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/). We'll be using that this time because if you try to download more than 10,000 of fasta via website or event the CLI itself, it won't be as smooth, at least from my multiple tries. I've attempted maybe 5-6 times and couldn't complete the download even when I used `datasets` and unable to resume downloads. However, the most stable is actually to `download dehydrated` then `rehydrate`. [See here](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/)

#### Terminal

``` bash
curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/mac/datasets'
chmod +x datasets dataformat
datasets download genome taxon "Escherichia coli" \
  --assembly-level scaffold,chromosome,complete \
  --dehydrated \
  --filename ecoli_high_quality_dehydrated.zip
unzip ecoli_genomes_dehydrated.zip 
cd ncbi_dataset
datasets rehydrate --directory
```

> For large genome downloads, use `datasets dehydrated` then `rehydrate`. It's easier to resume download if connection got lost. 

You notice above that we left off `contig` and just included scaffold, chromosome, and complete? That's because there were 300,000 sequences if we include all of them. I definitely don't need all of those packages. With scaffold, chromosome, and complete, we got 30,000+ and the entire zip file was `58 gigs` of data. 😵‍💫

Just for my education:
- `Contig` - Short for "contiguous sequence." This is a continuous stretch of DNA sequence with no gaps. Contigs are assembled from overlapping sequencing reads, but they represent isolated pieces without known relationships to other contigs.
- `Scaffold` - A collection of contigs that have been ordered and oriented relative to each other, often with gaps of estimated size between them. Scaffolding uses additional information like paired-end reads or mate-pair libraries to determine how contigs should be arranged, even when the sequence connecting them isn't fully resolved.
- `Chromosome` - Contigs and scaffolds have been assembled into chromosome-scale sequences that represent entire chromosomes. This typically requires additional long-range information like Hi-C data, optical mapping, or long-read sequencing to achieve proper chromosome-level organization.
- `Complete` - The highest level of assembly where the entire genome is finished with no gaps, including challenging repetitive regions, centromeres, and telomeres. This represents a truly complete, end-to-end sequence of all chromosomes.


## The Workflow {#workflow}
The workflow for phylogenetic analysis typically involves several key steps:  

> Extract 16s rRNA -> Align -> Calculate Distance -> Construct Tree

### Extract 16S rRNA {#16s}
This step involves obtaining the genetic material from the organisms of interest, such as bacteria or viruses. For example, in the case of antibiotic resistance, researchers might extract the 16S rRNA gene, which is commonly used for bacterial identification. The reason for extracting 16S rRNA in bacteria is beccause the sequence are highly conserved across different species, making it a reliable marker for phylogenetic analysis. The 16S rRNA gene is present in all bacteria and archaea, and its sequence can provide insights into the evolutionary relationships between different microbial species. Let's dive into the code to do this. We'll use the same 2 groups we used before, regular Ecoli and ESBL Ecoli [from before](https://www.kenkoonwong.com/blog/amr/)


``` r
library(Biostrings)
library(DECIPHER)

# load data
path1 <- "/path/to/your/first/ecoli/data"

non_esbl_ecoli_files <- list.files(path1, pattern = "*.fna", recursive = T)
non_esbl_ecoli <- DNAStringSet()
for (i in non_esbl_ecoli_files) {
  seq_i <- readDNAStringSet(paste0(path1,i))[1]
  non_esbl_ecoli <- c(non_esbl_ecoli,seq_i)
}

path2 <- "/path/to/your/second/ecoli/data"
esbl_ecoli_files <- list.files(path2, pattern = "*.fna", recursive = T)
esbl_ecoli <- DNAStringSet()
for (i in esbl_ecoli_files) {
  seq_i <- readDNAStringSet(paste0(path2,i))[1]
  esbl_ecoli <- c(esbl_ecoli,seq_i)
}

all_ecoli <- c(non_esbl_ecoli, esbl_ecoli)

# extract 16s
data("NonCodingRNA_Bacteria")
x <- NonCodingRNA_Bacteria$`rRNA_16S-RF00177`
all_ecoli[1]
rrna <- FindNonCoding(x = x, myXStringSet = all_ecoli[1:5], verbose = T) 
rrna
```

![](16s.png)
The reason I only used `all_ecoli[1:5]` is because it's EXTREMELY slow to extract 16s with `DECIPHER`. Later on we'll use an external tool called `barrnap` to extract our 10k contigs seemlessly. Let's continue.


``` r
(extract <- ExtractGenes(x = rrna, myDNAStringSet = all_ecoli[1:5]))
```

![](extract_16s.png)

Look at that beauty! Because `DECIPHER` extracted multiple `16s` sequences, hence we see there are 35 rows of data, even though we're only using 5 strains of Ecoli. Since we're having trouble with extracting 16s with DECIPHER, speed being the issue, let's try `barrnap`! To install is, [check out their github](https://github.com/tseemann/barrnap)

#### Terminal

``` bash
brew install brewsci/bio/barrnap
```

#### Back to R

``` r
writeXStringSet(all_ecoli, filepath = "40_ecoli.fasta")
system("barrnap --threads 90 40_ecoli.fasta > 40_ecoli_16s.gff")

library(ape)
(df <- read.gff("40_ecoli_16s"))
```

![](extract_16s_barrnap.png)

Alright, let's turn this into a dataframe, extract 16s only, and choose the first one with `+` and we'll have our 16s! Take note that there is a column called `score`, it is `evalue`, the lower (closer to zero) the better. These all look pretty good. Remember, the tool only tells you where the positions are, you have to go back to your genome and extract those. Let's go! 


``` r
library(tidyverse)

df <- df |>
  as_tibble() |>
  filter(str_detect(attributes, "16S")) |>
  filter(strand == "+") |>
  distinct(seqid, .keep_all = T)

all_sequences <- DNAStringSet()
for (i in 1:nrow(df)) {
  name <- paste0("^",df[[i, "seqid"]]) 
  assembly <- all_ecoli[str_detect(all_ecoli |> names(), name)]
  seq_i <- subseq(assembly, start = df[[i, "start"]], end = df[[i, "end"]])
  all_sequences <- c(all_sequences, seq_i)
}

all_sequences
```

![](extract_16s_barrnap_genome.png)
Again, what a beauty! These sequences look quite conversed, don't they? Take note that a 16s rRNA sequence is about 1538 base pairs, there is one on the glance that is only 1537. This is going to be a problem if we're trying to calculate distance. Hence, `align` is crucial to ensure they all have the same length of sequence. 

> Barrnap is truly an efficient tool to extract 16s positions from bacteria! The --threads option is awesome if you have lots of cpu to spare! This is will very helpful when we have to extract 10k sequences

### Align {#align}
Alignment is a crucial step in phylogenetic analysis as it ensures that the sequences being compared are of the same length and that homologous positions are aligned correctly. This is important because differences in sequence length or misaligned positions can lead to inaccurate distance calculations and, consequently, incorrect phylogenetic trees. By aligning sequences, we can accurately identify conserved regions, mutations, insertions, and deletions, which are essential for inferring evolutionary relationships. Let's align our 16s sequences using `DECIPHER`


``` r
alignment <- AlignSeqs(all_sequences, verbose = TRUE)
```

![](alignment.png)


``` r
alignment[36] |> as.character()
```

![](align_contig.png)
Remember that one contig that we saw previously with 1 missing nucleotide? `DECIPHER` basically adds a `-` to the missing position. The method behind this is very interesting! We will take a deep dive next time. But it uses `dynamic programming` to find the optimal alignment by minimizing the number of mismatches and gaps. It constructs a scoring matrix based on matches, mismatches, and gap penalties, then traces back through the matrix to determine the best alignment path. This `dynamic programming` actually is a different `dynamic programming` than the one used in reinforcement learning, I think. 

### Distance Calculation {#distance}
Distance calculation is a crucial step in making sense of all these 16s rRNA sequences.By calculating distances, we can determine how closely related different organisms are, which is essential for constructing accurate phylogenetic trees. Various methods exist for distance calculation, such as p-distance (proportion of differing sites), Jukes-Cantor, and Kimura models, each accounting for different aspects of sequence evolution. Let's use `Jukes-Cantor`


``` r
distances <- DistanceMatrix(alignment, 
                            correction = "Jukes-Cantor",
                            type = "dist", 
                            verbose = TRUE)

## This is just to show the matrix without names
dist <- as.matrix(distances)
rownames(dist) <- NULL
colnames(dist) <- NULL
dist
```

![](distance_matrix.png)
notice that [1,1], [2,2] ... are 0 because they are essentially comparing themselves. These methods are really intriguing. Can't say I understood all of them but maybe one day we'll take a deeper dive into these algorithms and its math behind them! Can't wait! On to the next, tree construction!

### Tree construction {#tree}

``` r
tree <- nj(distances)
```

Here, we basically used neighbor joining to construct our tree. Neighbor-joining is a distance-based method for constructing phylogenetic trees that focuses on minimizing the total branch length of the tree. It starts with a star-like structure and iteratively joins pairs of taxa (or nodes) that minimize the overall distance, effectively grouping closely related organisms together. 

Take note that this function from `ape` will not work well when it's a large dataset. It will be VERY slow! We will instead use [RapidNJ](https://github.com/somme89/rapidNJ) for that. An external tool but, wow the speed! Within seconds!

If you are using Mac M1/2 and want to use advantage of Mac M1/2 architecture, you can compile rapidNJ from source but from [John Lees](https://github.com/johnlees/rapidNJ-M1.git):

``` bash
git clone https://github.com/johnlees/rapidNJ-M1.git
cd rapidNJ-M1
make -j
```

#### Example on how to use for large dataset

``` r
library(phangorn)

dist <- as.matrix(distances)
names_list <- dist |> rownames() |> str_split(pattern = " ") 
names <- c()
for (i in 1:length(names_list)) {
  names <- c(names, names_list[[i]][1])
}

rownames(dist) <- names
colnames(dist) <- names
phangorn::writeDist(dist, file = "all_ecoli_phylip", format = "phylip")
system("rapidnj -i pd all_ecoli_phylip > all_ecoli_tree.newick")
```

Turn your `dist` format into matrix, remove any spaces on your matrix row and column names, write a `phylip` file then use `rapidNJ` to build tree. 

There may be times where there are `NA`s on our matrix. We can use the function below to impute number to make sure we don't have `NA`s. I'm actually not sure if rapidNJ can handle NAs, I know `ape::njs` can but it will again be very slow for large datasets.

#### Mean Imputation for NAs if Exists

``` r
impute_mean_distance <- function(dist_matrix) {
  mat <- as.matrix(dist_matrix)
  
  # Calculate mean excluding NAs
  mean_dist <- mean(mat, na.rm = TRUE)
  
  # Replace NAs with mean
  mat[is.na(mat)] <- mean_dist
  
  return(mat)
}

# Apply mean imputation
dist_imputed_mean <- impute_mean_distance(dist_mat)
```


### Visualizing Phylogenetic tree {#dataviz}


``` r
plot(tree, 
     main = "E. coli 16S rRNA Phylogenetic Tree",
     sub = paste("Based on", length(tree$tip.label), "16S sequences"),
     cex = 0.8,
     edge.width = 2)
```


![](phylo1.png)

I marked red boxes on the ESBL strains to see if it shows much insight. Not really. I was hoping to see some of the ESBL Ecoli are in the same clade but it doesn't seem like it. Maybe because we only used 40 strains. Technically, these ESBLs are controlled by plasmids, I suspect the chromosome sequence shouldn't really matter much, which means we should see clustering between both ESBLs and non-ESBLs.

The interpretation of the tree is essentially pay attention to the nodes, not the distances between each strains. The nodes represents a latent ancestor. The closer the nodes, the more related they are. Reminds me of a latent variable. If we want to compare between 2 strains, we basically count how many nodes are between their relationships. 

[Data Integration, Manipulation and Visualization of Phylogenetic Trees](https://yulab-smu.top/treedata-book/chapter4.html) has a very good chapter on viualizing tree using `ggtree`, it's REALLY neat! 

Again, if we have large dataset, we need to use something else. `plot` itself is pretty fast, but not ggtree. We'll use external tool again called [FigTree](https://github.com/rambaut/figtree/releases) to plot our large tree. It's faster and easier to navigate with a GUI, but will need java. 

## Ecoli Large Dataset {#}
<details>
<summary>click to expand code</summary>

``` r
########## asessing all ecoli
library(Biostrings)
library(tidyverse)
library(ape)
library(DECIPHER)

path <- "path/to/your/ecoli/data"
files <- list.files(path = path, pattern = "*.fna", recursive = T)

all_ecoli <- DNAStringSet()
for (i in files) {
  dna_i <- readDNAStringSet(paste0(path,i))[1]
  all_ecoli <- c(all_ecoli,dna_i)
}

# save it since it took sometime to read all
writeXStringSet(all_ecoli, filepath = "all_ecoli.fasta")

# load it if working in subsequent sessions
all_ecoli <- readDNAStringSet("all_ecoli.fasta")

# extract 16s
system("barrnap --threads 90 all_ecoli.fasta > all_ecoli_16s.gff")

# use position to get our 16s sequence
df <- read.gff("all_ecoli_16s.gff") |> 
  as_tibble() |>
  filter(str_detect(attributes, "16S")) |>
  filter(strand == "+") |>
  distinct(seqid, .keep_all = T)

all_sequences <- DNAStringSet()
for (i in 1:nrow(df)) {
  name <- paste0("^",df[[i, "seqid"]]) 
  assembly <- all_ecoli[str_detect(all_ecoli |> names(), name)]
  seq_i <- subseq(assembly, start = df[[i, "start"]], end = df[[i, "end"]])
  all_sequences <- c(all_sequences, seq_i)
  print(i)
}

# align
alignment <- AlignSeqs(all_sequences, verbose = TRUE)

# Save alignment
writeXStringSet(alignment, "all_ecoli_16s_alignment.fasta")


# load it (when returning from a new session)
alignment <- readDNAStringSet("all_ecoli_16s_alignment.fasta")

# Calculate distances
distances <- DistanceMatrix(alignment, 
                            correction = "Jukes-Cantor",
                            type = "dist", 
                            verbose = TRUE)

# save 
save(distances, file = "all_ecoli_distance.rda")

# load it (when returning from a new session)
load("all_ecoli_distance.rda")
dist_mat <- as.matrix(distances)

# impute NA
impute_mean_distance <- function(dist_matrix) {
  mat <- as.matrix(dist_matrix)
  
  # Calculate mean excluding NAs
  mean_dist <- mean(mat, na.rm = TRUE)
  
  # Replace NAs with mean
  mat[is.na(mat)] <- mean_dist
  
  return(mat)
}


# Apply mean imputation
dist_imputed_mean <- impute_mean_distance(dist_mat)

# converting to philip
dist_final <- dist_imputed_mean

### using phangorn for phylip
library(phangorn)

# rapidnj cannot handle spaces
names_list <- dist_final |> rownames() |> str_split(pattern = " ") 
names <- c()
for (i in 1:length(names_list)) {
  names <- c(names, names_list[[i]][1])
}

rownames(dist_final) <- names
colnames(dist_final) <- names
phangorn::writeDist(dist_final, file = "all_ecoli_phylip", format = "phylip")

# build tree w rapidnj
system("rapidnj -i pd all_ecoli_phylip > all_ecoli_tree.newick")

# read tree
library(ape)
tree <- read.tree("all_ecoli_tree.newick")

# Remove long branches
threshold <- 0.0001
sampled_tree$edge.length <- ifelse(sampled_tree$edge.length > threshold, threshold, sampled_tree$edge.length)

# set negative value to 0
sampled_tree$edge.length <- ifelse(sampled_tree$edge.length < 0, 0, sampled_tree$edge.length)

plot(sampled_tree,
     type = "fan",
     main = paste(length(sampled_tree$tip.label)," E. coli 16S rRNA Phylogenetic Tree"),
     cex = 0.1,
     edge.width = 1,
     show.tip.label = F)

write.tree(sampled_tree, file = "modified_ecol.newick")
```
</details>

This is the default `plot` function. Efficient but needs some improvement.

![](plot_phylo.png)

Now, if we use [FigTree](https://github.com/rambaut/figtree/releases), we can make into something like we saw upfront. 

![](figtree_phylo.jpeg)
To be quite frank. This looks quite pretty, but it doesn't really give me much information other than certain ecoli strains have clades and some clusters together. But without the names, we can't really say much and to put all these 10k+ names on the plot is just a group of meaningless mess. What if we sample these contigs, and revisit our topic of whether esbl and non-esbl tend to have their own clade or it doesn't matter because it's blaCTX-M, blaSHV, blaTEM are on plasmids, not chromosomes like what we're trying to assess here. 

Let's dive a bit deeper. Let's only show the tip label of the ESBLs in red and see if there is a cluster of them.

<details>
<summary>click to expand code</summary>

``` r
alignment <- readDNAStringSet("all_ecoli_16s_alignment.fasta")

sample_alignment <- alignment
  
esbl_index <- names(sample_alignment) |> str_detect("ESBL|esbl") |> which()
name_list <- c()
for (i in 1:length(sample_alignment)) {
  seq <- sample_alignment[i] |> names() |> str_split(" ")
  if (i %in% esbl_index) {
    name <- paste0(seq[[1]][1],"-ESBL")
  } else {
  name <- seq[[1]][1]
  }
  name_list <- c(name_list, name)
}

names(sample_alignment) <- name_list

distances <- DistanceMatrix(sample_alignment, 
                            correction = "Jukes-Cantor",
                            type = "dist", 
                            verbose = TRUE)

# tree <- nj(distances)
dist_mat <- as.matrix(distances)

# impute NA
impute_mean_distance <- function(dist_matrix) {
  mat <- as.matrix(dist_matrix)
  
  # Calculate mean excluding NAs
  mean_dist <- mean(mat, na.rm = TRUE)
  
  # Replace NAs with mean
  mat[is.na(mat)] <- mean_dist
  
  return(mat)
}


# Apply mean imputation
dist_imputed_mean <- impute_mean_distance(dist_mat)

# converting to philip
dist_final <- dist_imputed_mean

### using phangorn for phylip
library(phangorn)
phangorn::writeDist(dist_final, file = "all_ecoli_phylip_2", format = "phylip")

# build tree w rapidnj
system("rapidnj -i pd all_ecoli_phylip_2 > all_ecoli_tree_2.newick")

tree <- read.tree("all_ecoli_tree_2.newick")


tree$edge.length |> summary()
threshold <- 0.0001
tree$edge.length <- ifelse(tree$edge.length > threshold, threshold, tree$edge.length)

# set neg to 0
tree$edge.length <- ifelse(tree$edge.length < 0, 0, tree$edge.length)

plot(tree,
     main = "E. coli 16S rRNA Phylogenetic Tree",
     sub = paste("Based on", length(tree$tip.label), "16S sequences"),
     cex = 1,
     edge.width = 2)

library(ggtree)

# Assuming your tree object is called 'tree'
p <- ggtree(tree, layout = "circular") +
  geom_tiplab(aes(label = ifelse(grepl("ESBL", label), label, "")), 
              color = "red",
              size = 2)
p

esbl_parent_node <- tree$tip.label[tree$edge[,2]] |> str_detect("ESBL") |> which()

df_esbl_parent <- tibble(parent_node=as.numeric(),isolate=as.character())
for (i in esbl_parent_node) {
  idx_parent_node <- tree$edge[i,1]
  isolate <- tree$edge[tree$edge[,1] == idx_parent_node, 2]
  df_esbl_parent <- df_esbl_parent |>
    bind_rows(tibble(parent_node=idx_parent_node,isolate=tree$tip.label[isolate]))
  print(tree$tip.label[isolate])
}


df_esbl_parent <- df_esbl_parent |>
  distinct()

df_table <- df_esbl_parent |>
  group_by(parent_node) |>
  mutate(esbl = case_when(
    str_detect(isolate, "ESBL") ~ 2,
    is.na(isolate) ~ 0,
    TRUE ~ 1
  )) |>
  summarize(sum = sum(esbl)) 

df_table |>
  select(sum) |>
  mutate(name = case_when(
    sum == 4 ~ "ESBL_ESBL",
    sum == 3 ~ "ESBL_nonESBL",
    sum == 2 ~ "ESBL_NA"
  )) |>
  select(name) |>
  group_by(name) |>
  summarize(n = n()) |>
  mutate(prop = n/sum(n))
```
</details>

![](esbl_phylo.png)    

Doesn't seem like it. If ESBL strains were to have come later, or branched off from a specific ancestry, we should be seeing a more clustered branch, but it seems to be more wide spread across the tree. 

Let's take a deeper dive on looking at the tree data itself. If ESBL strains are more clustered together, we should be seeing more ESBL strains to have the same parent node (latent) than an ESBL strain with a non-ESBL strain. 

<p align="center">
  <img src="proportion.png" alt="image" width="60%" height="auto">
</p>

This shows that 33% of the ESBL strains have a non-ESBL strain that share its parent. Whereas 23.8% of ESBL strains share a parent with another ESBL strain. And 42.9% have parents with latent child (meaning another latent strain which we don't know whether it's ESBL or non-ESBL that bracnhed off to another phyla). 

*The code to generate the `ggtree` plot and proportion table is available on github.*

## Other Genus
Now, what if we include other genus of bacteria into a single tree? Let's grab `klebsiella aerogenes`, `pseudomonas aureginosa`, `enterobacter spp`, `staph aureus`, and we'll sample our existing `escherichia coli` and see if they would be in different branches? In theory they should be!

Looking at a glance, their 16s rRNA sequence look different too among different genus! If you still remember, [previously](#16s) our Ecoli 16s rRNA were quite similar.

![](16s_mixed.png)

Now let's plot the phylogenetic tree

![](mixed_phylo.png)

Wow, they do cluster close to each other! That is really cool! It also looks like complete seperation! that's amazing!


<details>
<summary>click to expand code</summary>

``` r
#### assessing other genus
ecoli <- sample(all_ecoli,10)

## create function
grab_fasta <- function(path) {
  files <- list.files(path = path, pattern = "*.fna", recursive = T)
  seq <- DNAStringSet()
  for (i in files) {
    dna_i <- readDNAStringSet(paste0(path,i))[1]
    seq <- c(seq,dna_i)
  }
  return(seq)
}

kleb <- grab_fasta(path = "kleb_aerogene/ncbi_dataset/data/")
pseudo <- grab_fasta(path = "pseudomonas/ncbi_dataset/data/")
staph <- grab_fasta(path = "staph_aureus/ncbi_dataset/data/")
entero <- grab_fasta(path = "enterobacter/ncbi_dataset/data/")
all <- c(ecoli, kleb, pseudo, staph, entero)

writeXStringSet(all, "mixed_bacteria.fasta")

system("barrnap --threads 90 mixed_bacteria.fasta > mixed_bacteria.gff")

df <- read.gff("mixed_bacteria.gff") |> 
  as_tibble() |>
  filter(str_detect(attributes, "16S")) |>
  filter(strand == "+") |>
  distinct(seqid, .keep_all = T)

all_sequences <- DNAStringSet()
for (i in 1:nrow(df)) {
  name <- paste0("^",df[[i, "seqid"]]) 
  assembly <- all[str_detect(all |> names(), name)]
  seq_i <- subseq(assembly, start = df[[i, "start"]], end = df[[i, "end"]])
  all_sequences <- c(all_sequences, seq_i)
  print(i)
}

new_name <- c()
for (i in 1:length(all_sequences)) {
  name <- all_sequences[i] |> names() |> str_split(" ")
  new_name <- c(new_name, paste0(name[[1]][1],"_",str_to_lower(name[[1]][2]),"_",name[[1]][3]))
}

names(all_sequences) <- new_name

alignment <- AlignSeqs(all_sequences)

distances <- DistanceMatrix(alignment, 
                            correction = "Jukes-Cantor",
                            type = "dist", 
                            verbose = TRUE)
tree <- nj(distances)

genus_info <- tibble(label = new_name) |>
  mutate(genus = case_when(  
  str_detect(label, "pseudomonas") ~ 1,
    str_detect(label, "escherichia") ~ 2,
    str_detect(label, "staph") ~ 3,
    str_detect(label, "aerogen") ~ 4,
    TRUE ~ 5
  ) |> as.factor())

ggtree(tree, layout = "circular", branch.length = "none") %<+% genus_info +
  geom_tree(aes(color=genus)) +
  geom_tiplab(aes(color=genus),size = 4) +
  geom_nodelab(aes(color=genus)) +
  theme(legend.position = "none")
```
</details>


## Acknowledgement 
I would like to thank Jonathan Ryder and Joseph Marcus for their assistance in choosing the best looking phylo tree as a feature for this blog! And also provided me the space to bounce off some ideas and theory of phylogenetic analysis. Much appreciated! 🙌 

## Opportunities for improvement {#opportunity}
- will perform a deeper dive on dynamic programming (alignment method)
- will perform a deeper dive on distance calculation 
- to include both + and - strand from barrnap output, so not to miss out of some 16s extraction
- use more `ggtree`, I do see potential. Rendering is slow for large dataset though 
- learn when to use appropriate layout for different questions to be answered
- maybe look into candida species with all the name changes, is it because of phlogeny? would it make more sense looking it through the lens of phylogeny? 
- use this technique in simulated contact tracing (might use [evo2](https://github.com/ArcInstitute/evo2) for genome inferences)
- learn how close does a bacteria need to be wither another in terms of node to be considered as similar to each other. ?1 node ?2 nodes. [read this](https://pmc.ncbi.nlm.nih.gov/articles/PMC10269621/)
- Go through John Blishak's `differential expression analysis with llama in R` course
- Will give [taxon2tree by Brian O'Meara](https://bomeara.github.io/taxon2tree/) a try

## Lessons Learnt {#lesson}
- learnt the basic workflow of phylogenetic analysis
- learnt and used `barrnap` an external tool for a quicker 16s rRNA extraction
- learnt and used `rapidnj` for neighbor joining for large dataset
- learnt and used `FigTree` for visualizing large phylogenetic tree. And it has a GUI!
- learnt a bit of `ggtree` to add colors to a phylo tree
- learnt to use `<details><summary>click here</summary>texts to hide by default</details>` to hide code chunks to decluster!

If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
