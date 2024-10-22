# Study-specific fMRI analysis for PRL task

# Inputs

- The four fMRI scans
- A fifth short fMRI scan with reverse phase encoding for TOPUP
- Deformation field from native to MNI space from CAT12 pipeline
- Multiatlas brain segmentation from SLANT pipeline
- Trial timing info from eprime-3prl_v1 pipeline
- High-pass filter cutoff (default 300 sec)
- Smoothing FWHM (default 6 mm)

# Processing

- Co-registration and TOPUP distortion correction of the fMRI (FSL)
- Registration of the fMRI to T1 (FSL)
- Warp to MNI space and smooth (SPM)
- First-level statistical analysis (SPM)

The cue and feedback events are modeled for each trial, with a fixed duration.

The six motion parameters for each run (rotation and translation) are included as confound predictors.

No temporal derivatives of any predictors are included.

# Outputs

[UPDATED for v2.1.0] Results are output for a single first-level model:

- `cue_mu3_feedback_epsi3_orth1` Cue appearance and feedback appearance are each modeled as individual fixed-duration events. A parametric effect of the mu3 parameter on cue response amplitude is modeled. A parametric effect of the epsilon3 parameter on feedback response amplitude is modeled. The parametric modulation terms are orthogonalized with respect to the primary predictor.


# References

Deserno L, Boehme R, Mathys C, Katthagen T, Kaminski J, Stephan KE, Heinz A, Schlagenhauf F. Volatility Estimates Increase Choice Switching and Relate to Prefrontal Activity in Schizophrenia. Biol Psychiatry Cogn Neurosci Neuroimaging. 2020 Feb;5(2):173-183. doi: 10.1016/j.bpsc.2019.10.007. PMID: 31937449.

