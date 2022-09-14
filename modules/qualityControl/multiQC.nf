   ///////////////////////////////////////////////////
  //Processes for initial quality check of raw seqs//
 ///////////////////////////////////////////////////

//Results into single report: multiqc
process multiQC{
    publishDir params.outdir_multiqc
    label 'multiqc'

    input:
    file(multiqc)

    output:
    file "$params.output_multiqc"

    script:
    """
    multiqc -z $multiqc -o $params.output_multiqc
    """
}