##### Importing and Cleaning Coyote Movement Data #####

library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(lubridate)

# Import data from retrieved gps collars

collar_id_154955 <- read_csv("01_Raw_data/deluca/PinPoint 154955 2024-10-17 10-11-29.csv", skip = 4)
collar_id_154963 <- read_csv("01_Raw_data/deluca/PinPoint 154963 2024-08-02 11-02-41.csv", skip = 4)
collar_id_154964 <- read_csv("01_Raw_data/deluca/PinPoint 154964 2024-06-11 14-11-47.csv", skip = 4)

# Create loop to import and merge gps collar data

deluca_files <- list.files(path = "01_Raw_data/deluca", pattern = "PinPoint")

num_files <- length(deluca_files)

for (i in 1:num_files){
  filename <- deluca_files[i]
  data <- read_csv("01_Raw_data/deluca")   ######## code currently is not working... meet with Geraldine###
}

data
# Add column with gps id

collar_id_154955 <- collar_id_154955 |> 
  mutate(collar_id = "154955")

collar_id_154963 <- collar_id_154963 |> 
  mutate(collar_id = "154963")

collar_id_154964 <- collar_id_154964 |> 
  mutate(collar_id = "154964")

# Merge data frames for each collar

all_collar_data <- rbind(collar_id_154955, collar_id_154963, collar_id_154964) |> 
  mutate(collar_id = as.factor(collar_id))

# Checking structure and format of data frames
str(all_collar_data)


# Convert timestamp column into correct format

all_collar_data <- all_collar_data |> 
  rename(gmt_date_time = `GMT Time`) |> 
  mutate(gmt_date_time = as.POSIXct(gmt_date_time, "%m/%d/%Y %H:%M:%S", tz="GMT"))


#######   Explore the data   #######

# check how many locations for each collar
all_collar_data |> 
  group_by(collar_id) |> 
  summarise(n = n())


# check if how many satellites were used for points

all_collar_data |> 
  group_by(Satellites) |> 
  summarise(n = n())    #### There are several points with no satellites recorded


