env_name                = "usw2dev"
schedule_daily_utc_time = ["00:00", "15:00"]
lambda_environment_variables = {
  "NODE_ENV"        = "production"
  "MODEL_NAME"      = "gemini-3-flash-preview"
  "EMAIL_SENDER"    = "do-not-reply@gp-news.perryz.net"
}

ssm_parameters = {
  "TWELVE_DATA_API_KEY_SSM" = "/gp-news/twelve-data-api-key"
  "NEWS_DATA_API_KEY_SSM"   = "/gp-news/news-data-api-key"
  "AI_API_KEY_SSM"          = "/gp-news/ai-api-key"
  "EMAIL_RECEIVERS"         = "/gp-news/email-receivers"
}
