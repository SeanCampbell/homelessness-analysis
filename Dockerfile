# docker build . -t homelessness-analysis
# docker run -it \
# 	-p 8888:8888 -v "/Users/Sean/Documents/School/Grad School/[6910] Applied Econometrics/Research Project/Code":/research \
# 	homelessness-analysis bash
#
# jupyter notebook --allow-root --no-browser --ip 0.0.0.0
#
FROM python:3.11

RUN pip install geopandas openpyxl jupyter
RUN pip install --upgrade ipykernel

WORKDIR /research
