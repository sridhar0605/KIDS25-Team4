# WGS Pipeline UI

Streamlit interface for WGS mtDNA variant analysis parameter collection.

## wgs_ui_v2.py
- Reference genome: hg38 only
- Pipeline selection: WGS only / WGS + MitoEdit (full pipeline)
- SNV class filter: TU (Tumor-enriched), HS (Shared), GH (Germline heteroplasmy), INH (Inherited)
- VAF threshold: Restricted to >0 and <99.9
- Access at: http://74.235.82.166:8505

## Running
```bash
streamlit run wgs_ui_v2.py
