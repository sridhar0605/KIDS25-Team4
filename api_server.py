"""
Backend API Server for WGS + MitoEdit Pipeline
Receives parameters from UI and triggers Nextflow pipeline
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List
import subprocess
import uuid
import json
import os
from pathlib import Path
from datetime import datetime

app = FastAPI(title="WGS-MitoEdit Pipeline API")

# Enable CORS for UI integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Directory structure
BASE_DIR = Path("/data/pipeline")
RUNS_DIR = BASE_DIR / "runs"
UPLOADS_DIR = BASE_DIR / "uploads"

# Ensure directories exist
RUNS_DIR.mkdir(parents=True, exist_ok=True)
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)

# In-memory job tracking (use Redis/database in production)
jobs = {}


class PipelineRequest(BaseModel):
    """Request model for pipeline execution"""
    tumor_bam: str = Field(..., description="Path or URL to tumor BAM file")
    normal_bam: str = Field(..., description="Path or URL to normal BAM file")
    reference_genome: str = Field(default="hg38", description="Reference genome")
    project_name: str = Field(..., description="Project identifier")
    
    # Variant filtering parameters
    min_coverage: int = Field(default=100, ge=1, description="Minimum coverage")
    vaf_threshold: float = Field(default=0.03, ge=0.0, le=1.0, description="VAF threshold")
    max_vaf: float = Field(default=0.99, ge=0.0, le=1.0, description="Maximum VAF")
    
    # MitoEdit parameters (optional)
    mito_position: Optional[int] = Field(None, description="Mitochondrial position to edit")
    mito_mutant_base: Optional[str] = Field(None, pattern="^[ATCG]$", description="Target base")
    mito_min_spacer: int = Field(default=14, ge=12, le=20, description="Min spacer length")
    mito_max_spacer: int = Field(default=18, ge=12, le=20, description="Max spacer length")


class JobStatus(BaseModel):
    """Job status response"""
    job_id: str
    status: str  # pending, running, completed, failed
    created_at: str
    updated_at: str
    progress: float
    message: str
    results: Optional[dict] = None


def run_nextflow_pipeline(job_id: str, params: PipelineRequest):
    """
    Execute Nextflow pipeline in background
    """
    job_dir = RUNS_DIR / job_id
    job_dir.mkdir(exist_ok=True)
    
    try:
        # Update job status
        jobs[job_id]["status"] = "running"
        jobs[job_id]["updated_at"] = datetime.now().isoformat()
        jobs[job_id]["progress"] = 0.1
        
        # Build Nextflow command
        cmd = [
            "nextflow", "run", "main.nf",
            "-profile", "docker",
            "--tumor_bam", params.tumor_bam,
            "--normal_bam", params.normal_bam,
            "--reference_genome", params.reference_genome,
            "--project_name", params.project_name,
            "--output_dir", str(job_dir),
            "--min_coverage", str(params.min_coverage),
            "--vaf_threshold", str(params.vaf_threshold),
            "--max_vaf", str(params.max_vaf),
        ]
        
        # Add MitoEdit parameters if provided
        if params.mito_position and params.mito_mutant_base:
            cmd.extend([
                "--mito_position", str(params.mito_position),
                "--mito_mutant_base", params.mito_mutant_base,
                "--mito_min_spacer", str(params.mito_min_spacer),
                "--mito_max_spacer", str(params.mito_max_spacer),
            ])
        
        # Execute pipeline
        jobs[job_id]["progress"] = 0.2
        
        result = subprocess.run(
            cmd,
            cwd=BASE_DIR,
            capture_output=True,
            text=True,
            timeout=3600  # 1 hour timeout
        )
        
        if result.returncode == 0:
            # Pipeline succeeded
            jobs[job_id]["status"] = "completed"
            jobs[job_id]["progress"] = 1.0
            jobs[job_id]["message"] = "Pipeline completed successfully"
            
            # Collect output files
            jobs[job_id]["results"] = {
                "wgs_report": str(job_dir / "reports" / "wgs_igv_report.html"),
                "mito_report": str(job_dir / "reports" / "mito_igv_report.html"),
                "variant_summary": str(job_dir / "wgs" / "variant_summary.csv"),
                "mito_windows": str(job_dir / "mito" / "all_windows.csv"),
                "mito_bystanders": str(job_dir / "mito" / "all_bystanders.csv"),
            }
        else:
            # Pipeline failed
            jobs[job_id]["status"] = "failed"
            jobs[job_id]["message"] = f"Pipeline failed: {result.stderr}"
            
    except subprocess.TimeoutExpired:
        jobs[job_id]["status"] = "failed"
        jobs[job_id]["message"] = "Pipeline execution timeout"
    except Exception as e:
        jobs[job_id]["status"] = "failed"
        jobs[job_id]["message"] = f"Error: {str(e)}"
    finally:
        jobs[job_id]["updated_at"] = datetime.now().isoformat()


@app.post("/api/pipeline/run", response_model=JobStatus)
async def run_pipeline(
    request: PipelineRequest,
    background_tasks: BackgroundTasks
):
    """
    Submit a new pipeline run
    """
    # Generate unique job ID
    job_id = str(uuid.uuid4())
    
    # Initialize job tracking
    jobs[job_id] = {
        "job_id": job_id,
        "status": "pending",
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat(),
        "progress": 0.0,
        "message": "Job submitted",
        "params": request.dict(),
        "results": None
    }
    
    # Start pipeline in background
    background_tasks.add_task(run_nextflow_pipeline, job_id, request)
    
    return JobStatus(**jobs[job_id])


@app.get("/api/pipeline/status/{job_id}", response_model=JobStatus)
async def get_job_status(job_id: str):
    """
    Get status of a pipeline run
    """
    if job_id not in jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    
    return JobStatus(**jobs[job_id])


@app.get("/api/pipeline/report/{job_id}/{report_type}")
async def get_report(job_id: str, report_type: str):
    """
    Retrieve IGV report HTML
    report_type: 'wgs' or 'mito'
    """
    if job_id not in jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    
    if jobs[job_id]["status"] != "completed":
        raise HTTPException(status_code=400, detail="Pipeline not completed")
    
    results = jobs[job_id]["results"]
    if not results:
        raise HTTPException(status_code=404, detail="Results not found")
    
    # Get report path
    report_key = f"{report_type}_report"
    if report_key not in results:
        raise HTTPException(status_code=404, detail="Report type not found")
    
    report_path = Path(results[report_key])
    if not report_path.exists():
        raise HTTPException(status_code=404, detail="Report file not found")
    
    # Return HTML content
    from fastapi.responses import HTMLResponse
    return HTMLResponse(content=report_path.read_text())


@app.get("/api/pipeline/download/{job_id}/{file_type}")
async def download_file(job_id: str, file_type: str):
    """
    Download result files
    file_type: variant_summary, mito_windows, mito_bystanders
    """
    if job_id not in jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    
    if jobs[job_id]["status"] != "completed":
        raise HTTPException(status_code=400, detail="Pipeline not completed")
    
    results = jobs[job_id]["results"]
    if not results or file_type not in results:
        raise HTTPException(status_code=404, detail="File not found")
    
    file_path = Path(results[file_type])
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    
    from fastapi.responses import FileResponse
    return FileResponse(
        path=file_path,
        filename=file_path.name,
        media_type="application/octet-stream"
    )


@app.post("/api/upload/bam")
async def upload_bam(file: UploadFile = File(...)):
    """
    Upload BAM file
    """
    try:
        file_id = str(uuid.uuid4())
        file_path = UPLOADS_DIR / f"{file_id}_{file.filename}"
        
        # Save uploaded file
        with file_path.open("wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        return {
            "file_id": file_id,
            "filename": file.filename,
            "path": str(file_path),
            "size": len(content)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@app.get("/api/jobs")
async def list_jobs():
    """
    List all pipeline jobs
    """
    return {
        "jobs": [
            {
                "job_id": job_id,
                "status": job_data["status"],
                "created_at": job_data["created_at"],
                "project_name": job_data["params"].get("project_name", "Unknown")
            }
            for job_id, job_data in jobs.items()
        ]
    }


@app.get("/health")
async def health_check():
    """
    Health check endpoint
    """
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
