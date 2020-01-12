defmodule ExTuya do
  @tuya_eu "https://px1.tuyaeu.com/homeassistant"

  alias ExTuya.Credentials
  alias ExTuya.Light

  @moduledoc """
  Documentation for ExTuya.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExTuya.hello()
      :world

  """
  def test_login() do
    {:ok, %{"access_token" => access_token}} =
      login(%Credentials{
        userName: "me@sodapop.se",
        password: "Password1",
        countryCode: "46",
        bizType: "tuya"
      })

    {:ok, devices} = get_devices(access_token)

    for device <- devices, device["dev_type"] == "light" do
      Light.set_color(access_token, device["id"], 1, 1, 1)
    end
  end

  def login(credentials = %Credentials{}) do
    {:ok, response} =
      Mojito.post(
        @tuya_eu <> "/auth.do",
        [{"Content-Type", "application/x-www-form-urlencoded"}],
        URI.encode_query(Map.from_struct(credentials))
      )

    Jason.decode(response.body)
  end

  def device_control(access_token, device_id, action, value, namespace \\ "control") do
    payload = %{
      accessToken: access_token,
      devId: device_id,
      value: value
    }

    data = %{
      header: %{
        name: action,
        namespace: namespace,
        payloadVersion: 1
      },
      payload: payload
    }

    request =
      Mojito.post(
        @tuya_eu <> "/skill",
        [{"Content-Type", "application/json"}],
        Jason.encode!(data)
      )

    with {:ok, response} <- request,
         {:ok, body} <- Jason.decode(response.body) do
      {:ok, body}
    else
      error -> error
    end
  end

  def get_devices(access_token) do
    payload = %{
      accessToken: access_token
    }

    data = %{
      header: %{
        name: "Discovery",
        namespace: "discovery",
        payloadVersion: 1
      },
      payload: payload
    }

    request =
      Mojito.post(
        @tuya_eu <> "/skill",
        [{"Content-Type", "application/json"}],
        Jason.encode!(data)
      )

    with {:ok, response} <- request,
         {:ok, %{"payload" => %{"devices" => devices}}} <- Jason.decode(response.body) do
      {:ok, devices}
    else
      error -> error
    end
  end

  def smap(true), do: "ON"
  def smap(_), do: "OFF"

  def lmap(1), do: 1
  def lmap(0), do: 0
  def lmap(true), do: 1
  def lmap(false), do: 0
  def lmap(item) when item in ["on", "true", "1"], do: 1
  def lmap(_item), do: 0
end
