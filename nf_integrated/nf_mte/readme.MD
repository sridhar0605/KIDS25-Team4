# Mitoedit Nextflow Module  
*Note:* requires having conda already installed in environment

## Set-up Mitoedit Nextflow  
1. Navigate to `nf_integrated`/`nf_mte`
2. Create conda environment: `conda create -n mte -f mte.yml`  

## Set test data variables or data of interest  
`INPUT_MTE_SEQ="NC_012920.1.txt"`  
`INPUT_TAB="test_WGS_output.tab"`  
`OUTPUT_MTE_PRE="test"`  
`BYSTANDER_INPUT=NO_FILE`

## Run Mitoedit module (standalone)  
`nextflow run mitoedit.nf \`  
`    --mtdna_seq_path ${INPUT_MTE_SEQ} --input_tab ${INPUT_TAB} \`  
`    --output_prefix ${OUTPUT_MTE_PRE} # --bystander_file ${BYSTANDER_INPUT}`
