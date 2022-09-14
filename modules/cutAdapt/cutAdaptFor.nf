    ////////////////////////////
   //     Modules to remove: //
  //          Adaptors      //
 //         (5'& 3'ends)   //
////////////////////////////

//Cut forward adaptors
process cutAdaptFor{
    //publishDir  path: params.outdir_cutfwd, mode: 'copy'
    label 'cutadapt'

    input:
    tuple(val(id),
    file(reft_seq))
    file(primfwd)

    output:
    tuple(
      file('*_rev.fa.gz'),
      val(id)
    )
    script:
    """
    cutadapt -g file:$primfwd \
    -O $params.fwd_overlap \
    -o ${id}_rev.fa.gz \
    -m $params.min_fwd_len \
    $reft_seq \
    --discard-untrimmed \
    -j $params.cutadp_threads 2>&1 | tee ${id}.logfile
    """
}