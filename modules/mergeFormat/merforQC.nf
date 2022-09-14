//Make quality fastqc of merged and reformated seqs
process merforQC{
    publishDir path: params.outdir_merforQC, mode: 'copy'
    label 'fastqc'

    input:
    tuple(val(id),
    file(reformat))

    output:
    file "*.{zip, html}"

    script:
    """
    fastqc -t $params.threads_fastqc $reformat
    """
}