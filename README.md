# KIDS25-Team4 WGS–MTE Pipeline Project

This repository tracks the development of a computational biology pipeline consisting of two major modules:  
- **Whole-Genome Sequencing (WGS)**  
- **MitoEdit (MTE)**  

The goal is to:  
1. Build and modernize the pipeline for usability and reproducibility.  
2. Add functionality, containerization, and visualization features.  
3. Provide a clear record of progress, priorities, and ownership.  

---

## 📋 Project Task List

Team members can check off items as they are completed.  
Use GitHub Projects for detailed tracking, assignments, and prioritization.

### WGS
- [ ] **User Interface**: develop UI and capture parameters (BAM list, project name, output path).
- [ ] **Containerization**: package Conda environment and build Docker/Singularity container.
- [ ] **Validation**: compare Nextflow outputs vs HOX8 legacy pipeline.
- [x] **Data Prep**: create down-sampled BAMs (800M, 500M, 200M reads) for Biohackathon.

### MTE Functionality Improvements
- [ ] Report whether TALEs are *not* ideal (not just ideal ones).
- [ ] Extend customization module to predict bystander edits.
- [ ] Improve parsing to reduce argument failures.

### MTE TALEN-NT Modernization
- [ ] Rewrite in Python 3.
- [ ] Make importable as a library (not only CLI).
- [ ] Remove absolute paths.
- [ ] Add parallelization for speed.

### Visualization
- [ ] Add interactive visualization (IGV-like).  
  Options:  
  - Use Jandee’s agent  
  - JavaScript-based implementation  

---

## 🗂 Clarified Outline

### **WGS Module**
1. **User Interface**
   - Define required inputs:  
     - Paired BAM list (sample sheet)  
     - Project name  
     - Output location  
   - Build UI to capture these parameters.
2. **Dependencies & Containerization**
   - Current HPC modules:  
     - `samtools/1.12`, `bwa/0.7.17`, `annovar/20200607`, `python/3.11.0`, `bambino-1.0.jar`
   - Package into Conda and containerize with Docker/Singularity.
3. **Validation**
   - Benchmark Nextflow outputs against HOX8 pipeline results.
   - Provide down-sampled BAM files for testing/development.

### **MTE Module**
1. **Functionality Improvements**
   - Flag non-ideal TALEs.  
   - Predict impact of bystander edits.  
   - Improve argument parsing robustness.
2. **TALEN-NT Modernization**
   - Port from Python 2 → Python 3.  
   - Implement as importable library.  
   - Remove hardcoded paths.  
   - Add parallelization.

### **Visualization**
- Add IGV-like interactive viewer for results.  
- Options: Jandee’s agent or JavaScript implementation.

---

## 📊 Workflow Diagram

```mermaid
flowchart TD
    A[WGS Module] --> B1[User Interface]
    B1 --> B2[Define input parameters: BAM list, project name, output]
    A --> C1[Dependencies & Containerization]
    C1 --> C2[Package Conda environment]
    C2 --> C3[Build Docker/Singularity container]
    A --> D1[Validation]
    D1 --> D2[Compare outputs with HOX8 pipeline]
    D1 --> D3[Use down-sampled BAM files]

    E[MitoEdit Module] --> F1[Functionality Improvements]
    F1 --> F2[Report non-ideal TALEs]
    F1 --> F3[Predict bystander edits]
    F1 --> F4[Improve parsing]
    E --> G1[TALEN-NT Modernization]
    G1 --> G2[Rewrite in Python 3]
    G1 --> G3[Make importable library]
    G1 --> G4[Remove absolute paths]
    G1 --> G5[Parallelize execution]

    H[Visualization Module] --> I1[Interactive Viewer]
    I1 --> I2[Jandee’s Agent]
    I1 --> I3[JavaScript IGV-like tool]
