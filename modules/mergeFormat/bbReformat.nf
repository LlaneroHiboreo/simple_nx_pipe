//Remove N's from sequences
process bbReformat{
    //publishDir params.outdir_bbReformat
    label 'bbtools'

    input:
    tuple(val(id),
    file(reform))

    output:
    tuple(val(id),
    file("*.fastq.gz"))

    script:
    """
    (reformat.sh -Xmx8500m in=$reform \
      out=${id}.merged2.fastq.gz \
      maxns=$params.reformat_maxns) 2>&1 | tee ${id}_logfile
    """
}