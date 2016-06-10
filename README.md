# CESM_postprocessing
Github Project repository for the CESM post-processing tools documentation and issues tracking.

Please see the shared Google document for CESM postprocessing documentation until it is migrated into Github at URL:

https://docs.google.com/a/ucar.edu/document/d/1toJt7y35cy_730-tGaKkzYC5H509iY9DYNmLFDGNe6E/edit?usp=sharing

## Updating your local postprocessing sandbox
The CESM post-processing code is still maintained in Subversion until we migrate all the 
working group diagnostics packages to github. It's best to always use the
latest trunk tag as that code has been tested. Here is the link to the 
SVN repository:

https://svn-ccsm-models.cgd.ucar.edu/postprocessing/

Be sure to follow these steps when updating you local CESM postprocessing sandbox. 
> cd $postprocess_sandbox

> make clobber

> make clobber-env

> svn propset svn:externals -F SVN_EXTERNAL_DIRECTORIES .

> svn update

> ./create_python_env -cimeroot $CIMEROOT -machine yellowstone

The Github issue will add instructions if ./create_postprocess needs to be rerun for existing postprocessing caseroots.
