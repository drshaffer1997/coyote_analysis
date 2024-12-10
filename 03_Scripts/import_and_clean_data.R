# Creator: Dakotah Shaffer
# Date: 12/10/2024
# email: dakotahrshaffer@gmail.com


##### Importing and Cleaning Coyote Movement Data #####

library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(lubridate)

# Import coyote movement data from retrieved gps collars

collar_id_154955 <- read_csv("01_Raw_data/deluca/PinPoint 154955 2024-10-17 10-11-29.csv", skip = 4)
collar_id_154963 <- read_csv("01_Raw_data/deluca/PinPoint 154963 2024-08-02 11-02-41.csv", skip = 4)
collar_id_154964 <- read_csv("01_Raw_data/deluca/PinPoint 154964 2024-06-11 14-11-47.csv", skip = 4)


# Import coyote capture and data on when collar and coyote were both still active and data viable

coyote_info <- read_csv("01_Raw_data/collared_coyote_info.csv") |> 
  mutate(collar_id = as.factor(collar_id))  # factor to join layer later

# Create loop to import and merge gps collar data

deluca_files <- list.files(path = "01_Raw_data/deluca", pattern = "PinPoint")

num_files <- length(deluca_files)

for (i in 1:num_files){
  filename <- deluca_files[i]
  data <- read_csv(paste0("01_Raw_data/deluca/", filename), skip = 4)   ######## code currently is not working... meet with Geraldine###
}

data
# Add column with collar id

collar_id_154955 <- collar_id_154955 |> 
  mutate(collar_id = "154955")

collar_id_154963 <- collar_id_154963 |> 
  mutate(collar_id = "154963")

collar_id_154964 <- collar_id_154964 |> 
  mutate(collar_id = "154964")

# Merge data frames from each collar into one

all_collar_data <- rbind(collar_id_154955, collar_id_154963, collar_id_154964) |> 
  mutate(collar_id = as.factor(collar_id))

# Join coyote movement data with coyote info data

all_collar_data_join_info <- left_join(all_collar_data, coyote_info)

# Checking structure and format of data frames
str(all_collar_data_join_info)


# Convert timestamp column into correct format

all_collar_data_join_info <- all_collar_data_join_info |> 
  rename(gmt_date_time = `GMT Time`) |> 
  mutate(gmt_date_time = as.POSIXct(gmt_date_time, "%m/%d/%Y %H:%M:%S", tz="GMT"),
         date_deployed = as.POSIXct(date_deployed, "%m/%d/%Y", tz="GMT"),
         dropoff_or_mortality = as.POSIXct(dropoff_or_mortality, "%m/%d/%Y", tz="GMT"))



##### !!!!!!!!!!Need to find a way that's reproducible to filter dates... can I filter dates for
##### different groups within a column or do I need to make them seperate data frames?

# Filter viable dates for each coyote

all_collar_data_join_info

#######   Explore the data   #######

# check how many locations for each collar
all_collar_data_join_info |> 
  group_by(collar_id) |> 
  summarise(n = n())


# check if how many satellites were used for points

all_collar_data_join_info |> 
  group_by(Satellites) |> 
  summarise(n = n())    #### There are several points with no satellites recorded



# plot points for each collar to see if their any major outliers

  all_collar_data_join_info |> 
  ggplot(aes(x = Longitude, y = Latitude)) +
  geom_path(aes(group = collar_id, color = collar_id), size = 0.25) +
  scale_color_viridis_d() +
  theme_bw()


# Time series movement of latitude

all_collar_data_join_info |> 
  ggplot() +
  geom_line(aes(x = gmt_date_time, y = Latitude, color = collar_id), size = 0.2) +
  scale_color_viridis_d() +
  theme_bw() +
  facet_wrap(~collar_id, scales = "free")


# Time series movmenet of longitude
plotly::ggplotly(
all_collar_data_join_info |> 
  ggplot() +
  geom_line(aes(x = gmt_date_time, y = Longitude, color = collar_id), size = 0.2) +
  scale_color_viridis_d() +
  theme_bw() +
  facet_wrap(~collar_id, scales = "free"))

# Using Shiny app from package bayesmove that I found from youtube video by Josh Cullen

all_collar_data_join_info |> 
  rename(id = collar_id,
         date = gmt_date_time,
         x = Longitude,
         y = Latitude) |> 
  bayesmove::shiny_tracks(epsg = 4326)



### Turn into spatial dataframe then calculate how fast coyotes are moving
# Visualization book 