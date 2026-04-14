source("scripts/utils.R")
library(dplyr)
library(fable)
library(tsibble)
library(lubridate)
library(distributional) #to extract info from dist objects

predict_chap <- function(historic_data_fn, future_climatedata_fn, predictions_fn) {
  # Note: 'future_climatedata_fn' is now only used to get the
  # list of locations and the number of steps to forecast (the horizon, h).
  future_per_location <- get_df_per_location(future_climatedata_fn)
  historic_per_location <- get_df_per_location(historic_data_fn)
  models <- readRDS("model.rds") # Assumes the model was saved using saveRDS
  first_location <- TRUE
  
  for (location in names(future_per_location)){
    df <- future_per_location[[location]]
    historic_df <- historic_per_location[[location]]
    model <- models[[location]]
    
    # CHANGED: Get the forecast horizon 'h' from the future_df
    h_steps <- nrow(df)
    
    # REMOVED: The section that rbinds and creates lags
    # We create the historic_tible directly
    historic_tible <- historic_df |> 
      mutate(time_period = yearmonth(time_period)) |>
      as_tsibble(index = time_period)
    
    model = refit(model, historic_tible)
    
    # CRITICAL CHANGE:
    # We no longer pass 'new_data' since the model has no regressors.
    # Instead, we pass 'h = h_steps' to tell it how far to forecast.
    predicted_dists <- forecast(model, h = h_steps)
    
    n_samples <- 100
    # CHANGED: Use h_steps instead of nrow(future_tible)
    preds <- data.frame(matrix(ncol = n_samples, nrow = h_steps))
    
    colnames(preds) <- paste("sample", 0:(n_samples-1), sep = "_")
    
    # CHANGED: Use h_steps
    for(i in 1:h_steps){
      dist <- predicted_dists[i, "disease_cases"]$disease_cases
      preds[i,] <- rnorm(n_samples, mean = mean(dist), sd = sqrt(variance(dist)))
    }
    
    # This cbinds the future time/location info (from df)
    # with the new predictions (from preds)
    sample_df <- cbind(df, preds) 
    
    if (first_location){
      full_df <- sample_df
      first_location <- FALSE
    }
    else {
      full_df <- rbind(full_df, sample_df)
    }
  }
  
  # REMOVED: 'full_df["time_period"] <- df["time_period"]'
  # This was a bug, it would overwrite all time_periods with the last one.
  # full_df already has the correct time_period column from the rbind.
  
  write.csv(full_df, predictions_fn, row.names = FALSE)
}

# --- CLI entry point ---
args <- commandArgs(trailingOnly = TRUE)

hist_fn <- "historic.csv"
future_fn <- "future.csv"
preds_fn <- "predictions.csv"

for (i in seq_along(args)) {
  if (args[i] == "--historic" && i < length(args)) hist_fn <- args[i + 1]
  if (args[i] == "--future" && i < length(args)) future_fn <- args[i + 1]
  if (args[i] == "--output" && i < length(args)) preds_fn <- args[i + 1]
}

if (!interactive()) {
  cat("Running predictions...\n")
  cat("Historic:", hist_fn, "\n")
  cat("Future:", future_fn, "\n")
  cat("Output:", preds_fn, "\n")
  predict_chap(hist_fn, future_fn, preds_fn)
}