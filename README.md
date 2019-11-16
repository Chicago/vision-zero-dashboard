# Vision Zero Dashboard

last updated: 11/16/2019 12:26 PM CST

## About the Meetup

This is the repository to support the meetup, the signup is here:

https://www.meetup.com/Chicago-R-User-Group/

## Background on Vision Zero

Vision Zero Chicago (VZC) is the commitment and approach to eliminating fatalities and serious injuries from traffic crashes.

Much more information is available in the Action Plan, and the City’s website:
https://www.chicago.gov/city/en/depts/cdot/supp_info/vision-zero-chicago.html

The plan emphasizes reporting and accountability in an transparent manner. To this end, the VZ committee has requested a public facing dashboard that communicates our progress toward Vision Zero goals, which can be referenced internally and externally.

## The Vision Zero Dashboard

The purpose of the proposed dashboard is to help Vision Zero Chicago achieve its mission, and increase transparency and accountability.

There are a wide variety of ways this information could be communicated, and technologies that could be used.  We feel that it would be best to begin with open source software and open data. The most relevant data that we would want to communicate is already publicly available on the open data portal: https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if

The data sets include crash, vehicle, and person information reported into our eCrash system.  These data sets are updated on a daily basis.

We are also working with IDOT to determine how we can incorporate data for prior years so that we can accurately measure progress toward goals, and identify trends.

### Elements of the dashboard:

- Progress toward Vision Zero goals
- Cause of crash
- Was the crash in a High Crash Corridor
- Demographics impacted by crashes
- Summaries by time of day, day of week, season
- Anything that would provide insight to help prevent crashes

Examples of dashboards from other cities, and Illinois:

- [Illinois IDOT](http://apps.dot.illinois.gov/fatalcrash/snapshot.html)
- [Seattle](https://sdotblog.seattle.gov/2016/06/10/new-vision-zero-dashboard-now-online/)
- [Denver](https://public.tableau.com/profile/kmay#!/vizhome/DenverVisionZeroDashboard/OverviewofDenverCrashes)
- Portland (offline was [this](https://pdx.maps.arcgis.com/sharing/rest/oauth2/authorize?client_id=arcgisonline&display=default&response_type=token&state=%7B%22returnUrl%22%3A%22https%3A%2F%2Fpdx.maps.arcgis.com%2Fapps%2FMapSeries%2Findex.html%3Fappid%3D47c2153a3fa84636bb63e25b451372d0%22%2C%22useLandingPage%22%3Afalse%7D&expiration=20160&locale=en-us&redirect_uri=https%3A%2F%2Fpdx.maps.arcgis.com%2Fhome%2Faccountswitcher-callback.html&force_login=false&hideCancel=true&showSignupOption=true&signuptype=esri))
- [Washington DC](https://www.dcvisionzero.com/maps-data)
- [San Francisco](https://www.visionzerosf.org/maps-data/)
- [Los Angeles](http://visionzero.geohub.lacity.org/)
- [New York (citizen created)](http://crashmapper.org/#/?cfat=true&cinj=true&endDate=2019-02&geo=citywide&identifier=&lat=40.696518118094616&lng=-73.91738891601562&lngLats=%255B%255D&mfat=true&minj=true&noInjFat=false&pfat=true&pinj=true&startDate=2019-02&zoom=11)
- [New York (official)](http://www.nycvzv.info/)
- [Toronto](https://www.toronto.ca/services-payments/streets-parking-transportation/road-safety/vision-zero/safety-measures-and-mapping/)

## Technical Details

Please fork, clone, push, and then issue pull requests to the Chicago repository. Please use the issues in Chicago for general discussion, unless you have topics specific to your group.  The d`discussion` tag indicates discussion areas.

To install `geneorama` please uuse devtools, `devtools::install_github("geneorama/geneorama")`

Please use the metadata for the crash data in `data-idot` to understand the nuance of the crash data.

Gnenerally speaking, reference data can be found in the `resources\` folder, including a Word Document with dashboard examples. The final example in that document is a template created by CDOT which represents a great starting point.  From a technical perspective, check out the `example-shiny-crashes\` app.  

** Please use issues!  Let us know what you're thinking. 


## About the Chicago R User Group and Shiny

The CRUG Organization is focused on R, which is an open source language with broad application and compatibility with other technology. The open source software company R Studio has developed a library that works with R to create modern, secure, websites.

You can learn more about the web development software, and view examples here:
https://shiny.rstudio.com
https://shiny.rstudio.com/gallery/
 

<img src="https://design.chicago.gov/assets/img/seals/1990-blue.png" width="400" alt="City Seal of Chicago"/>
