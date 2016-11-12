require IEx

defmodule Thoughts.Twitter do
  @base_url 'https://stream.twitter.com/1.1'
  
  def connect(query) do
    case query do
      %{method: :post, uri: path, params: params} ->
        response = __MODULE__.post('#{@base_url}/#{path}', params, _consumer, _access_token, _access_secret, [{:sync, false}, {:stream, :self}])
        {:ok, response}
      %{method: :get, uri: path, params: params} ->
        response = __MODULE__.get('#{@base_url}/#{path}', params, _consumer, _access_token, _access_secret, [{:sync, false}, {:stream, :self}])
        {:ok, response}
       _ ->
        {:error, "unkown query"}
    end
  end

  def post(url, params, consumer, access_token, access_secret, stream_options) do
    :oauth.post(url, params, consumer, access_token, access_secret, stream_options)
  end

  def get(url, params, consumer, access_token, access_secret, stream_options) do
    :oauth.get(url, params, consumer, access_token, access_secret, stream_options)
  end

  defp _consumer, do: {Application.get_env(:thoughts, :consumer_key), Application.get_env(:thoughts, :consumer_secret), :hmac_sha1}
  defp _access_token, do: Application.get_env(:thoughts, :access_token)
  defp _access_secret, do: Application.get_env(:thoughts, :access_secret)
end
