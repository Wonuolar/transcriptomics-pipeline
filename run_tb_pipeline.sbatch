
#!/bin/bash -l
#SBATCH --job-name=tb_rnaseq
#SBATCH --account=bio1439s225
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=24:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=oolarinde1@gsu.edu
#SBATCH --output=slurm-%x-%j.out
#SBATCH --error=slurm-%x-%j.err
# #SBATCH -D /path/to/your/project   # (optional) set a working directory

echo "Job started: $(date)"
echo "Node: $(hostname)"
echo "PWD: $(pwd)"


bash run_tb_pipeline.sh

echo "Job finished: $(date)"
