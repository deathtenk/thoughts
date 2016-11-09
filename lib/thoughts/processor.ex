defmodule Thoughts.Processor do
  
  def message_processor(receiver, aggregate_data \\ []) do
    receive do
      {:http, {request_id, :stream, chunk}} ->
        cond do
          _is_empty?(chunk) ->
            message_processor(receiver, aggregate_data)
          _eol?(chunk) ->
            #try do
              {:ok, final} = _join_and_parse(chunk,aggregate_data)
              send(receiver, {:message, final})
              message_processor(receiver, [])
              #catch
                # {:error, {reason,_,_}} = _join_and_parse(chunk,aggregate_data)
                # IO.puts "parsing issue for #{reason}, emptying message box"
                #message_processor(receiver, [])
                #end
          true ->
            message_processor(receiver, [chunk|aggregate_data])
        end

      _ ->
        message_processor(receiver, aggregate_data)
    end
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

  defp _parse_handler
end
