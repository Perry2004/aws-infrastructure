env_name                = "usw2dev"
schedule_daily_utc_time = ["00:00", "15:00"]
lambda_environment_variables = {
  "NODE_ENV"     = "production"
  "MODEL_NAME"   = "gemini-3-flash-preview"
  "EMAIL_SENDER" = "do-not-reply@gp-news.perryz.net"
}

ssm_parameters = {
  "NEWS_DATA_API_KEY"      = "news_data_api_key"
  "BASE_URL"               = "base_url"
  "MODEL"                  = "model"
  "LLM_API_KEY"            = "llm_api_key"
  "LLM_PROVIDER_IGNORE"    = "llm_provider_ignore"
  "EMAIL_FROM"             = "email_from"
  "EMAIL_TO"               = "email_to"
  "BRIEFING_HISTORY_TABLE" = "gp-news-usw2dev-briefing-history"
}

lambda_timeout_seconds = 900 # 15 minutes
