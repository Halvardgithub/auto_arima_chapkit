source("scripts/utils.R")
library(dplyr)
library(fable)
library(tsibble)
library(lubridate)

train_chap <- function(csv_fn) {
  dataframe_list <- get_df_per_location(csv_fn)
  
  models <- list()
  for (location in names(dataframe_list)){
    model <- train_single_region(dataframe_list[[location]], location)
    models[[location]] <- model
  }
  saveRDS(models, file="model.rds")
}

train_single_region <- function(df, location){
  # REMOVED: create_lagged_feature("rainfall", ...)
  # REMOVED: create_lagged_feature("mean_temperature", ...)
  # REMOVED: cut_top_rows(...)
  
  # We just need to convert the dataframe to a tsibble
  df_tsibble <- mutate(df, time_period = yearmonth(time_period)) |> 
    as_tsibble(index = time_period)
  
  # CHANGED: The model formula is now univariate (no regressors)
  # It models disease_cases based only on its own past values.
  model <- df_tsibble |>
    model(
      ARIMA(disease_cases) 
    )
  
  return(model)
}

# --- CLI entry point ---
args <- commandArgs(trailingOnly = TRUE)

data_fn <- "data.csv"


for (i in seq_along(args)) {
  if (args[i] == "--data" && i < length(args)) data_fn <- args[i + 1]
}

if (!interactive()) {
  cat("Training model...\n")
  cat("Data:", data_fn, "\n")
  train_chap(data_fn)
}