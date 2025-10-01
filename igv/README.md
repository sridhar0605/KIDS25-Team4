# IGV-Reports

[![PyPI version](https://badge.fury.io/py/igv-reports.svg)](https://badge.fury.io/py/igv-reports)
[![Install with Bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io/recipes/igv-reports/README.html)

IGV-Reports is a Python application that generates self-contained HTML pages embedding Interactive Genomics Viewer (IGV) visualizations. These reports include tables of genomic sites or regions with associated IGV views, designed for visual variant review. The output HTML files are static and require no dependency on the original input files, as all necessary data (e.g., alignments, variants) is embedded as uuencoded blobs.

This tool is particularly useful for sharing genomic data visualizations without needing to distribute large input files or set up servers.

## Features

- **Self-Contained Reports**: Embed all data directly in the HTML for easy sharing.
- **Support for Multiple Track Types**: Includes alignments (BAM/CRAM), variants (VCF), and custom tracks.
- **Reference Genome Integration**: Uses FASTA, TwoBit, or predefined genome identifiers.
- **Customizable Tables**: Include specific INFO fields or columns from variant files.
- **Tabix-Indexed File Support**: Efficient handling of large files.

## Requirements

- Python 3.6 or later
- pysam >= 0.22.0 (automatically installed as a dependency)
- On macOS, ensure Xcode command-line tools are installed if pysam installation fails due to missing libraries.

No internet access is required to view generated reports.

## Installation

IGV-Reports can be installed via pip, conda (recommended for bioinformatics environments), or from source.

### Via pip
```bash
pip install igv-reports
```

### Via Bioconda
```bash
conda install -c bioconda igv-reports
```

### From Source
```bash
git clone https://github.com/igvteam/igv-reports.git
cd igv-reports
pip install .
```

After installation, verify by running:
```bash
create_report --help
```

## Usage

Reports are generated using the `create_report` command-line script (or equivalently, `python -m igv_reports.report`). The core functionality creates an HTML report from a sites file (e.g., VCF of variants) and optional tracks like alignments.

### Basic Command Structure
```bash
create_report [OPTIONS] <sites> <reference>
```

- `<sites>`: File of genomic variant sites (VCF, BED, MAF, BEDPE, or tab-delimited). Tabix-indexed files are recommended for large datasets.
- `<reference>`: One of:
  - `--fasta <file>`: Indexed FASTA reference genome.
  - `--twobit <file>`: TwoBit reference genome file.
  - `--genome <id>`: IGV.js genome identifier (e.g., "hg38", "mm10"). See [igv.js genomes](https://github.com/igvteam/igv.js/wiki/Genomes) for options.

### Required Arguments
- **Sites File**: Path to a VCF, BED, or similar file listing variants/regions.
- **Reference**: As above, one reference option is mandatory.

### Common Options
| Option | Description | Example |
|--------|-------------|---------|
| `--tracks <file1> [<file2> ...]` | Alignment tracks (BAM/CRAM) or other IGV-compatible tracks. Optional but recommended for context. | `--tracks sample.bam` |
| `--output <file>` or `-o <file>` | Output HTML report file. Defaults to `report.html`. | `-o my_report.html` |
| `--standalone` | Embed all data (default behavior). | |
| `--title <string>` | Report title. Defaults to "IGV Report". | `--title "Patient Variant Review"` |
| `--info-columns <list>` | Space-delimited INFO fields/columns to include in the variant table (VCF: INFO IDs; others: column names). | `--info-columns AF DP` |
| `--locus <region>` | Specific genomic locus to view (e.g., "chr1:100000-200000"). Overrides sites for single-region reports. | `--locus chr1:1,000,000-1,100,000` |
| `--include-all` | Include all variants in the table (default filters to passed variants). | |

For a full list of options:
```bash
create_report --help
```

### Example: Basic Variant Report
Generate a report for variants in a VCF file, using hg38 and an alignment BAM track:
```bash
create_report --genome hg38 --tracks sample.bam variants.vcf
```
This produces `report.html` with a table of variants and IGV views for each.

### Example: Custom Locus Report
For a specific region without a sites file:
```bash
create_report --genome hg38 --tracks sample.bam --locus chr1:1000000-1010000 -o region_report.html
```

### Example: Detailed Variant Table
Include specific INFO fields:
```bash
create_report --fasta ref.fa --tracks alignments.cram --info-columns AF DP QUAL variants.vcf -o detailed_report.html
```

## Viewing Reports
- Open the generated `.html` file in any modern web browser (Chrome, Firefox, Safari, etc.).
- No installation or server is needed—the IGV.js viewer is embedded.
- Navigate the table to jump between sites; zoom/pan in IGV views as usual.

## Tips and Troubleshooting

- **Large Files**: Use Tabix-indexed inputs to speed up processing. Generate indexes with `tabix -p vcf file.vcf`.
- **macOS Issues**: If pysam fails to install, run `xcode-select --install` and retry.
- **Custom Genomes**: For non-standard references, provide `--fasta` with a `.fai` index (create via `samtools faidx ref.fa`).
- **Memory Usage**: Embedding large BAMs can produce big HTML files; consider subsampling or using remote tracks if sharing is an issue (omit `--standalone`).
- **Errors with `--genome`**: Ensure the identifier matches igv.js (e.g., "hg19" not "GRCh37").
- For advanced customization, embed reports in Jupyter via [igv-notebook](https://github.com/igvteam/igv-notebook).

## Examples
Sample reports and inputs are available in the [GitHub repo examples](https://github.com/igvteam/igv-reports/tree/master/examples).

## Contributing
Contributions are welcome! See the [GitHub repository](https://github.com/igvteam/igv-reports) for issues, pull requests, or to report bugs.

## License
MIT License. See [LICENSE](https://github.com/igvteam/igv-reports/blob/master/LICENSE) for details.

## References
- [IGV-Reports GitHub](https://github.com/igvteam/igv-reports)
- [IGV Documentation](https://igv.org/)
- Robinson et al. "Variant Review with the Integrative Genomics Viewer (IGV)" *Cancer Genetics* (2017).


## Use case MitoEDIT

igv-reports needs first col to always be chr  
 Current input data
```
 head -2 test.tsv
Name	Chr	Pos	Type	Size	Coverage	Percent_alternative_allele	Chr_Allele	Alternative_Allele	Score	Text	unique_alternative_ids	reference_normal_count	reference_tumor_count	alternative_normal_count	alternative_tumor_count	count_ref_normal_fwd	count_ref_normal_rev	count_ref_tumor_fwd	count_ref_tumor_rev	count_var_normal_fwd	count_var_normal_rev	count_var_tumor_fwd	count_var_tumor_rev	alternative_fwd_count	alternative_rev_count	alternative_bidirectional_confirmation	broad_coverage	broad_reference_normal_count	broad_reference_tumor_count	broad_alternative_normal_count	broad_alternative_tumor_count	unique_alt_read_starts	unique_alt_read_starts_fwd	unique_alt_read_starts_rev	avg_mapq_alternative	somatic_or_germline	loh_flag	alt_to_ref_ratio_normal	alt_to_ref_ratio_tumor	alt_to_ref_ratio_diff_normal_tumor	strand_skew
chrM.4769	chrM	4769	SNP	1	10820	1.000	A	G	0.990	TCATCATTAATAATCATAAT[A/G]GCTATAGCAATAAAACTAGG	9152	0	0	3793	5378	0	0	0	0	2273	1520	3126	2252	5399	3772	1	13547	005703	7844	131	131	131	36	G		1.000	1.000	0.000	0.500
```

Mod
```
awk -F'\t' -v OFS='\t' '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$1}' test.tsv > mod_tab.tsv
```

## igv config file
you can edit multiple params in this file which includes split reads, circlular view etc..
```
 cat igv.config
[
  {
    "name": "Tumor",
    "url" : "/shared/Mito_WGS_Nextflow/HG008_Downsampled_TestData/HG008-T_Illumina_Downsample_200M.bam",
    "colorBy": "strand",
    "alleleFreqThreshold": 0.02
  },
  {
    "name": "Normal",
    "url": "/shared/Mito_WGS_Nextflow/HG008_Downsampled_TestData/HG008-N-D_Illumina_Downsample_200M.bam",
    "colorBy": "strand",
    "alleleFreqThreshold": 0.02
  }
]
```

## igv bash script
```
 cat igv.sh
python3 ~/miniconda3/lib/python3.13/site-packages/igv_reports/report.py ~/mod_tab.tsv \
/shared/Mito_WGS_Nextflow/Nextflow_mitochondra_wgs/MT_bwa/MT.fa \
 --sequence 1 --begin 2 --end 2 \
--info-columns Chr Pos Type Size Coverage Percent_alternative_allele Chr_Allele Alternative_Allele Score \
--flanking 1000 \
--tracks https://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/refGene.txt.gz \
--title "HG008" \
--output HG008-MT.genome.html \
--track-config igv.config
```
