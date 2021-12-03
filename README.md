# MycoSNP Workflows

## Overview
MycoSNP is a portable workflow for performing whole genome sequencing analysis of fungal organisms, including Candida auris. This method prepares the reference, performs quality control, and calls variants using a reference. MycoSNP generates several output files that are compatible with downstream analytic tools, such as those for used for phylogenetic tree-building and gene variant annotations. 

MycoSNP (version 0.22) includes the following set of three GeneFlow workflows:

1. MycoSNP BWA Reference:
    * https://github.com/CDCgov/mycosnp-bwa-reference
    * Prepares a reference FASTA file for BWA alignment and GATK variant calling by masking repeats in the reference and generating the BWA index.
2. MycoSNP BWA Pre-Process:
    * https://github.com/CDCgov/mycosnp-bwa-pre-process
    * Prepares samples (paired-end FASTQ files) for GATK variant calling by aligning the samples to a BWA reference index and ensuring that the BAM files are correctly formatted. This step also provides different quality reports for sample evaluation. 
3. MycoSNP GATK Variants:
    * https://github.com/CDCgov/mycosnp-gatk-variants
    * Calls variants and generates a multi-FASTA file. 
    * Calls variants.
    * Generates individual vcf files for each sample, which can be used for gene variant annotation.
    * Generates a multi-FASTA file, which can be used to build phylogenetic trees. 


This repository contains installation instructions common for all workflows. 

## Requirements

To run any of the three workflows, please ensure that your computing environment meets the following requirements:

1. Linux Operating System

2. Git

3. SquashFS, required for executing Singularity containers - Most standard Linux distributions have SquashFS installed and enabled by default. However, in the event that SquashFS is not enabled, we recommend that you check with your system administrator to install it. Alternatively, you can enable it by following these instructions (warning: these docs are for advanced users): https://www.tldp.org/HOWTO/html_single/SquashFS-HOWTO/

4. Python 3+

5. Singularity

6. GeneFlow (https://github.com/CDCgov/geneflow2, install instructions below)

7. DRMAA library, required for executing the workflow in an HPC environment

## Quick Installation - Recommended

```bash
git clone https://github.com/CDCgov/mycosnp.git
cd mycosnp
bash run-mycosnp-single.sh -I
bash run-mycosnp-single.sh -o testresults
```

This should install geneflow under a python virtual environment in the "gfpy" directory and the appropriate workflows into the workflows directory, as well as run some test data through the workflows to determine if everything is working correctly.

## Manual Installation

This section outlines how to perform a manual install if needed. It is recommended to just use the provided run-mycosnp-single.sh script which will perform the installation outlined in this section.

First install GeneFlow and its dependencies as follows:

1. Create a Python virtual environment to install dependencies and activate that environment.

    ```bash
    mkdir -p ~/mycosnp
    cd ~/mycosnp
    python3 -m venv gfpy
    source gfpy/bin/activate
    ```

2. Install GeneFlow.

    ```bash
    pip3 install geneflow
    ```

3. Install the Python DRMAA library if you need to execute the workflow in an HPC environment. Skip this step if you do not need HPC.

    ```bash
    pip3 install drmaa
    ```

4. Install and run any of the three MycoSNP workflows by following the instructions for each workflow:

    * MycoSNP BWA Reference: https://github.com/CDCgov/mycosnp-bwa-reference
    * MycoSNP BWA Pre-Process: https://github.com/CDCgov/mycosnp-bwa-pre-process
    * MycoSNP GATK Variants: https://github.com/CDCgov/mycosnp-gatk-variants

    ```bash
    # From within mycosnp directory
    # source gfpy/bin/activate # If not already
    gf install-workflow --make-apps --git-branch v0.22 -f -g https://github.com/CDCgov/mycosnp-bwa-reference workflows/mycosnp-bwa-reference/0.22
    gf install-workflow --make-apps --git-branch v0.22 -f -g https://github.com/CDCgov/mycosnp-bwa-pre-process workflows/mycosnp-bwa-pre-process/0.22
    gf install-workflow --make-apps --git-branch v0.22 -f -g https://github.com/CDCgov/mycosnp-gatk-variants workflows/mycosnp-gatk-variants/0.22

    ```
## Usage

Once installed, the set of workflows can most easily be run using the wrapper script which will run each of the three workflows in succession.

```bash
bash run-mycosnp-single.sh -o ~/my-mycosnp-results/test-results -r demo/c_auris_test.fasta -i demo/fastq -v 0.22
```

See options for run-mycosnp-single.sh using the -h and -H options


```bash
# Wraper script help/options
bash run-mycosnp-single.sh -h

Usage: run-mycosnp-single.sh [ -r <reference fasta> ] [ -i <fastq input directory> ] [ -o <output directory: ./output> ] ...
   [ -x <result name prefix: result> ]
   [ -v <mycosnp version: 0.22> ]
   [ -w <work directory: ./work> ] * work directory can be removed after successful analysis.

   [ -d <bwa-preprocess coverage-option: 70> ]
   [ -D <bwa-preprocess rate-option: 1.0> ] 
   ... If rate is specified, then coverage is ignored. rate specifies the rate for downsampling FASTQ files. A rate of 1.0 indicates that 100% of reads in the FASTQ files are retained, which effectively "skips" downsampling. If coverage is specified and rate is not specified, coverage is used to calculate a downsampling rate that results in the specified coverage. For example if coverage 70, then FASTQ files are downsampled such that, when aligned to the reference, the result is approximately 70x coverage. 

   [ -p <gatk ploidy: 1> ] Ploidy of sample
   [ -f <gatk filter expression: "QD < 2.0 || FS > 60.0 || MQ < 40.0 || DP < 10"> ]
   ... Filter criteria for variants

   [ -a <gatk max_perc_amb_samples: 10> ]
   ... Max percent of samples with ambiguous calls for inclusion

   [ -A <gatk max_amb_samples: 1000000> ]
   ... Max number of samples with ambiguous calls for inclusion

   [ -g <git host root> ] 
   [ -c <execution type [gridengine/slurm/local]: local> ] 
   [ -q <cluster queue name: all.q> ] 

   [ -I Install workflows ]
   .. Can be used with -v to install specific version, otherwise the default will be installed

   [ -1 Run Step one only ] Prepare Reference Files
   [ -2 Run Step two only (requires step one run with same input/output settings) ] Mapping
   [ -3 Run Step three only (requires step one/two run with same input/output settings) ] Variant Calling

   [ -H print this help message ]
   [ -m print geneflow help messages for all of the workflows ]

== Installation ==

This script must first install dependencies before being run. Dependencies would also be installed 
if they do not exist on first run of the script. To install run:

  bash run-mycosnp-single.sh -I

This will install geneflow and the appropriate workflows into the script directory.

== Testing ==
Test the installation with the demo data.

 bash run-mycosnp-single.sh -o testresults

Results will be stored in the directory indicated with -o.

== Running ==

This script will run the following workflows in succession.
    * MycoSNP BWA Reference: https://github.com/CDCgov/mycosnp-bwa-reference
    * MycoSNP BWA Pre-Process: https://github.com/CDCgov/mycosnp-bwa-pre-process
    * MycoSNP GATK Variants: https://github.com/CDCgov/mycosnp-gatk-variants

To view the helpfiles for the workflows you can use the -H flag.

Note: Either the prefix (-x) or the output directory (-o) must be unique for each run.

To run an analysis, you only need a reference file in fasta format, and a set of directories with fastq files (R1/R2). Each directory
will be analyzed as a separate sample, or each unique pair of fastq files.

Example:
bash run-mycosnp-single.sh -r demo/c_auris_test.fasta -i demo/fastq -o demo-results

```

Individual help for the workflows can be accessed with the -H argument.
```
# Workflow help descriptions - Note: options are accessed via the wrapper script arguments
bash run-mycosnp-single.sh -H

```
## Output Analysis
The results will be present in three separate directories, one for each step of the workflow.

### *** results-mycosnp-bwa-reference ***

#### bwa_index  
BWA index files for the fasta reference.

#### index_reference
The index files from picard CreateSequenceDictionary.

### *** results-mycosnp-bwa-pre-process ***

#### bam_index
Mapping bam files for each sample.

#### fastqc_bam  
FastQC report of the mapped/filtered reads.

#### multiqc  
A MultiQC report file, showing the quality of the reads and mapping results.

#### qc_report  
A text report of mapping results for each sample.

#### qc_trim  
Reads, trimmed based on qc settings.

#### qualimap
Qualimap output to determine the quality of the alignment. Results are better viewed in the multiqc report.

### *** results-mycosnp-gatk-variants ***

#### consensus  
Consensus file for each sample, with variants mapped back to the consensus sequence.

#### gatk-selectvariants  
Combined selected variants.

#### split-vcf-broad  
Full vcf files split into one per sample.

#### split-vcf-selectvariants  
Select filtered variants, split into one file per sample.

#### vcf-filter  
Combined, filtered variants in VCF format.

#### vcf-qc-report  
QC report showing the number of bases per sample for selected variants and how many of the bases are unknown (N) per sample

#### vcf-to-fasta
A multi-fasta file which includes variants from each sample. This file can be used to construct a tree showing sequence similarity between each of the sequences.

## Public Domain Standard Notice

This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice

The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice

This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)
and [Code of Conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice

Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice

This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices

Please refer to [CDC's Template Repository](https://github.com/CDCgov/template)
for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md),
[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md),
and [code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
