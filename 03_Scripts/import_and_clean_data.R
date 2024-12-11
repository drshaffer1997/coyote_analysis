# Creator: Dakotah Shaffer
# Date: 12/10/2024
# email: dakotahrshaffer@gmail.com


##### Importing and Cleaning Coyote Movement Data #####

library(tidyverse)

# Import coyote movement data from retrieved gps collars

# collar_id_154955 <- read_csv("01_Raw_data/deluca/PinPoint 154955 2024-10-17 10-11-29.csv", skip = 4)
# collar_id_154963 <- read_csv("01_Raw_data/deluca/PinPoint 154963 2024-08-02 11-02-41.csv", skip = 4)
# collar_id_154964 <- read_csv("01_Raw_data/deluca/PinPoint 154964 2024-06-11 14-11-47.csv", skip = 4)


# Import coyote capture and data on when collar and coyote were both still active and data viable

coyote_info <- read_csv("01_Raw_data/collared_coyote_info.csv") |> 
  mutate(collar_id = as.factor(collar_id)) |>  # factor to join layer later 
  dplyr::select(collar_id, study_area, date_deployed, dropoff_or_mortality)

# List all relevant files in the directory
deluca_files <- list.files(path = "01_Raw_data/deluca", 
                           pattern = "PinPoint", 
                           full.names = TRUE)  # Include the full path to read files directly

# Initialize an empty list to store data frames
all_data <- list()

for (filename in deluca_files) {                           # Loop through each file and process
  data <- read_csv(filename, skip = 4)                     # Read the CSV file, skipping the first 4 rows
  data$collar_id <- str_sub(basename(filename), 10, 15)    # Add a column for the collar_id extracted from the filename
  all_data[[length(all_data) + 1]] <- data                 # Append the processed data to the list
}

deluca_collar_data <- bind_rows(all_data)  # Combine all data frames into a single data frame

head(deluca_collar_data)   # View the combined data

deluca_collar_data <- deluca_collar_data |> 
  mutate(collar_id = as.factor(collar_id))

# Join coyote movement data with coyote info data

all_collar_data_join_info <- left_join(deluca_collar_data, coyote_info)

# Checking structure and format of data frames
str(all_collar_data_join_info)


# Convert timestamp column into correct format

all_collar_data_join_info <- all_collar_data_join_info |> 
  rename(gmt_date_time = `GMT Time`) |> 
  mutate(gmt_date_time = as.POSIXct(gmt_date_time, "%m/%d/%Y %H:%M:%S", tz="GMT"),
         date_deployed = as.POSIXct(date_deployed, "%m/%d/%Y", tz="GMT"),
         dropoff_or_mortality = as.POSIXct(dropoff_or_mortality, "%m/%d/%Y", tz="GMT"))


# Filter viable dates for each coyote

all_collar_data_join_info <- all_collar_data_join_info |> 
  filter(gmt_date_time >= date_deployed & gmt_date_time <= dropoff_or_mortality)
  

#######   Explore the data   #######

# check how many locations for each collar
all_collar_data_join_info |> 
  group_by(collar_id) |> 
  summarise(n = n())


# check if how many satellites were used for points

all_collar_data_join_info |> 
  group_by(Satellites) |> 
  summarise(n = n())    # at least 4 satellites are needed to determine location of moving objects


# filter out locations with less than 4 satellites
 all_collar_data_join_info <- all_collar_data_join_info |>
   filter(Satellites >= 4)


# plot points for each collar to see if their any major outliers

deluca_path_plot <- all_collar_data_join_info |> 
  ggplot(aes(x = Longitude, y = Latitude)) +
  geom_path(aes(group = collar_id, color = collar_id), size = 0.25) +
  scale_color_viridis_d() +
  theme_bw()
  
ggsave(filename = "deluca_path_plot.jpg", plot = deluca_path_plot, path = "05_Figures")
  
  
# Time series movement of latitude

deluca_lat_time_plot <- all_collar_data_join_info |> 
  ggplot() +
  geom_line(aes(x = gmt_date_time, y = Latitude, color = collar_id), size = 0.2) +
  scale_color_viridis_d() +
  theme_bw() +
  facet_wrap(~collar_id, scales = "free")

ggsave(filename = "deluca_lat_time_plot.jpg", plot = deluca_lat_time_plot, path = "05_Figures")


# Time series movemenet of longitude
deluca_long_time_plot <- all_collar_data_join_info |> 
  ggplot() +
  geom_line(aes(x = gmt_date_time, y = Longitude, color = collar_id), size = 0.2) +
  scale_color_viridis_d() +
  theme_bw() +
  facet_wrap(~collar_id, scales = "free")

ggsave(filename = "deluca_long_time_plot.jpg", plot = deluca_long_time_plot, path = "05_Figures")


# Using Shiny app from package bayesmove that I found from youtube video by Josh Cullen

all_collar_data_join_info |> 
  rename(id = collar_id,
         date = gmt_date_time,
         x = Longitude,
         y = Latitude) |> 
  bayesmove::shiny_tracks(epsg = 4326)



