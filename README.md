# CESM_postprocessing
Project repository for the CESM post-processing tools documentation and issues tracking.

Please see the shared Google document for CESM postprocessing documentation until it is migrated into Github at URL:

https://docs.google.com/a/ucar.edu/document/d/1toJt7y35cy_730-tGaKkzYC5H509iY9DYNmLFDGNe6E/edit?usp=sharing

## Updating your local postprocessing sandbox
Be sure to follow these steps when updating you local CESM postprocessing sandbox.
> cd $postprocess_sandbox
> make clobber
> make clobber-env
> svn up 
> ./create_postprocess_env -cimeroot $CIMEROOT -machine yellowstone

The Github issue will add instructions if ./create_postprocess needs to be rerun for existing postprocessing caseroots.
