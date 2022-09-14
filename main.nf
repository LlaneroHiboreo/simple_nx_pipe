              /////////////
             //MAIN FLOW//
            /////////////

//Code implemented on dsl v.2
nextflow.enable.dsl=2

//IMPORT MODULES
include { fastQC; } from './modules/qualityControl/fastQC.nf'
include { multiQC;} from './modules/qualityControl/multiQC.nf'
include { bbMerge;  } from './modules/mergeFormat/bbMerge.nf'
include { bbReformat; } from './modules/mergeFormat/bbReformat.nf'
include { merforQC; } from './modules/mergeFormat/merforQC.nf'
include { cutAdaptFor; } from './modules/cutAdapt/cutAdaptFor.nf'
include { cutAdaptRev;} from './modules/cutAdapt/cutAdaptRev.nf'
include { remPhix; } from './modules/phixChim/removePhix.nf'
include { chimeras; } from './modules/phixChim/removeChimeras.nf'

// Check for empty files
if (file(params.input_path)){
  ch_input_path_qc = Channel.fromPath("${params.input_path}", checkIfExists: true)
} else{ exit 1, 'Specify input_path for raw sequences! e.g: input_path =  <$baseDir/RawData/*.fastq.gz>'}

if (file(params.pairs_path)){
  ch_input_pairs = Channel.fromFilePairs("${params.pairs_path}")
} else{ exit 1, 'Specify input_path for pair raw sequences! e.g: pairs_path =  <$baseDir/RawData/*_{R1,R2}.fastq.gz>'}

//filter input channels
ch_input_path_qc.branch{
    empty: it.size() < 1.KB
    correct: it.size() >= 1.KB
  }.set{
    ch_filtered_seqs
    }

ch_filtered_seqs.empty.subscribe{
    samples = it.join("\n")
    log.error "[qualityControl] - The following input samples had too small file size (<1KB):\n$samples\n\n[bbMERGE] - PAIR NOT TAKEN"
}

//WORKFLOW COMPOSITION

//1st Phase: Fastqc and multiQC to check initial quality
workflow qualityControl{
  take:
    rawSeqs
  main:
    //quality control
    fastQC(rawSeqs) | collect | multiQC
}

//2nd Phase: Merge reads and remove N's
workflow mergeFormat{
  take:
    rawSeqs
  main:
    bbMerge(rawSeqs) | bbReformat | merforQC
  emit:
    bbReformat.out
}

//3rd Phase: Remove Adaptors
workflow cutAdapt{
  take:
    reformatedSeqs
    primers
    primersrev
  main:
    cutAdaptFor(reformatedSeqs, primers) | set{ch_fwd}
    //----
    cutAdaptRev(ch_fwd, primersrev)
  emit:
    cutAdaptRev.out
}

//4th Phase: Remove phiX contaminant and remove chimeras
workflow phixChim{
  take:
    trimmedSeqs
    adaptersdb
    chimersdb
  main:
    remPhix(trimmedSeqs, adaptersdb) | set{ch_x}
    //----
    chimeras(ch_x, chimersdb)
  emit:
    contaminant =   remPhix.out
    chimeras    =   chimeras.out
}

/*PIPE SUBWORKFLOWS USING MAIN WORKFLOW*/
workflow{
    //Phase 1
    qualityControl(
      ch_filtered_seqs.correct
    )

    //Phase 2
    mergeFormat(
      ch_input_pairs.filter{ name, files -> files.every { it.size() > 5 }}
    )

    //Phase 3
    cutAdapt(
      mergeFormat.out,
      Channel.fromPath(params.fwd_prim).first(),
      Channel.fromPath(params.rev_prim).first()
    )

    //Phase 4
    phixChim(
      cutAdapt.out,
      Channel.fromPath(params.phix_adapters).first(),
      Channel.fromPath(params.chimers_db).first()
    )
}