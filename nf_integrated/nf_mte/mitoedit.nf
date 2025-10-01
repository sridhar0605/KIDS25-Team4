#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.bystander = "$projectDir/NO_FILE"

process MITOEDIT {
    conda params.conda_mte_env
    errorStrategy 'ignore'  // Skip failed MITOEDIT runs

    publishDir "${params.outdir}/mitoedit_results", mode: 'copy', overwrite: true

    input:
    tuple val(row_data), val(position), val(base), val(test_base)
    path mtdna_seq
    path bystander_file
    
    output:
    tuple val(row_data), val(test_base), path("talen_output_${position}_${test_base}.txt"), optional: true
    
    script:
    def bystander = bystander_file.name != "NO_FILE" ? "--bystander_file ${bystander_file}" : ""
    """
    set +e
    mitoedit \
        --mtdna_seq_path ${mtdna_seq} \
        ${position} \
        ${test_base} \
        --output_prefix tmp_output \
        --min_spacer ${params.min_spacer} \
        --max_spacer ${params.max_spacer} \
        --array_min ${params.array_min} \
        --array_max ${params.array_max} \
        --filter ${params.mte_filter} \
        --cut_pos ${params.cut_pos} \
        ${bystander} 2>/dev/null
    
    # Rename output to include position and base for tracking
    if [ -f tmp_output/talen_output.txt ]; then
        mv tmp_output/talen_output.txt talen_output_${position}_${test_base}.txt
        rm -r tmp_output
    fi

    # Omit errors since most will fail
    exit 0
    """
}

process COMBINE_RESULTS {
    conda params.conda_mte_env
    publishDir params.outdir, mode: 'copy'
    
    input:
    path input_tab
    path 'mitoedit_results/*'
    
    output:
    path "${params.output_prefix}_combined.tab"
    
    script:
    """
    #!/usr/bin/env python3
    import pandas as pd
    import glob
    import os
    
    # Read original input
    input_df = pd.read_csv("${input_tab}", sep='\\t')
    
    # Read all MITOEDIT talen_output results
    result_files = glob.glob('mitoedit_results/talen_output_*.txt')
    
    results = []
    for talen_file in result_files:
        # Extract position and base from filename
        basename = os.path.basename(talen_file)
        # Expected format: talen_output_{position}_{base}.txt
        parts = basename.replace('.txt', '').split('_')
        position = int(parts[2])
        test_base = parts[3]
        
        # Read MITOEDIT talen_output (assuming tab-separated)
        talen_df = pd.read_csv(talen_file, sep='\\t')
        
        # Find corresponding row in input
        input_row = input_df[input_df['Pos'] == position].iloc[0].to_dict()
        
        # For each row in talen_output, duplicate the input row data
        for idx, talen_row in talen_df.iterrows():
            combined_row = input_row.copy()
            combined_row['Tested_Base'] = test_base
            # Add all columns from talen_output
            for col, val in talen_row.items():
                combined_row[col] = val
            results.append(combined_row)
    
    # Combine all results
    if results:
        combined_df = pd.DataFrame(results)
        # Reorder columns: input columns, Tested_Base, then talen columns
        input_cols = list(input_df.columns)
        talen_cols = [c for c in combined_df.columns if c not in input_cols and c != 'Tested_Base']
        final_cols = input_cols + ['Tested_Base'] + talen_cols
        combined_df = combined_df[final_cols]
        combined_df.to_csv("${params.output_prefix}_combined.tab", sep='\\t', index=False)
    else:
        # Create empty output if no results
        pd.DataFrame().to_csv("${params.output_prefix}_combined.tab", sep='\\t', index=False)
    """
}

workflow {
    // Read input tab file and create channel
    input_tab = Channel.fromPath(params.input_tab, checkIfExists: true)
    
    // Parse tab file and create a channel with one item per row and test base
    rows_ch = input_tab
        .splitCsv(header: true, sep: '\t')
        .flatMap { row ->
            def pos = row.Pos
            def alt_allele = row.Alternative_allele
            def bases = ['A', 'C', 'T', 'G']
            
            // Generate test bases (all except the alternative allele)
            bases.findAll { it != alt_allele }.collect { test_base ->
                [row, pos, alt_allele, test_base]
            }
        }
    
    // Create file channels
    mtdna_seq_ch = Channel.fromPath(params.mtdna_seq_path, checkIfExists: true)
    bystander_ch = file(params.bystander_file)
    
    // Run MITOEDIT in parallel for each row/base combination
    mitoedit_results = MITOEDIT(
        rows_ch,
        mtdna_seq_ch.first(),
        bystander_ch
    )
    
    // Collect all results and combine
    COMBINE_RESULTS(
        input_tab.first(),
        mitoedit_results.map { it[2] }.collect()
    )
}