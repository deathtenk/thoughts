defmodule Thoughts.Async do
  def handler(receiver, query) do
    spawn_link(fn ->
      case Thoughts.Twitter.connect(query) do
        {:ok, _} ->
          Thoughts.Message.processor(receiver)
        {:error, message} ->
          Thoughts.logger({:info, "died because of '#{message}', sending kill"})
          send(self, {:kill, message})
      end
    end)
  end
end
