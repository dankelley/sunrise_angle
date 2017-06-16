# Setup

First, to ensure that the R packages `"OpenStreetMap"` and `"oce"` are
installed. After that, it makes sense to try a test case by loading R and doing

```bash
source("sunrise_angle.R")
```

which should create a graph for sunrise, and overplot it with a graph for
sunset. The processing will take up to half a minute, mainly because of the
time taken for `OpenStreetMap:openmap()` to download the image tiles for the
map. Things could be improved by caching the map data, and that would make
sense for an application that updated every minute, but not for something that
runs just once per day to calculate sunrise and sunset conditions.


# Crontab entries to create graphs for a website

The graphs are updated at 2AM each day, local time.

```
0 2 * * * /usr/local/bin/R --no-save < /Users/kelley/Sites/sunrise_angle/sunrise_angle.R >/Users/kelley/stdout.log 2>/Users/kelley/stderr.log
```

