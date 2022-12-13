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

The cue event is modeled for each trial, with onset at the presentation of the cue and offset at the presentation of feedback. This duration varies from trial to trial.

Parametric modulators of the cue response are included for five parameters of the fitted behavioral model: epsilon2, epsilon3, psi2, psi3, mu33.

The six motion parameters for each run (rotation and translation) are included as confound predictors.

# Outputs

Results are output for three different first-level models:

- `spm_cue_orth0` Parametric modulators are not orthogonalized (this follows Deserno 2020). The cue response is not interpretable due to collinearity with parametric modulators. The mu33 result shows variance that is explainable by mu33, but not explainable by cue or other modulators.

- `spm_cue_orth1_epsi2` Parametric modulators are orthogonalized with respect to cue and to each other in the order epsilon2, epsilon3, psi2, psi3, mu33. The cue response is interpretable as amplitude at a fixed value of the modulators. The mu3 response is the same as for `spm_cue_orth0`.

- `spm_cue_orth1_mu33` Parametric modulators are orthogonalized in the order mu33, psi3, psi2, epsilon3, epsilon2. The cue response is interpretable at a fixed value of the modulators. The mu33 response shows variance that is not explainable by the cue response (only).


# References

Deserno L, Boehme R, Mathys C, Katthagen T, Kaminski J, Stephan KE, Heinz A, Schlagenhauf F. Volatility Estimates Increase Choice Switching and Relate to Prefrontal Activity in Schizophrenia. Biol Psychiatry Cogn Neurosci Neuroimaging. 2020 Feb;5(2):173-183. doi: 10.1016/j.bpsc.2019.10.007. PMID: 31937449.

