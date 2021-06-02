# MycoSNP Workflows

## Overview

MycoSNP (version 0.21) includes the following set of three GeneFlow workflows:

1. MycoSNP BWA Reference:
    * https://github.com/CDCgov/mycosnp-bwa-reference
    * Prepares a reference FASTA file for BWA alignment and GATK variant calling by masking repeats in the reference and generating the BWA index.
2. MycoSNP BWA Pre-Process:
    * https://github.com/CDCgov/mycosnp-bwa-pre-process
    * Prepares samples (paired-end FASTQ files) for GATK variant calling by aligning the samples to a BWA reference index and ensuring that the BAM files are correctly formatted.
3. MycoSNP GATK Variants:
    * https://github.com/CDCgov/mycosnp-gatk-variants
    * Calls variants and generates a multi-FASTA file. 

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

## Installation

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
