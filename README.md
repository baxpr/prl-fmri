# Demo singularity container with SPM12 and Freeview

SPM12-based pipelines require a little extra work to get them compiled and working in a
container. Freesurfer's Freeview is also included here, as it's very handy for creating
the PDF QA report. This example shows three different ways of creating image displays for
the QA PDF.

See https://github.com/baxpr/demo-singularity-matlab-fsl for a lot of detailed info about
putting Matlab code into singularity containers. This example uses the same structure.

A licensed Matlab installation is required to compile the Matlab code, but is not needed
to run the compiled executable in the container.

SPM12 (https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) is not in this repository and must
be installed separately on the compilation host. Edit `matlab/compile_matlab.sh` to point 
to it.

SPM requires jumping an extra hurdle at the compilation step - we use a modified version
of SPM's own compiler function `spm_make_standalone.m`, found at 
`matlab/spm_make_standalone_local.m`. This process captures a lot of dependencies that
could otherwise easily be left out of the executable, with the resulting symptom that it
compiles just fine but fails at run time with various cryptic error messages. In addition
to SPM12, everything in the `matlab/src` directory is included in the path at compile time.
If Matlab toolboxes are used, they will need to be added to the list of included toolboxes
in `matlab/spm_make_standalone_local.m`.

The compiled Matlab executable is stored on github using git LFS. A regular git clone will
download a pointer text file instead of the executable binary. The result of building a 
container from that will be a cryptic error message - so, compile it yourself. Or, if 
storing on github, download it manually and replace the pointer text file, or include this 
step in the Singularity file if helpful - example here:
https://github.com/baxpr/gf-fmri/blob/47b0552/Singularity.v1.3.4#L65

Freesurfer requires a license to run:
https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall#License
Best practice is to store your license file on the host that will run the container, and
bind it to the container at runtime - NOT to include your own license file in the 
container itself.
