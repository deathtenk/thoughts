defmodule Thoughts.Fetcher do
  @base_url 'https://stream.twitter.com/1.1'

  def open_connection(query) do
    case query do
      %{method: :post, uri: path, params: params} ->
         response = :oauth.post('#{@base_url}/#{path}', params, _consumer, _access_token, _access_secret, [{:sync, false}, {:stream, :self}])
         {:ok, response}
       %{method: :get, uri: path, params: params} ->
         response = :oauth.get('#{@base_url}/#{path}', params, _consumer, _access_token, _access_secret, [{:sync, false}, {:stream, :self}])
         {:ok, response}
       _ ->
         {:error}
    end
  end


  def async_handler(receiver, query) do
    spawn(fn -> response = open_connection(query)
      case response do
        {:ok, request_id} ->
          Thoughts.Processor.message_processor(receiver)
        {:error} ->
          IO.puts "oh fuck"
        end
    end)
  end

  defp _consumer, do: {Application.get_env(:thoughts, :consumer_key), Application.get_env(:thoughts, :consumer_secret), :hmac_sha1}
  defp _access_token, do: Application.get_env(:thoughts, :access_token)
  defp _access_secret, do: Application.get_env(:thoughts, :access_secret)
end
