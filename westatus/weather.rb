require "httparty"

class Weather
  def initialize(config)
    @config = config

    @forecast = nil
    Thread.new do
      loop do
        response = HTTParty.get("https://api.open-meteo.com/v1/forecast?latitude=#{@config.data["weather"]["latitude"]}&longitude=#{@config.data["weather"]["longitude"]}&timezone=GMT&hourly=temperature_2m,precipitation_probability,precipitation,weather_code&forecast_days=2")

        @forecast = JSON.parse(response.body)

        sleep([@config.data["weather"]["sync_frequency"] || 1800, 100].max)
      end
    end
  end

  def get_weather()
    return "No weather data" unless @forecast

    current_hour = Time.now.utc.hour
    forecast_hour = Time.now.utc.hour + (@config.data["weather"]["forecast_hours"] || 3)

    s = @config.data["weather"]["format"] || ""

    s = s
        .gsub("{{ current_icon }}", get_icon_from_code(@forecast["hourly"]["weather_code"][current_hour]))
        .gsub("{{ current_temp }}", @forecast["hourly"]["temperature_2m"][current_hour].to_s)
        .gsub("{{ trend_icon }}", trend)
        .gsub("{{ forecast_icon }}", get_icon_from_code(@forecast["hourly"]["weather_code"][forecast_hour]))
        .gsub("{{ forecast_temp }}", @forecast["hourly"]["temperature_2m"][forecast_hour].to_s)

    return s
  end

  def trend()
    current_hour = Time.now.utc.hour
    forecast_hour = Time.now.utc.hour + (@config.data["weather"]["forecast_hours"] || 3)

    current_temperature = @forecast["hourly"]["temperature_2m"][current_hour]
    forecasted_temperature = @forecast["hourly"]["temperature_2m"][forecast_hour]

    delta = (current_temperature - forecasted_temperature).round

    if delta > 0
      "\uF30E"
    elsif delta < 0
      "\uF310"
    else
      "\uF30F"
    end
  end

  # translated from c# by chatgpt
  def get_icon_from_code(weather_code)
    # Codes from https://open-meteo.com/en/docs
    # Scroll all the way down
    # Why don't these docs use markdown, wtf

    is_daytime = is_day_time?(Time.now)

    case weather_code
    when 0
      is_daytime ? "\uF00D" : "\uF02E"
    when 1
      is_daytime ? "\uF00C" : "\uF031"
    when 2
      is_daytime ? "\uF002" : "\uF031"
    when 3
      "\uF013"
    when 45, 48
      "\uF063"
    when 51, 61, 80
      "\uF017"
    when 53, 63, 81
      "\uF015"
    when 55, 65, 82
      "\uF019"
    when 56, 57, 66, 67
      "\uF01A"
    when 71, 73, 75, 77, 85, 86
      "\uF01B"
    when 95
      "\uF01D"
    when 96, 99
      "\uF01E"
    else
      "\uF049"
    end
  end

  # translated from c# by chatgpt
  def is_day_time?(current_time)
    day_start = Time.new(current_time.year, current_time.month, current_time.day, 6, 0, 0)
    day_end = Time.new(current_time.year, current_time.month, current_time.day, 18, 0, 0)

    current_time >= day_start && current_time <= day_end
  end
end
