#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###### Defaults ######

VER=0.22
OUTDIR=output
NAMEPRE=result
THREADS=4
REF="${SCRIPT_DIR}/demo/c_auris_test.fasta"
INPUTFOLDER="${SCRIPT_DIR}/demo/fastq"
WORKDIR=work
CTYPE="local"
INSTALLONLY=""
QUEUE="all.q"
RATE="1.0"
COV="70"
GFIL="QD < 2.0 || FS > 60.0 || MQ < 40.0 || DP < 10"
GAMBNN="1000000"
AMB="10"
PLOIDY="1"
export GENEFLOW_PATH="${SCRIPT_DIR}"
RUNPARTIAL=""
RUNONE=""
RUNTWO=""
RUNTHREE=""

GITHOST="https://github.com/CDCgov"



usage() {                                 # Function: Print a help message.
  echo "
Usage: $0 [ -r <reference fasta> ] [ -i <fastq input directory> ] [ -o <output directory: ./output> ] ...
   [ -x <result name prefix: result> ]
   [ -v <mycosnp version: 0.22> ]
   [ -w <work directory: ./work> ] * work directory can be removed after successful analysis.

   [ -d <bwa-preprocess coverage-option: 70> ]
   [ -D <bwa-preprocess rate-option: 1.0> ] 
   ... If rate is specified, then coverage is ignored. rate specifies the rate for downsampling FASTQ files. A rate of 1.0 indicates that 100% of reads in the FASTQ files are retained, which effectively \"skips\" downsampling. If coverage is specified and rate is not specified, coverage is used to calculate a downsampling rate that results in the specified coverage. For example if coverage 70, then FASTQ files are downsampled such that, when aligned to the reference, the result is approximately 70x coverage. 

   [ -p <gatk ploidy: 1> ] Ploidy of sample
   [ -f <gatk filter expression: \"QD < 2.0 || FS > 60.0 || MQ < 40.0 || DP < 10\"> ]
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


   " 1>&2
}

exit_abnormal() {                         # Function: Exit with error.
  usage
  exit 1
}


while getopts ":r:i:o:x:w:v:g:c:q:D:a:d:f:A:p:HIh123" options; do

  case "${options}" in
    i)
      INPUTFOLDER=${OPTARG}
      ;;
    r)
      REF=${OPTARG}
      ;;
    o)
      OUTDIR=${OPTARG}
      ;;
    x)
      NAMEPRE=${OPTARG}
      ;;
    w)
      WORKDIR=${OPTARG}
      ;;
    v)
      VER=${OPTARG}
      ;;
    g)
      GITHOST=${OPTARG}
      ;;
    c)
      CTYPE=${OPTARG}
      ;;
    q)
      QUEUE=${OPTARG}
      ;;
    D)
      RATE=${OPTARG}
      ;;
    p)
      PLOIDY=${OPTARG}
      ;;
    a)
      AMB=${OPTARG}
      ;;
    d)
      COV=${OPTARG}
      ;;
    f)
      GFIL=${OPTARG}
      ;;
    A)
      GAMBNN=${OPTARG}
      ;;
    H)
      PRINTMESS=true
      ;;
    1)
      RUNPARTIAL=true
      RUNONE=true
      ;;
    2)
      RUNPARTIAL=true
      RUNTWO=true
      ;;
    3)
      RUNPARTIAL=true
      RUNTHREE=true
      ;;
    I)
      INSTALLONLY=true
      ;;
    h)
      usage
      exit 0;
      ;;
    :)                                    # If expected argument omitted:
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal                       # Exit abnormally.6
      ;;
    *)                                    # If unknown (any other) option:
      exit_abnormal                       # Exit abnormally.
      ;;
  esac
done

###### Install and/or Activate Geneflow ######

GFDIR="${SCRIPT_DIR}/gfpy"
if [[ ! -d ${GFDIR} ]]; then
  python3 -m venv ${GFDIR}
  source ${GFDIR}/bin/activate
  pip3 install geneflow
  pip3 install drmaa
else
  source ${GFDIR}/bin/activate
  export DRMAA_LIBRARY_PATH=/opt/sge/lib/lx-amd64/libdrmaa2.so
fi


###### Install workflows if they do not exist ###### 

if [[ ! -d "${SCRIPT_DIR}/workflows/mycosnp-bwa-reference/${VER}" ]]; then
 gf install-workflow --make-apps --git-branch v${VER} -f -g ${GITHOST}/mycosnp-bwa-reference.git ${SCRIPT_DIR}/workflows/mycosnp-bwa-reference/${VER}
fi

if [[ ! -d "${SCRIPT_DIR}/workflows/mycosnp-bwa-pre-process/${VER}" ]]; then
 gf install-workflow --make-apps --git-branch v${VER} -f -g ${GITHOST}/mycosnp-bwa-pre-process.git ${SCRIPT_DIR}/workflows/mycosnp-bwa-pre-process/${VER}
fi

if [[ ! -d "${SCRIPT_DIR}/workflows/mycosnp-gatk-variants/${VER}" ]]; then
 gf install-workflow --make-apps --git-branch v${VER} -f -g ${GITHOST}/mycosnp-gatk-variants.git ${SCRIPT_DIR}/workflows/mycosnp-gatk-variants/${VER}
fi


if [[ "${PRINTMESS}" == "true" ]]
then
    echo ""
    echo ""
    echo "======== MycoSNP BWA Reference Help ========"
    geneflow help ${SCRIPT_DIR}/workflows/mycosnp-bwa-reference/${VER}
    echo ""
    echo ""
    echo "======== MycoSNP BWA Pre Process Help ========"
    geneflow help ${SCRIPT_DIR}/workflows/mycosnp-bwa-pre-process/${VER}
    echo ""
    echo ""
    echo "======== MycoSNP GATK Variants Help ========"
    geneflow help ${SCRIPT_DIR}/workflows/mycosnp-gatk-variants/${VER}
    exit 1;
fi

if [[ "${INSTALLONLY}" == "true" ]]
then
    echo "Installation Complete."
    exit;
fi

###### Additional Options ######

ADDLOPTIONS=("")
  echo "Using Execution Type ${CTYPE}"
ADDLOPTIONS+=("--ec default:${CTYPE}")
ADDLOPTIONS+=("--ep default.slots:${THREADS}")
ADDLOPTIONS+=("'default.init:echo \`hostname\` && mkdir -p \$HOME/tmp && export TMPDIR=\$HOME/tmp && export _JAVA_OPTIONS=-Djava.io.tmpdir=\$HOME/tmp && export PATH=/usr/sbin:\$PATH && export XDG_RUNTIME_DIR='")
ADDLOPTIONS+=("'default.other:-l avx -v PATH'")
if [[ "${CTYPE}" == "gridengine" ]] || [[ "${CTYPE}" == "slurm" ]]
then
  ADDLOPTIONS+=("'default.queue:${QUEUE}@@sd'")
fi

echo RP ${RUNPARTIAL} 1 ${RUNONE} 2 ${RUNTWO} 3 ${RUNTHREE}


###### mycosnp-bwa-reference ######

if [[ -d "${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference" ]]
then
    echo "Output directory (${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference) already exists! Skipping! Remove directory if you want to repeat this analysis."
elif ( [[ "${RUNPARTIAL}" == "true" && "${RUNONE}" != "true" ]] )
then
    echo "Skiping mycosnp-bwa-reference"
else

##### Check for existance of files/folders #####

if [[ ! -f "${REF}" ]]
then
  echo "Reference file ${REF} DOES NOT exist!!!"
  exit 1;
fi

  command1="gf --log-level debug run workflows/mycosnp-bwa-reference/${VER} \
    -o \"${OUTDIR}\" \
    -w \"${WORKDIR}\" \
    -n ${NAMEPRE}-mycosnp-bwa-reference \
    --in.reference_sequence \"${REF}\"  \
    --no-output-hash \
    --param.threads ${THREADS} ${ADDLOPTIONS[@]}"
    
    echo ""
    echo "Running: $command1";
    eval "$command1"
fi

####### mycosnp-bwa-pre-process ######

if [[ -d "${OUTDIR}/${NAMEPRE}-mycosnp-bwa-pre-process" ]]
then
    echo "Output directory (${OUTDIR}/${NAMEPRE}-mycosnp-bwa-pre-process) already exists! Skipping! Remove directory if you want to repeat this analysis."
elif ( [[ "${RUNPARTIAL}" == "true" && "${RUNTWO}" != "true" ]] )
then
    echo "Skiping mycosnp-bwa-pre-process"
else

  ##### Check for existance of files/folders #####

  if [[ ! -d  "${INPUTFOLDER}" ]]
  then
    echo "Input Folder for mycosnp-bwa-pre-process DOES NOT exist"
    exit 1;
  fi
  
  if [[ ! -d  "${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference/bwa_index/bwa_index" ]]
  then
    echo "Reference Sequence Index for mycosnp-bwa-pre-process DOES NOT exist"
    exit 1;
  fi

  if [[ ! -f  "${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference/index_reference/indexed_reference/indexed_reference.fasta" ]]
  then
    echo "Indexed Reference Fasta for mycosnp-bwa-pre-process DOES NOT exist"
    exit 1;
  fi

  command2="gf --log-level debug run workflows/mycosnp-bwa-pre-process/${VER} \
    -o \"${OUTDIR}\" \
    -w \"${WORKDIR}\" \
    -n ${NAMEPRE}-mycosnp-bwa-pre-process \
    --in.input_folder \"${INPUTFOLDER}\" \
    --in.reference_index \"${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference/bwa_index/bwa_index\" \
    --in.reference_sequence \"${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference/index_reference/indexed_reference/indexed_reference.fasta\" \
    --param.coverage ${COV} \
    --param.rate ${RATE} \
    --no-output-hash \
    --param.threads ${THREADS} ${ADDLOPTIONS[@]}"
    
    echo "";
    echo "Running: $command2";
    eval "$command2"
   

fi

###### mycosnp-gatk-variants ######

if [[ -d "${OUTDIR}/${NAMEPRE}-mycosnp-gatk-variants" ]]
then
    echo "Output directory (${OUTDIR}/${NAMEPRE}-mycosnp-gatk-variants) already exists! Skipping! Remove directory if you want to repeat this analysis."
elif ( [[ "${RUNPARTIAL}" == "true" && "${RUNTHREE}" != "true" ]] )
then
    echo "Skiping mycosnp-gatk-variants"
else

  ##### Check for existance of files/folders #####

  if [[ ! -d "${OUTDIR}/${NAMEPRE}-mycosnp-bwa-pre-process/bam_index" ]]
  then
    echo "Input Folder for mycosnp-gatk-variants DOES NOT exist"
    exit 1;
  fi

  if [[ ! -d "${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference/index_reference/indexed_reference" ]]
  then
    echo "Indexed reference files for mycosnp-gatk-variants DOES NOT exist"
    exit 1;
  fi

  command3="gf --log-level debug run workflows/mycosnp-gatk-variants/${VER} \
    -o \"${OUTDIR}\" \
    -w \"${WORKDIR}\" \
    -n ${NAMEPRE}-mycosnp-gatk-variants \
    --in.input_folder \"${OUTDIR}/${NAMEPRE}-mycosnp-bwa-pre-process/bam_index\" \
    --in.reference_sequence \"${OUTDIR}/${NAMEPRE}-mycosnp-bwa-reference/index_reference/indexed_reference\" \
    --param.max_perc_amb_samples ${AMB} \
    --param.max_amb_samples ${GAMBNN} \
    --param.sample_ploidy ${PLOIDY} \
    --param.filter_expression \"${GFIL}\" \
    --param.pair_hmm_threads ${THREADS} \
    --no-output-hash ${ADDLOPTIONS[@]}"

    echo ""
    echo "Running: $command3";
    eval "$command3"
fi

