# 1. Base Image: Stable 4.4.2 to ensure reproducibility 
FROM rocker/tidyverse:4.4.2

# 2. Metadata
LABEL maintainer="A. Carolina Ledezma-Carrizalez"
USER root

# 3. System Dependencies (Simplified for faster local execution)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl pandoc fonts-roboto libfontconfig1-dev libfreetype6-dev \
    libharfbuzz-dev libfribidi-dev libmagick++-dev \
    libgdal-dev libproj-dev   libgeos-dev \
    libcurl4-openssl-dev libssl-dev libxml2-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* 
    
# 4. Quarto Installation
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    dpkg -i quarto-linux-amd64.deb && rm quarto-linux-amd64.deb

# 5. Working Directory matching your local structure
WORKDIR /home/rstudio/presentacion-flisol

# 6. R Package Installation (Fixed syntax and missing commas) 
RUN R -e "install.packages(c('sf','rmapshaper', 'rnaturalearth', 'stringr', 'geomtextpath', \
    'gdtools', 'patchwork', 'rcartocolor', 'scico', 'tidyverse', 'janitor', \
    'glue', 'ggimage', 'lubridate', 'plotly', 'shiny', 'bslib', 'ggplot2', \
    'dplyr', 'readr', 'ggiraph', 'ggstream', 'languageserver', 'zoo', \
    'ggforce', 'ragg', 'prismatic', 'gfonts', 'httpuv', 'ggtext', 'here', \
    'knitr', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# 7. Copy assets and set permissions (Fixed syntax: COPY source destination) 
COPY . .
RUN chown -R rstudio:rstudio /home/rstudio/presentacion-flisol

# 8. Automatic presentation rendering
RUN quarto render slides.qmd --to html

# 9. Execution of the Shiny application
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/home/rstudio/presentacion-flisol', host='0.0.0.0', port=3838)"]


