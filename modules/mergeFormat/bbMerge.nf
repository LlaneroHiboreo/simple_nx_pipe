    ///////////////////////////////////////
  //Modules to merge seqs and remove Ns//
 ///////////////////////////////////////

//Merge sequence pairs
process bbMerge{
    //publishDir params.outdir_bbMerge, mode:'copy'
    label 'bbtools'

    input:
    tuple val(pair_id), path(reads)

    output:
    tuple(
        val(pair_id),
        file("*.fastq.gz"))

    script:
    r1 = reads.get(0)
    r2 = reads.get(1)

    script:
    """
    (bbmerge.sh -Xmx8500m in1=$r1 in2=$r2 out=${pair_id}.fastq.gz \
    minlength=$params.merged_min_len \
    merge=$params.merged_status \
    qtrim=$params.merged_qtrim \
    minq=$params.merged_minq \
    mismatches=$params.merged_mismatches) >  ${pair_id}.log 2>&1;
    """
}