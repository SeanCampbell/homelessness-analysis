# Data Sources

- Average weather by state: [USA.com](http://www.usa.com/rank/us--average-temperature--state-rank.htm)


# Running the code

```
docker run -it \
	-p 8888:8888 -v "/Users/Sean/Documents/School/Grad School/[6910] Applied Econometrics/Research Project/Code":/research \
	homelessness-analysis bash
```

Within the docker container, run:

```
jupyter notebook --allow-root --no-browser --ip 0.0.0.0
```
