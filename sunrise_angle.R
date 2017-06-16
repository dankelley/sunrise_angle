## Start our sunrise-time search at 8AM UTC, or about 4AM local

t0 <- as.POSIXct(sprintf("%s 04:00:00", Sys.Date()), tz="UTC")

## Centre map on Halifax
lon <- -63.60
lat <- 44.66

library(oce)

## Function to find sunrise time
sunrise <- numberAsPOSIXct(uniroot(function(t)
                                   sunAngle(t, lat=lat, lon=lon, useRefraction=TRUE)$altitude,
                                   interval=as.numeric(t0 + 3600*c(2,13)))$root)
sunset <- numberAsPOSIXct(uniroot(function(t)
                                  sunAngle(t, lat=lat, lon=lon, useRefraction=TRUE)$altitude,
                                  interval=as.numeric(t0 + 3600*c(13,22)))$root)


## redefine azimuth direction for plotting
azimuthSunrise <- 90 - sunAngle(sunrise, latitude=lat, longitude=lon)$azimuth
azimuthSunset <- 90 - sunAngle(sunset, latitude=lat, longitude=lon)$azimuth

library(OpenStreetMap)

mapSpanInDegrees <- c(10, 50)
for (i in seq <- seq_along(mapSpanInDegrees)) {
    D <- mapSpanInDegrees[i] / 111     # km
    Dlon <- D / cos(lat * pi / 180)   # longitude
    map <- openmap(c(lat=lat+D/2, lon=lon-Dlon/2), c(lat=lat-D/2, lon=lon+Dlon/2), minNumTiles=9)
    
    filename <- paste("/Users/kelley/Sites/sunrise_angle/sunrise_angle_", i, ".png", sep="")
    if (!interactive()) png(filename, width=900, height=900, res=120, pointsize=10)
    par(mar=c(0.5, 0.5, 1, 0.5))
    plot(map, removeMargin=FALSE)

    ## Draw lines along which rays of the sun are aligned at sunrise and sunset.
    cx <- mean(par('usr')[1:2])
    cy <- mean(par('usr')[3:4])
    d <- diff(par('usr')[3:4]) # scales as the map
    for (o in d*seq(-1, 1, length.out=30)) {
        lines(cx+c(-1,1)*d*cos(azimuthSunrise*pi/180),
              cy+o+c(-1,1)*d*sin(azimuthSunrise*pi/180), col='brown1', lwd=3)
        lines(cx+c(-1,1)*d*cos(azimuthSunrise*pi/180),
              cy+o+c(-1,1)*d*sin(azimuthSunrise*pi/180), col='darkgoldenrod1', lwd=1.75)
    }
    ## Label in local time
    attributes(sunrise)$tzone <- "America/Halifax"
    mtext(paste(format(sunrise, "%a %d %b, %Y"), ": sunrise at ", format(sunrise, "%H:%M %Z"), sep=""),
          side=3, line=0, adj=0.5)
    if (!interactive()) dev.off()

    
    filename <- paste("/Users/kelley/Sites/sunrise_angle/sunset_angle_", i, ".png", sep="")
    if (!interactive()) png(filename, width=900, height=900, res=120, pointsize=10)
    par(mar=c(0.5, 0.5, 1, 0.5))
    plot(map, removeMargin=FALSE)

    ## Draw lines along which rays of the sun are aligned at sunrise and sunset.
    cx <- mean(par('usr')[1:2])
    cy <- mean(par('usr')[3:4])
    d <- diff(par('usr')[3:4]) # scales as the map
    for (o in d*seq(-1, 1, length.out=30)) {
        lines(cx+c(-1,1)*d*cos(azimuthSunset*pi/180),
              cy+o+c(-1,1)*d*sin(azimuthSunset*pi/180), col='brown1', lwd=3)
        lines(cx+c(-1,1)*d*cos(azimuthSunset*pi/180),
              cy+o+c(-1,1)*d*sin(azimuthSunset*pi/180), col='darkgoldenrod1', lwd=1.75)
    }
    ## Label in local time
    attributes(sunset)$tzone <- "America/Halifax"
    mtext(paste(format(sunset, "%a %d %b, %Y"), ": sunset at ", format(sunset, "%H:%M %Z"), sep=""),
          side=3, line=0, adj=0.5)
    if (!interactive()) dev.off()
}
