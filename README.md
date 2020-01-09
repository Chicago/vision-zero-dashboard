# Vision Zero Dashboard

last updated 2020-01-08

## Background on Vision Zero

Vision Zero Chicago (VZC) is the commitment and approach to eliminating fatalities and serious injuries from traffic crashes. The plan emphasizes reporting and accountability in an transparent manner. To this end, the VZ committee has requested a public facing dashboard that communicates our progress toward Vision Zero goals, which can be referenced internally and externally.

Much more information is available in the Action Plan, and the City’s website: https://www.chicago.gov/city/en/depts/cdot/supp_info/vision-zero-chicago.html

## The Vision Zero Dashboard

The purpose of the proposed dashboard is to help Vision Zero Chicago achieve its mission, and increase transparency and accountability.

There are a wide variety of ways this information could be communicated, and technologies that could be used. We feel that it would be best to begin with open source software and open data. The most relevant data that we would want to communicate is already publicly available on the open data portal: https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if

The data sets include crash, vehicle, and person information reported into our eCrash system. These data sets are updated daily.

We are also working with IDOT to determine how we can incorporate data for prior years so that we can accurately measure progress toward goals, and identify trends.

## Example dashboard elements:

- Progress toward Vision Zero goals
- Cause of crash
- Was the crash in a High Crash Corridor
- Demographics impacted by crashes
- Summaries by time of day, day of week, season
- Anything that would provide insight to help prevent crashes

## Examples of dashboards from other cities, and Illinois:

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


More detail and documentation here: [resources/example_dashboards.md](https://github.com/Chicago/vision-zero-dashboard/blob/master/resources/example_dashboards.md)

## How to get involved!

We meet at Chi Hack Night, which is a free weekly event here in Chicago. To learn more and register visit www.chihacknight.org

We have a "vision-zero-dashboard" slack channel in the chihacknight slack, which can join here: http://slackme.chihacknight.org

Please use github issues for any discussion related to devleopment, or just general discussion about contributions.

## Technical requirements

Note: you are welcome to participate without making any technical contributions. 

However, if you want run the code in this repo you will need to:

1. Download [R] (https://www.r-project.org/) (please see the [presentation from Nov 2019](https://github.com/Chicago/vision-zero-dashboard/blob/master/resources/Hackathon%20presentation.pdf) for details if you're unsure how)
2. Download [R Studio](https://rstudio.com/)
3. Open the vision zero project (the file called "vision-zero-dashboard.Rproj")
4. Install packages as needed.  Note, the `geneorama` package is only for convenience.

## Contribution requirements

To make code contributions (i.e. submit any files to the project) please follow this pattern: fork, clone, add, commit, push.  More documentation in [resources/git_fork_management](https://github.com/Chicago/vision-zero-dashboard/blob/master/resources/git_fork_management.md). Note, branching is optional. 

For best results, please let issues guide your contributions! If the pull request is well documented, discussed, and agreed upon within an issue, then it's much easier to accept into the master branch. 

The main thing we need at this point are examples of relationships and visualizations that could become components of a dashboard.  

## Technical details and quick start guides

Please refer to the `resources/` folder for examples. 

 - See https://github.com/Chicago/vision-zero-dashboard/blob/master/resources/example_dashboards.md for examples of dashboards from other geographies.
 - For an advanced technical example, please see the `example-shiny-crashes\` app.  This includes 
 - For a quickstart example of how to read the IDOT data and write it to a CSV please see [resources\quickstart example - write idot data to csv.R](https://github.com/Chicago/vision-zero-dashboard/blob/master/resources/quickstart%20example%20-%20write%20idot%20data%20to%20csv.R)

Important reminder about IDOT crash / person / vehicle data: Please use to the metadata to understand the fields, and please note the [readme](https://github.com/Chicago/vision-zero-dashboard/blob/master/data-idot/README.md) on how to document your use of the data.

To install `geneorama` please use devtools, `devtools::install_github("geneorama/geneorama")`


## About the Chicago R User Group and Shiny

This project was started to support a hackathon hosted through the Chicago R User Group. You can learn more about it here: https://www.meetup.com/Chicago-R-User-Group/

The CRUG Organization is focused on R, which is an open source language with broad application and compatibility with other technology. The open source software company R Studio has developed a library that works with R to create modern, secure, websites.

You can learn more about the web development software, and view examples here:
https://shiny.rstudio.com
https://shiny.rstudio.com/gallery/
 

<img src="https://design.chicago.gov/assets/img/seals/1990-blue.png" width="400" alt="City Seal of Chicago"/>


