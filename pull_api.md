Pull data from AirCasting API
================
Lyuou Zhang
4/7/2019

This `.Rmd` file pulls AirCasting data from API, clean and tidy them.

# Mobile sessions

Now we have fixed sessions and mobile sessions available. Ideally, we
will use mobile sessions to do any analysis, and use fixed sessions as
“knots” to validate the measurements. However, we don’t know any
models that can do that job. Anyway, I will pull data from mobile
sessions first and see what they look like. I will also remove those
that are obviously wrong.

I will follow Chris’s method:

  - Step 1: find usernames from AirCasting website under the MAPS
    session
  - Step 2: plug in usernames in the mobile session API call and get the
    session IDs
  - Step 3: plug in session IDs in the measurement ID API call and get
    the measurements in the form of points

## Step 1

Here are the usernames that I found on the AirCasting website:  
`NYCEJA`, `BLU 12`, `HabitatMap`, `BCCHE`, `scooby`, `Ana BCCHE`,
`Ricardo Esparza`, `Tasha kk`, `lana`, `Marisa Sobel`, `Wadesworld18`,
`El Puente 3`, `El Puente 4`, `El Puente 2`, `El Puente 1`, `mahdin`,
`El Puente 5`, `Asemple`, `patqc`, `sjuma`
