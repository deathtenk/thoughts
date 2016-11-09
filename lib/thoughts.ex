defmodule Thoughts do
  
  def on(subject) do
    spawn(fn() -> 
      parent = self
      request = %{method: :post, uri: 'statuses/filter.json', params: [{'track', to_charlist(subject)}]}
      IO.puts "finding thoughts on #{subject}..."
      async_handler = Thoughts.Fetcher.async_handler(parent, request)
      _on(subject, _default_tweet_function, async_handler) 
    end)
  end

  def on(subject, fun) do
    spawn(fn() ->
      parent = self
      request = %{method: :post, uri: 'statuses/filter.json', params: [{'track', to_charlist(subject)}]}
      IO.puts "finding thoughts on #{subject}..."
      async_handler = Thoughts.Fetcher.async_handler(parent, request)
      _on(subject, fun, async_handler)
    end)
  end


  defp _on(subject, fun, async_handler) do
    receive do
      {:message, message} ->
        fun.(message)
    end
    _on(subject, fun, async_handler)
  end


  defp _default_tweet_function do
    fn(tweets) ->
      IO.puts tweets["text"]
      IO.puts "____________"
    end
  end
end
