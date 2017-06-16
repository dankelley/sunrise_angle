## NOTE: several things here are specific to Halifax, and to Dan Kelley's
## computer. He can make things more general, if others want to use the code;
## readers should feel free to post an 'issue' on the github site
##     https://github.com/dankelley/sunrise_angle/issues
## to request some help in that or any problems that (ahem) arise.

## Centre map on Halifax
lon <- -63.60
lat <- 44.66

library(oce)

## Find sunrise and sunset times as times when sun crosses
## horizon. I'm using uniroot() with preset intervals, although obviously
## there are other ways that should be explored to port this to other
## spots on the globe.
t0 <- as.POSIXct(sprintf("%s 04:00:00", Sys.Date()), tz="UTC")
sunrise <- numberAsPOSIXct(uniroot(function(t)
                                   sunAngle(t, longitude=lon, latitude=lat, useRefraction=TRUE)$altitude,
                                   interval=as.numeric(t0 + 3600*c(2,10)))$root)
sunset <- numberAsPOSIXct(uniroot(function(t)
                                  sunAngle(t, longitude=lon, latitude=lat, useRefraction=TRUE)$altitude,
                                  interval=as.numeric(t0 + 3600*c(18,25)))$root)
rise <- sunAngle(sunrise, longitude=lon, latitude=lat, useRefraction=TRUE)
set <- sunAngle(sunset, longitude=lon, latitude=lat, useRefraction=TRUE)

## debugging
##> message("sunrise at ", sunrise, " UTC", ", altitude=", rise$altitude, ", azimuth=", rise$azimuth)
##> message("sunset at ", sunset, " UTC", ", altitude=", set$altitude, ", azimuth=", set$azimuth)

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
        angle <- pi * (90 - rise$azimuth) / 180
        lines(cx+c(-1,1)*d*cos(angle),
              cy+o+c(-1,1)*d*sin(angle), col='brown1', lwd=3)
        lines(cx+c(-1,1)*d*cos(angle),
              cy+o+c(-1,1)*d*sin(angle), col='darkgoldenrod1', lwd=1.75)
    }
    ## Label in local time
    risetime <- sunrise
    attributes(risetime)$tzone <- "America/Halifax"
    mtext(paste(format(risetime, "%a %d %b, %Y"), ": sunrise at ", format(risetime, "%H:%M %Z"),
               sprintf(" at azimuth %.0f", rise$azimuth),  sep=""),
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
        angle <- pi * (90 - set$azimuth) / 180
        lines(cx+c(-1,1)*d*cos(angle),
              cy+o+c(-1,1)*d*sin(angle), col='brown1', lwd=3)
        lines(cx+c(-1,1)*d*cos(angle),
              cy+o+c(-1,1)*d*sin(angle), col='darkgoldenrod1', lwd=1.75)
    }
    ## Label in local time
    settime <- sunset
    attributes(settime)$tzone <- "America/Halifax"
    mtext(paste(format(settime, "%a %d %b, %Y"), ": sunset at ", format(settime, "%H:%M %Z"),
               sprintf(" at azimuth %.0f", set$azimuth),  sep=""),
          side=3, line=0, adj=0.5)
    if (!interactive()) dev.off()
}
