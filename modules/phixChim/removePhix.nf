     /////////////////////////////////
    //      Modules to Remove:     //
   //       ·phiX contaminant     //
  //        ·Human chimeras      //
 /////////////////////////////////
process remPhix{
  //publishDir  params.outdir_remphix, mode: 'copy'
  label 'bbtools'

  input:
    tuple(
      file(cut_primmers),
      val(id)
      )
    file(adapters)

  output:
    tuple(
      file("*.non-contm.fna.gz"),
      val(id)
    )

  script:
  """
  bbduk.sh -Xmx500m in=$cut_primmers \
  out=${id}.non-contm.fna.gz \
  ref=$adapters \
  k=$params.kmers stats=${id}_log
  """
}