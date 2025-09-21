---
title: Exploring The Workflow of The Oxford Nanopore Technologies (ONT) from pod5 to Polished Asembly - A Note To Myself
author: Ken Koon Wong
date: '2025-09-21'
slug: ont-pod5
categories: 
- ont
- oxford nanopore technology
- minion
- epi2me
- dorado
- samtools
- flye
tags: 
- ont
- oxford nanopore technology
- minion
- epi2me
- dorado
- samtools
- flye
excerpt: "Hands-on with Oxford Nanopore workflow: pod5 → BAM → assembly! Processed M. tuberculosis from raw signals to complete genome using dorado + flye. Fascinating how thousands of contigs became one 4M+ bp sequence. Polishing question: when is it worth the compute time?"
---

> Hands-on with Oxford Nanopore workflow: pod5 → BAM → assembly! Processed M. tuberculosis from raw signals to complete genome using dorado + flye. Fascinating how thousands of contigs became one 4M+ bp sequence. Polishing question: when is it worth the compute time?

![](pod5_2.png)

## Motivations:
ONT Minion is really cool! I have been interested in this technology for a few months now and found it to have great potential. In case we have an opportunity to explore this technology, why not let's get familiar with the workflow, so that at least we're somewhat familiar with the workflow and prepared to process the sequence data! Let's explore! After somer reading, it seems like ONT produces a raw sequence file called `pod5`. And the file needs to be converted / processed to `fasta` or `fastq` format. 

## TL;DR Workflow
> basecall pod5 to BAM (`dorado`) > Convert BAM to fastq (`samtools`) > Assemble (`flye`) > Align (`dorado`) & Index (`samtools`) > Polish (`dorado`) 


## Objectives:
- [Find a pod5 file](#find)
  - [pod5viewer](#pod5viewer)
- [workflow](#wf)
  - [Basecall pod5 to BAM](#convert)
  - [Turn BAM into fastq](#fastq)
  - [Assemble with Flye](#flye)
  - [Align & Index](#align_index)
  - [Polish](#polish)
- [Other methods](#other)
- [Opportunities for improvement](#opportunity)
- [Lessons learnt](#lesson)

## Find a pod5 file {#find}
If I'm not mistaken, an ONT will return a `pod5` file. The way they capture the sequences is very interesting! Apparently each nucleotide, when passes through the pore, it changes the ionic current. And `pod5` basically records those signals. Each signal reflects multiple nucleotide. There is a python package where we can view the pod5 file called `pod5Viewer`. 

Now let's find one and download it. I found a [`mycobacterium tuberculosis` pod5](https://figshare.unimelb.edu.au/articles/dataset/AMtb_1_202402_pod5_data/25495045) from The University of Melbourne. And interestingly, there are 45 `pod5` for a single isolate. Very cool! But mostly what I saw from other pod5 files are usually just 1 big file. fyi, the zip file of pod5 was about 7 gb! Let's view one of the file.

### pod5viewer {#pod5viewer}

``` python
# install
conda create -n p5v python==3.10
conda activate p5v
pip install pod5Viewer

# run
pod5Viewer
```

You can open the pod5 file and inspect the raw signal like so. 

![](signal.png)
Interesting looking thing! Now, on to our first step of our workflow, basecalling! 

## Workflow {#wf}
### Basecall pod5 to BAM {#convert}
We can use `dorado` to convert the pod5 file to BAM format, like so.


``` bash
# installation
curl "https://cdn.oxfordnanoportal.com/software/analysis/dorado-1.1.1-osx-arm64.zip" -o dorado-1.1.1-osx-arm64.zip
unzip dorado-1.1.1-osx-arm64.zip
export PATH="/path/to/dorado-1.1.1-osx-arm64/bin:$PATH"

# basecall
dorado basecaller hac --device metal /path/to/your/pod5_files/ > mycobacterium_basecalled.bam
```

the `bam` file will be about 600mb. 

### Turn BAM into fastq {#fastq}

``` bash
# install
wget https://github.com/samtools/samtools/releases/download/1.22.1/samtools-1.22.1.tar.bz2
cd samtools-1.x   
./configure --prefix=/where/to/install
make
make install
export PATH=/where/to/install/bin:$PATH 

# convert
samtools fastq mycobacterium_basecalled.bam > mtb.fastq
```
Wow, the fastq is 1.4g. Let's take a look at the fastq! 

![](samtools.png)
Wow! So many contigs! Hmm, can we `mlst` this? Let's try.


``` bash
mlst mtb.fastq
```

![](mlst.png)

Wow, this already works pretty good! It was already identify `mycobacterium`. Because there are so many repeats, that's why we're seeing repeated loci profiles listed. Interestingly, some with different loci profile. Alright, our next step is to `assemble` and see if we make them into 1 longgggg sequence

### Assemble with Flye {#flye}

``` bash
# install
conda install flye

# assemble
flye --nano-hq mtb.fastq \
     --threads 10 \
     --out-dir mtb_assembly
```

That took a few minutes. Great! Let's go into our `mtb_assembly` folder and read the assembly.fasta

![](assembly.png)
Wow, look at that! One longgg contig! Hurray! Now let's run `mlst` again and then see what pops up. 


``` bash
mlst mtb_assembly/assembly.fasta
```


![](mlst_assemble.png)

![](mlst_mtb.png)

Pretty good. Same thing! Mycobacterium tuberculosis. Let's blast it with whole genome and see what pops up.


``` bash
blastn -query mtb_assemble/assembly.fasta -db /blast_db/ref_prok_rep_genomes -outfmt 6 -num_threads 10 -out mtb_wgs.txt
```


<details>
<summary>click to expand R code</summary>

``` r
library(tidyverse)

colnames <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

df <- read_tsv("mtb_wgs.txt", col_names = colnames)

sseqid_vec <- df |>
  arrange(desc(bitscore)) |>
  head(10) |>
  pull(sseqid)

system(paste0("blastdbcmd -db blast_db/ref_prok_rep_genomes -outfmt '%a %t' -entry ",paste(sseqid_vec, collapse = ",")))
```
</details>

![](wgs.png)

We're looking at arranged descending bitscore and top 10 results. Nine of 10 are Mtb, which is great! Wait a minute, there is something called Mycobacterium canettii. What is that !? Wow, at least [that's](https://en.wikipedia.org/wiki/Mycobacterium_canettii) an Mtb complex! Let's dive in a bit.


<details>
<summary>click to expand R code</summary>

``` r
seq_to_compare <- c("NC_000962.3","NC_015848.1")

df |> 
  filter(sseqid %in% seq_to_compare) |>
  group_by(sseqid) |>
  mutate(total_length = sum(length)) |>
  distinct(sseqid,total_length)
```
</details>

Wow, looking at the total length for both reference sequence, they have very wide coverage, `NC_000962.3` (Mtb) being the highest but M canettii isn't too bad either at 5047243! 

<p align="center">
  <img src="wgs_total_length.png" alt="image" width="50%" height="auto">
</p>

Alright, next is to `polish`! But before we can polish, we have to `align & index`. 

### Align & Index {#align_index}

``` bash

# align and create new aligned bam
dorado aligner mtb_assembly/assembly.fasta mycobacterium_basecalled.bam | samtools sort > aligned_mycobacterium.bam

# Index the new alignment
samtools index aligned_mycobacterium.bam
```

this should create 2 files, `aligned_mycobacterium.bam` and `aligned_mycobacterium.bam.bai`. Alright, so far so good! This process might be less than a minute. Next, we polish!

### Polish {#polish}

``` bash
dorado polish --device auto aligned_mycobacterium.bam mtb_assembly/assembly.fasta > polished_assembly.fasta
```

Looks like the current polish method does not allow `metal` to my knowledge. Maybe that might change. But still it wasn't bad, took a bout 1 hour for polishing. And we ended up with `35` additional nucleotides on the polish_assembly.

Which begs the question, why do we need to polish these assembly? 🤔 

![](polish_assembly.png)

Let's see if this changes anything in terms of blastn with whole genome.


``` bash
blastn -query polished_assembly.fasta -db /blast_db/ref_prok_rep_genomes -outfmt 6 -num_threads 10 -out mtb_wgs_polished.txt
```


<details>
<summary>click to expand R code</summary>

``` r
colnames <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

df <- read_tsv("mtb_wgs_polished.txt", col_names = colnames)

sseqid_vec <- df |>
  arrange(desc(bitscore)) |>
  head(10) |>
  pull(sseqid)

system(paste0("blastdbcmd -db blast_db/ref_prok_rep_genomes -outfmt '%a %t' -entry ",paste(sseqid_vec, collapse = ",")))
```
</details>

![](polish_blast.png)

No change! Bitscore didn't change either (not shown). Very interesting. I'm not exactly sure when do we need to use this post-assembly process. And what makes this "more" accurate? 

## Other Methods {#other}
[`Epi2me`](https://epi2me.nanoporetech.com/) has great workflow for automated selection with additional perks as well, including using `resfinder` to assess antimicrobial resistance genes etc. I've tried the command line, minimal coding. Does require installation of `Java`, `Nextflow`, and `Docker`. If you're using `mac` and has alert of [mac malware](https://docs.docker.com/desktop/cert-revoke-solution/?_gl=1*1lwz82l*_gcl_au*Mjk4NjQwMDUyLjE3NTgyMTM0Mzc.*_ga*MTgwNTA2ODY1Mi4xNzU4MjEzNDM3*_ga_XJWPQMJYHQ*czE3NTgyMTM0MzckbzEkZzEkdDE3NTgyMTQxNjQkajU5JGwwJGgw), click on this link to find out how to disable it. There is also a `GUI` version of epi2me, you can check that out as well, but it requires registration and login. I personally have not used that.  

On a side note, epi2me uses `medaka` for polishing and it's extremely slow on my computer. Unsure why and probably user error. Hence my workflow of using `dorado` for most of the tasks. I could essentially write a `R` script to automate all of the above. A project for the near future!

## Opportunities for improvement {#opportunity}
- Definitely looking forward to adding [`resfinder`](https://github.com/genomicepidemiology/resfinder) workflow to assess amr. Since this doesn't have a complete mycobacterium amr sequences, we may have to add another database that contains those such as [AMRfinder](https://www.ncbi.nlm.nih.gov/pathogens/antimicrobial-resistance/AMRFinder/)
- Explore [`prokka`](https://github.com/tseemann/prokka) for annotation
- Need to learn quality control
- need to learn what is the acceptable threshold to set for blastn when we're using it to identify isolate
- need to learn when to use `polish` and when not to

## Final Thoughts
That was fun exploring the raw sequence of ONT to constructing the workflow to process raw sequence to a polished assembly. Though this use case is probably not ideal for identification because most of the current less laborous technology such as PCR can already identify Mtb, this might be helpful for phylogenetic analysis and tree construction. Also might be helpful in assessing NTM. Since I couldn't find a raw sequence of NTM, I wasn't able to look into that... but it was fun going through a known MTB, MLST, and blast! 

## Lessons learnt {#lesson}
- learnt `pod5Viewer`, `dorado`, `flye`, `samtools`
- learnt to process raw ONT sequence to a polish assembly
- explore a bit on how we could use `resfinder` or other methods to explore AMR. this will be potentially helpful


If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
