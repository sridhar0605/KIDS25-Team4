# TAL Effector Binding Site Prediction Rules

This document summarizes the most current rules for predicting and designing TAL effector binding sites in **nuclear** and **mitochondrial** genomes.  
These guidelines can be used to support development of binding site predictors, custom transcription factors, and TALEN-based genome editing tools.

---

## 1. TAL Effector–Nucleotide Binding Code
- **HD → C**  
- **NI → A**  
- **NG → T**  
- **NN → G > A** (less specific, higher activity)  
- **NH → G** (preferred over NN for specificity)  
- **NK → G** (very specific but often weaker)

---

## 2. Core Binding Rules
1. **Position 0 (T0):**  
   - Most natural EBEs are preceded by a 5′ **T** immediately upstream.  
   - Strongly enhances binding via N-terminal repeat “−1” interaction.

2. **Mismatch Tolerance:**  
   - Mismatches at the **5′ end (first 5 repeats)** are most detrimental.  
   - Mismatches at the **3′ end** are more tolerated.

3. **Aberrant Repeats:**  
   - Non-standard (non-34 aa) repeats can cause **frameshift binding**, creating unexpected off-targets.  
   - Off-target prediction should allow for this.

4. **Repeat Count:**  
   - Optimal activity with **~15–20 repeats**.  
   - Longer arrays often reduce performance.

---

## 3. Epigenetic & Context Effects
- **5mC (5-methylcytosine):**  
  - **NG** can bind 5mC (chemically similar to T).  
  - **HD** binding is impaired at 5mC.  
  - **Methylation-aware scoring** is recommended for nuclear targets.  
- **Contextual effects:**  
  - DNA shape and flanking sequence influence binding efficiency.  
  - Position-specific scoring models outperform simple code-only matchers.

---

## 4. TALEN Design Constraints
- **Spacer length:** ~12–21 bp between paired TALEN half-sites.  
- **Orientation:** Proper arrangement of monomers required.  
- **Activity scoring/off-target search:**  
  - Recommended tools: **SAPTA**, **TALENoffer**, **PROGNOS**.

---

## 5. Nuclear vs Mitochondrial Genomes
- Binding rules are the same.  
- **Mitochondrial DNA:**  
  - Chromatin is minimal.  
  - CpG methylation is low/controversial → methylation rules often less relevant.  
  - **mitoTALENs** (TALE–FokI with MTS) validated for selective cleavage of mtDNA variants.

---

## 6. Practical Design Checklist
✔ Start with **T0** if possible.  
✔ Use **HD for C, NI for A, NG for T, NH/NK for G**. Avoid NN unless degeneracy is acceptable.  
✔ Keep repeat length at ~15–20.  
✔ Place unavoidable mismatches toward the **3′ end**.  
✔ Account for methylation (nuclear only).  
✔ Respect TALEN spacer and orientation rules.  
✔ Re-scan targets if using aberrant repeats (frameshift binding).

---

_Last updated: 2025-09-29_
