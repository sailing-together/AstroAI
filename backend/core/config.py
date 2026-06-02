from functools import cached_property

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: str = "development"
    backend_cors_origins: str = "http://localhost:3000"

    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str
    supabase_jwt_secret: str

    database_url: str
    redis_url: str

    gemini_api_key: str
    gemini_primary_model: str = "gemini-2.5-flash"
    gemini_light_model: str = "gemini-2.5-flash-lite"
    gemini_timeout_seconds: int = 30
    gemini_max_retries: int = 3

    ai_chat_free_daily_limit: int = 3
    ai_chat_premium_daily_limit: int = 50

    stripe_secret_key: str | None = None
    stripe_webhook_secret: str | None = None
    stripe_premium_price_id: str | None = None

    google_places_api_key: str | None = None
    fcm_server_key: str | None = None

    @cached_property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.backend_cors_origins.split(",") if origin.strip()]


settings = Settings()
