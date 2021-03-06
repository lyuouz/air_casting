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
    IDs
  - Step 3: plug in IDs in the measurement ID API call and get the
    measurements in the form of points

## Step 1

Here are the usernames that I found on the AirCasting website:  
`NYCEJA`, `BLU 12`, `HabitatMap`, `BCCHE`, `scooby`, `Ana BCCHE`,
`Ricardo Esparza`, `Tasha kk`, `lana`, `Marisa Sobel`, `Wadesworld18`,
`El Puente 3`, `El Puente 4`, `El Puente 2`, `El Puente 1`, `mahdin`,
`El Puente 5`, `Asemple`, `patqc`,
`sjuma`

``` r
usernames <- c('NYCEJA', 'BLU%2012', 'HabitatMap', 'BCCHE', 'scooby', 'Ana%20BCCHE', 'Ricardo%20Esparza', 'Tasha%20kk', 'lana', 'Marisa%20Sobel', 'Wadesworld18', 'El%20Puente%201', 'El%20Puente%202', 'El%20Puente%203', 'El%20Puente%204', 'El%20Puente%205', 'mahdin', 'Asemple', 'patqc', 'sjuma')

user_test <- c('NYCEJA', 'HabitatMap', 'BCCHE', 'lana', 'Wadesworld18', 'patqc')
```

write a function that takes one username from the username vector, plugs
it into the API call, and extracts the session IDs

``` r
fetch_id <- function(name){
  api_call <- str_c('http://aircasting.org/api/sessions.json?page=0&page_size=500&q[measurements]=true&q[time_from]=0&q[time_to]=2552648500&q[usernames]=', name)
  api_pull <- jsonlite::fromJSON(api_call)
  user_id <- api_pull$streams$'AirBeam2-PM2.5'$id %>% 
    .[!is.na(.)]

  user_id
}

pulled_ids <- map(usernames, fetch_id) %>% 
  unlist()
```

``` r
# This function plug each ID into the measurement API call and pulls data using that ID
pull_fun <- function(id_element){
  test_sess <- str_c("http://aircasting.org/api/realtime/stream_measurements.json/?end_date=2281550369000&start_date=0&stream_ids[]=",id_element) %>% 
    jsonlite::fromJSON(.) %>% 
    mutate(id = id_element) %>% 
    as_tibble()

  test_sess
}

# the output of pull_fun is a list. Take each element of the list and combine them into a tibble
airbeam_data <- map(pulled_ids, pull_fun) %>% 
  do.call("bind_rows", .)
```

``` r
airbeam_data_tidy = airbeam_data %>% 
  separate(time, into = c("year", "month", "day"), sep = "-") %>% 
  separate(day, into = c("day", "time"), sep = "T") %>% 
  separate(time, into = c("hour", "min", "sec"), sep = ":") %>% 
  separate(sec, into = c("sec", "remove"), sep = "Z") %>% 
  select(-remove)
```
