    ////////////////////////////
   //     Modules to remove: //
  //          Adaptors      //
 //         (5'& 3'ends)   //
////////////////////////////

//Cut reverse adaptors
process cutAdaptRev{
    //publishDir  params.outdir_cutrev, mode: 'copy'
    label 'cutadapt'

    input:
    tuple(
      file(for_cut),
      val(id))
    file(primrev)

    output:
    tuple(file("*.cutadapt.fa.gz"),
    val(id))



    script:
    """
    cutadapt -a  file:$primrev \
    -m $params.min_rev_len \
    -O $params.rev_overlap \
    -o ${id}.cutadapt.fa.gz \
    --discard-untrimmed \
    -j $params.cutadp_threads \
    $for_cut 2>&1 | tee ${id}.log
    """
}