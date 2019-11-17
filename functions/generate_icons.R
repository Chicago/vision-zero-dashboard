# use point symbols from base R graphics as icons
# pchIcons <- function(pch = 0:14, width = 30, height = 30, ...) {
#     n <- length(pch)
#     files <- character(n)
#     # create a sequence of png images
#     for (i in seq_len(n)) {
#         f <- tempfile(fileext = ".png")
#         png(f, width = width, height = height, bg = "transparent")
#         par(mar = c(0, 0, 0, 0))
#         plot.new()
#         points(.5, .5, pch = pch[i], cex = min(width, height) / 8, ...)
#         dev.off()
#         files[i] <- f
#     }
#     files
# }


generate_icons <- function(iconpath = "data-icons", w=30, h=30, colors, pch, ...){
    # w=30;h=30
    # pch <- icon_data[!is.na(color), pch]
    # colors <- icon_data[!is.na(color), color]
    icons <- character(length = length(colors))
    for(i in 1:length(colors) ){
        # i=1
        f <- file.path(iconpath, 
                       paste0("icon", sprintf("%i", i), ".png"))
        png(f, width = w, height = h, bg = "transparent")
        par(mar = c(0, 0, 0, 0))
        plot.new()
        points(.5, .5, pch = pch[i], 
               cex = min(w, h) / 8 , 
               col = colors[i],
               ...)
        # points(0,0)
        # points(1,1)
        # points(0,1)
        # points(1,0)
        dev.off()
        # icons[[i]] <- list(iconUrl = f,
        #                    iconSize = c(w, h))
        icons[i] <- f
    }
    return(icons)
}
#

