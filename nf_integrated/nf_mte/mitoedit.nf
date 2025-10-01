#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// params.inputs = "$projectDir/data/prots/*{1,2,3}.fa"
// params.filter = "$projectDir/assets/NO_FILE"

// process foo {
//   debug true
//   input:
//   path seq
//   path opt

//   script:
//   def filter = opt.name != 'NO_FILE' ? "--filter $opt" : ''
//   """
//   echo your_command --input $seq $filter
//   """
// }

// workflow {
//   prots_ch = Channel.fromPath(params.inputs, checkIfExists:true)
//   opt_file = file(params.filter, checkIfExists:true)

//   foo(prots_ch, opt_file)
// }

params.bystander = "$projectDir/NO_FILE"

process MITOEDIT {
    conda params.conda_mte_env  // Update with the path to your conda environment file if needed
    publishDir params.outdir, mode: 'copy'
    
    input:
    path mtdna_seq
    val position
    val base
    path bystander_file
    
    output:
    path "${params.output_prefix}*"
    
    script:
    def bystander = params.bystander_file != "NO_FILE" ? "--bystander_file ${bystander_file}" : ""
    """
    mitoedit \
        --mtdna_seq_path ${mtdna_seq} \
        ${position} \
        ${base} \
        --output_prefix ${params.output_prefix} \
        --min_spacer ${params.min_spacer} \
        --max_spacer ${params.max_spacer} \
        --array_min ${params.array_min} \
        --array_max ${params.array_max} \
        --filter ${params.mte_filter} \
        --cut_pos ${params.cut_pos} \
        ${bystander}
    """
}

workflow {
    // Create channels
    mtdna_seq_ch = Channel.fromPath(params.mtdna_seq_path, checkIfExists: true)
    position_ch = Channel.of(params.position)
    base_ch = Channel.of(params.base)
    bystander_ch = params.bystander_file ? Channel.fromPath(params.bystander_file, checkIfExists: true) : Channel.empty()

    // Run mitoedit
    MITOEDIT(
        mtdna_seq_ch,
        position_ch,
        base_ch,
        bystander_ch
    )
}