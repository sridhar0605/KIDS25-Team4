# 📋 Project Task List

This file tracks ongoing work for the **WGS–MTE Pipeline**.  
Team members can check off tasks as they complete them, add new items, and note priorities.  

For visual tracking and assignments, also see the [GitHub Project Board](../../projects).

---

## 🧬 Whole-Genome Sequencing (WGS)

- [ ] **User Interface**
  - Capture input parameters (BAM list, project name, output path).
- [ ] **Containerization**
  - Package Conda environment.  
  - Build Docker/Singularity container.
- [ ] **Validation**
  - Compare Nextflow outputs vs HOX8 legacy pipeline.
- [x] **Data Prep**
  - Down-sampled BAMs created (800M, 500M, 200M reads) for Biohackathon.

---

## 🧬 MitoEdit (MTE) Functionality Improvements

- [ ] Report whether TALEs are *not* ideal (not just the ideal ones).
- [ ] Extend customization module to predict bystander edits.
- [ ] Improve parsing to prevent argument failures.

---

## ⚙️ MTE TALEN-NT Modernization

- [ ] Rewrite in Python 3.
- [ ] Implement as importable library (reduce reliance on CLI).
- [ ] Remove absolute/ hardcoded paths.
- [ ] Add parallelization for speed.

---

## 📊 Visualization

- [ ] Add interactive visualization component for each module.  
  Options:  
  - Use Jandee’s agent  
  - Build JavaScript IGV-like viewer  

---

## 🏷️ Priority Key

- 🔴 High Priority  
- 🟡 Medium Priority  
- 🟢 Low Priority  

(Use labels or comments on tasks to indicate priority.)

---

## 🙋 Ownership

Team members can add their name next to a task they are taking on. Example:

- [ ] Rewrite in Python 3 (**Owner: Jenn O'Micks**)

---
