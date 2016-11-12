defmodule Thoughts.Message do
  
  def processor(receiver, aggregate_data \\ []) do
    receive do
      {:http, {request_id, :stream, chunk}} ->
        cond do
          _is_empty?(chunk) ->
            processor(receiver, aggregate_data)
          _eol?(chunk) ->
              case _join_and_parse(chunk,aggregate_data) do
                {:ok, final} ->
                  send(receiver, {:message, final})
                  processor(receiver, [])
                {:error, {reason,_,_}} ->
                  Thoughts.logger({:info, "parse error due to '#{reason}', emptying list"})
                  processor(receiver, [])
              end
          true ->
            processor(receiver, [chunk|aggregate_data])
        end
    end
    processor(receiver, aggregate_data)
  end

  @eol "\r\n"
  defp _eol?(chunk), do: chunk |> String.ends_with?(@eol)
  defp _is_empty?(chunk), do: chunk == @eol
  
  defp _join_and_parse(chunk,aggregate_data) do
    [chunk|aggregate_data] |>
      Enum.reverse |>
      Enum.join("") |>
      Poison.Parser.parse
  end
end
