##### Importing and Cleaning Coyote Movement Data #####

library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(lubridate)

# Import data from retrieved gps collars

collar_id_154955 <- read_csv("01_Raw_data/PinPoint 154955 2024-10-17 10-11-29.csv", skip = 4)
collar_id_154963 <- read_csv("01_Raw_data/PinPoint 154963 2024-08-02 11-02-41.csv", skip = 4)
collar_id_154964 <- read_csv("01_Raw_data/PinPoint 154964 2024-06-11 14-11-47.csv", skip = 4)


# Checking structure and format of data frames
str(collar_id_154955)
