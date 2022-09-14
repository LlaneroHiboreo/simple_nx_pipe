   ///////////////////////////////////////////////////
  //Processes for initial quality check of raw seqs//
 ///////////////////////////////////////////////////

//Get quality scores: fastqc
process fastQC{
  //publishDir params.outdir_fastqc, mode: 'copy'
  label 'fastqc'
  
  input:
  file(rawReads)

  output:
  file("*.zip")

  script:
  """
  fastqc -t 2 $rawReads
  """
}

