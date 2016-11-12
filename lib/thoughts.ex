defmodule Thoughts do
  require Logger

  # seperating the logger into a function means we don't have to require it in every file
  # and I can easily test output values by stubbing out its functionality in the test
  def logger(message) do
    case message do
      {:info, text} ->
        Logger.info text
      {:puts, text} ->
        IO.puts text
    end
  end
  
  def on(subject) do
    spawn_link(fn() -> 
      parent = self
      request = %{method: :post, uri: 'statuses/filter.json', params: [{'track', to_charlist(subject)}]}
      __MODULE__.logger({:info, "finding thoughts on #{subject}..."})
      async_handler = Thoughts.Async.handler(parent, request)
      _on(subject, _default_tweet_function, async_handler)
    end)
  end

  def on(subject, fun) do
    spawn_link(fn() ->
      parent = self
      request = %{method: :post, uri: 'statuses/filter.json', params: [{'track', to_charlist(subject)}]}
      __MODULE__.logger({:info, "finding thoughts on #{subject}..."})
      async_handler = Thoughts.Async.handler(parent, request)
      _on(subject, fun, async_handler)
    end)
  end


  defp _on(subject, fun, async_handler) do
    receive do
      {:message, message} ->
        fun.(message)
      {:kill, message} ->
        __MODULE__.logger({:info, "killing process for this reason: #{message}"})
        __MODULE__._die(self,message)
    end
    _on(subject, fun, async_handler)
  end

  defp _die(process, message) do
    process |> Process.exit(message)
  end


  defp _default_tweet_function do
    fn(tweets) ->
      __MODULE__.logger({:puts, tweets["text"]})
      __MODULE__.logger({:puts, "____________"})
    end
  end
end
