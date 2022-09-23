FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y apt-utils \
	&& apt-get install build-essential -y \
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
		dirmngr \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
	&& add-apt-repository --enable-source --yes "ppa:marutter/rrutter4.0" \
	&& add-apt-repository --enable-source --yes "ppa:c2d4u.team/c2d4u4.0+" \
	&& apt-get install libz-dev \
	&& apt-get -y install default-jre-headless \
	&& apt-get install curl -y \
	&& apt-get install zip -y \
	&& apt-get install -y perl-doc \
	&& apt-get install python3 -y \
	&& apt-get install python3-pip -y \
	&& apt-get install python3-pycurl -y \
	&& apt-get install bc -y \
	&& apt-get install samtools -yq --no-install-recommends \
	&& apt-get install tabix -y \
	&& apt-get install bcftools -y \
	&& apt-get install graphviz -y \
	&& apt-get install pandoc -y \
	&& apt-get install libsodium-dev -y \
	&& apt-get install cargo -y \
	&& apt-get install libudunits2-dev -y \
	&& apt-get install libcurl4-openssl-dev \
	&& apt-get install libssl-dev \
	&& apt-get install libxml2-dev -y \
	&& apt-get install libgeos-dev -y \
	&& apt-get install libfontconfig1-dev -y \
	&& apt-get install libcairo2-dev -y \
	&& apt-get install libgdal-dev -y \
	&& apt-get install libharfbuzz-dev -y \
	&& apt-get install libfribidi-dev -y \
	&& apt-get clean \
	&& ln -s /usr/bin/python3 /usr/bin/python

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8


RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		littler \
		r-base \
		r-base-dev \
		r-recommended \
		r-cran-docopt \
	&& apt-get clean \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*

RUN pip3 -V \
	&& pip3 install --upgrade pip \
	&& pip3 install cwltool \
	&& rm -rf /var/lib/apt/lists/*

ENV GATK_VERSION=4.2.4.0

ENV GATK_ZIP_PATH=/tmp/gatk-4.2.4.0.zip


RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
	&& unzip -o $GATK_ZIP_PATH -d /etc/ \
	&& ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk \
	&& pip install /etc/gatk-$GATK_VERSION/gatkPythonPackageArchive.zip

RUN R -e "install.packages(c('shiny'), rdependencies=TRUE)" \
	&& R -e "install.packages(c('R.utils','remotes', 'systemfonts', 'textshaping', 'ggplot2', 'tidyr', 'dplyr','rmarkdown', 'ggthemes', 'knitr', 'cowplot', 'data.table', 'magrittr','BiocManager', 'devtools','BBmisc', 'heatmaply', 'pheatmap', 'matrixStats', 'plotly', 'plyr', 'PRROC', 'reshape2', 'RcppArmadillo','extraDistr', 'ggrepel', 'VGAM'), rdependencies=TRUE)" \
	&& R -e "BiocManager::install(c('BSgenome.Hsapiens.NCBI.GRCh38','BiocParallel', 'GenomicFeatures', 'SummarizedExperiment', 'BiocGenerics', 'DESeq2', 'GenomicRanges', 'IRanges', 'pcaMethods', 'S4Vectors','GenomicScores', 'BiocVersion', 'BSgenome', 'DelayedMatrixStats', 'HDF5Array', 'rhdf5', 'Rsubread','VariantAnnotation'))"

#need to download this whole git: https://github.com/gagneurlab/drop
COPY drop drop
#can also do RUN wget for each of the following instead of COPY. Your preference.
#https://github.com/gagneurlab/OUTRIDER/archive/refs/tags/1.7.1.tar.gz
COPY 1.7.1.tar.gz 1.7.1.tar.gz
#https://github.com/gagneurlab/drop/archive/refs/tags/1.2.2.tar.gz
COPY 1.2.2.tar.gz 1.2.2.tar.gz
#https://github.com/gagneurlab/tMAE/archive/refs/tags/1.0.4.tar.gz
COPY 1.0.4.tar.gz 1.0.4.tar.gz
#https://bioconductor.org/packages/release/data/annotation/src/contrib/MafDb.gnomAD.r2.1.GRCh38_3.10.0.tar.gz
COPY MafDb.gnomAD.r2.1.GRCh38_3.10.0.tar.gz MafDb.gnomAD.r2.1.GRCh38_3.10.0.tar.gz


RUN pip install ./drop 	&& rm -rf ./drop \
	&& R CMD INSTALL 1.7.1.tar.gz \
	&& rm -f 1.7.1.tar.gz \
	&& R CMD INSTALL 1.2.1.tar.gz \
	&& rm -f 1.2.1.tar.gz \
	&& R CMD INSTALL 1.0.4.tar.gz \
	&& rm -f 1.0.4.tar.gz \
	&& R CMD INSTALL MafDb.gnomAD.r2.1.GRCh38_3.10.0.tar.gz \
	&& rm -f MafDb.gnomAD.r2.1.GRCh38_3.10.0.tar.gz \
	&& rm -rf /tmp/*





