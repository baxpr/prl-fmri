#!/usr/bin/env bash
#
# Show the image, annotated

echo Running $(basename "${BASH_SOURCE}")

thedate=$(date)

# Work in output directory
cd ${out_dir}

# Find center of mass of the mask image, using a custom matlab function
run_spm12.sh ${MATLAB_RUNTIME} function ctr_of_mass mask.nii 0 yes com.txt
com=$(cat com.txt)
rm com.txt
XYZ=(${com// / })

# Axial slices to show, relative to COM in mm
for sl in -040 -030 -020 -010 000 010 020 030 040 050 060; do

    Z=$(echo "${XYZ[2]} + ${sl}" | bc -l)
    echo "Slice ${sl} at ${XYZ[@]}"

	freeview \
	  -v img.nii \
	  -v mask.nii:colormap=lut:outline=yes \
	  -viewsize 800 800 --layout 1 --zoom 1.2 --viewport axial \
	  -ras ${XYZ[0]} ${XYZ[1]} ${Z} \
	  -ss slice_${sl}.png

done

# Combine slices into single image. A 'clever' trick to get the images
# in the right order on the page
montage -mode concatenate slice_-0{4,3,2,1}*.png slice_0*.png \
    -tile 3x4 -quality 100 -background black -gravity center \
    -border 20 -bordercolor black page1.png

# Rescale to fit the page, and add annotations
convert \
    -size 2250x3000 xc:white -density 300 \
    -gravity center \( page1.png -resize 2000x \) -composite \
    -gravity North -pointsize 12 -annotate +0+100 \
    "Mask shown on input image" \
    -gravity SouthEast -pointsize 12 -annotate +100+100 "${thedate}" \
    -gravity NorthWest -pointsize 12 -annotate +100+200 "${label_info}" \
    page1.png

# Combine with saved images from Matlab/SPM to make a single PDF
convert page1.png batchfigure*.pdf funcfigure*.pdf demo.pdf

# Clean up
rm page1.png batchfigure_*.pdf funcfigure_*.pdf
