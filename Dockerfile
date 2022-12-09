# Start with FSL, ImageMagick, python3/pandas base docker
FROM baxterprogers/fsl-base:v6.0.5.2

# Matlab reqs
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-8-jre && \
    apt-get clean
        
# Install the MCR
RUN wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/6/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip \
     -O /opt/mcr_installer.zip && \
     unzip /opt/mcr_installer.zip -d /opt/mcr_installer && \
    /opt/mcr_installer/install -mode silent -agreeToLicense yes && \
    rm -r /opt/mcr_installer /opt/mcr_installer.zip
   
# Copy the pipeline code
COPY matlab /opt/prl-fmri/matlab
COPY src /opt/prl-fmri/src
COPY README.md /opt/prl-fmri/README.md

# Matlab env
ENV MATLAB_SHELL=/bin/bash
ENV MATLAB_RUNTIME=/usr/local/MATLAB/MATLAB_Runtime/v97

# Add pipeline to system path
ENV PATH /opt/prl-fmri/src:/opt/prl-fmri/matlab/bin:${PATH}

# Entrypoint
ENTRYPOINT ["pipeline_entrypoint.sh"]
