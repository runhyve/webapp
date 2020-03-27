defmodule Webapp.Chargebee.Request do
  # Copied from bhyve.ex
  # TODO: deduplicate?
  def process_response({:ok, %{body: body, status_code: 200}}) do
    rest_process_response(body)
  end

  def process_response({:ok, %{body: body, status_code: 404}}) do
    {:error, body}
  end

  def process_response({:ok, %{body: body, status_code: 403}}) do
    {:error, body}
  end

  def process_response({:ok, %{body: body, status_code: _}}) do
    rest_process_response(body)
  end

  def process_response(%HTTPoison.Response{body: body, status_code: 200}) do
    rest_process_response(body)
  end

  def process_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  def rest_process_response(json) do
    case Jason.decode(json) do
      {:ok, list} -> {:ok, list}
      {:error, error} -> {:error, error}
      {:error, %Jason.DecodeError{data: _error}} -> {:error, "Invalid response"}
    end
  end

  def get_config(endpoint) do
    uri = "#{Application.get_env(:webapp, Webapp.Chargebee)[:endpoint]}/#{endpoint}"
    apikey = Application.get_env(:webapp, Webapp.Chargebee)[:apikey]
    options = [hackney: [ basic_auth: {apikey, ""}]]
    %{uri: uri, apikey: apikey, options: options}
  end

  def get(endpoint) do
    config = get_config(endpoint)
    headers = ["Accept": "Application/json; Charset=utf-8"]
    HTTPoison.get(config[:uri], headers, config[:options]) |> process_response
  end
  
  def post(endpoint, payload) do
    config = get_config(endpoint)
    headers = [{"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}, {"accept", "application/json"}]
    HTTPoison.post!(config[:uri], URI.encode_query(payload), headers, config[:options]) |> process_response
  end
end