"""Nosetests for the ILAMB run script."""
import os
import subprocess
from nose.tools import assert_equal, raises


run_cmd = 'ilamb-run'


def test_help_argument():
    r = subprocess.call([run_cmd, '--help'])
    assert_equal(r, 0)


@raises(subprocess.CalledProcessError)
def test_config_argument_not_set():
    r = subprocess.check_call([run_cmd])
