defmodule ExTuya.Light do
  def turn_on(access_token, device_id) do
    ExTuya.device_control(access_token, device_id, "turnOnOff", "1")
  end

  def turn_off(access_token, device_id) do
    ExTuya.device_control(access_token, device_id, "turnOnOff", "0")
  end

  def set_brightness(access_token, device_id, brightness) do
    ExTuya.device_control(access_token, device_id, "brightnessSet", brightness)
  end

  def set_color(access_token, device_id, hue, saturation, brightness) do
    ExTuya.device_control(access_token, device_id, "colorSet", %{
      hue: hue,
      saturation: saturation,
      brightness: brightness
    })
  end

  def set_color_temperature(access_token, device_id, temperature) do
    ExTuya.device_control(access_token, device_id, "colorTemperatureSet", temperature)
  end
end
