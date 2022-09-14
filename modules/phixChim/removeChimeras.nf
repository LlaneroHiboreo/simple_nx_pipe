     /////////////////////////////////
    //      Modules to Remove:     //
   //       ·phiX contaminant     //
  //        ·Human chimeras      //
 /////////////////////////////////

// remove chimeras
process chimeras{
  //publishDir  params.outdir_chimeras, mode: 'copy'
  label 'vsearch'

  input:
    tuple(
      file(rem_phix),
      val(id))
    file(chimers_db)

  output:
    file("*.nonchimeras.fa.gz")
    

  script:
  """
  vsearch --uchime_ref $rem_phix \
  --threads $params.chimera_threads \
  --db $chimers_db --nonchimeras ${id}.nonchimeras.fa.gz \
  --log ${id}.stats.log
  """
}