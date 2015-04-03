#BSUB -n 4
#BSUB -R "span[ptile=15]"
#BSUB -q regular
#BSUB -N
#BSUB -a poe
#BSUB -x
#BSUB -o postprocess.stdout.%J
#BSUB -e postprocess.stderr.%J
#BSUB -J CESM_postprocessing
#BSUB -W 02:00
#BSUB -P P93300606
