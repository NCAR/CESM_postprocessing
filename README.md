# CESM_postprocessing
Github Project repository for the CESM post-processing tools documentation and issues tracking.

Please refer to the Wiki for documentation.

## Updating your local postprocessing sandbox
The CESM post-processing code is still maintained in Subversion until we migrate all the 
working group diagnostics packages to github. It's best to always use the
latest trunk tag as that code has been tested. Here is the link to the 
SVN repository:

https://svn-ccsm-models.cgd.ucar.edu/postprocessing/trunk 
-- or --
https://svn-ccsm-models.cgd.ucar.edu/postprocessing/trunk_tag/postprocess_[date]

Be sure to follow these steps when updating you local CESM postprocessing sandbox. 
> cd $postprocess_sandbox

> make clobber

> make clobber-env

> svn propset svn:externals -F SVN_EXTERNAL_DIRECTORIES .

> svn update

> ./create_python_env -cimeroot $CIMEROOT -machine yellowstone


