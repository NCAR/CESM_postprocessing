NP = 1

test_sample:
	@mpirun -n ${NP} ilamb-run                \
        --config test.cfg                         \
        --model_root ${ILAMB_ROOT}/MODELS/CLM/    \
	--models CLM50r243CRUNCEP CLM50r243GSWP3  \
        --regions global shsa
	python score_diff.py scores_test.csv.gold _build/scores.csv

test_run_script:
	nosetests test_run_script.py

clean:
	@rm -rf _build
