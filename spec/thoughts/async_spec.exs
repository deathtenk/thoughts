defmodule AsyncSpec do
  use ESpec
  require Logger

  describe "async" do
    let :query, do: %{method: :post, uri: 'example', params: [{'foo', 'bar'}]}
    let :request_id, do: 1
    let :data, do: "some data"
    let :stream_chunk, do: {:http, {'1234', :stream, data}}
    let :process, do: self()

    before do
      parent = self()
      allow(Thoughts).
        to accept(:logger,
        fn(message)->
        case message do
          {:info, text} ->
            send(parent,{:logger, text})
          {:puts, text} ->
            send(parent,{:io,text})
        end
      end)

      allow Thoughts.Message |>
        to(accept :processor, fn(process)->
           receive do
             {:http, {_, :stream, stream_data}} ->
               send(process, {:ok, stream_data})
               Thoughts.Message.processor(process)
           end
           Thoughts.Message.processor(process)
        end)
    end
    
    context "when successful" do
      before do
        allow Thoughts.Twitter |> 
          to(accept :connect, 
            fn(query) -> 
              send(self(), {:http, {'1234', :stream, "some data"}})
              {:ok, 1}
            end)
      end

      it "should receive the stream data" do
        pid = Thoughts.Async.handler(self(), query)
        expect(Process.alive?(pid)).to eq(true)
        assert_receive({:ok, stream_data}, 250)
      end
    end

    context "when an error occurs", focus: true do
      let(:spawn_handler) do
        fn(q) ->
          spawn_link(fn -> 
                       Thoughts.Async.handler(self(), q) 
                     end)
        end
      end

      before do
        allow Thoughts.Twitter |> 
          to(accept :connect, 
            fn(query) -> 
              {:error, "unknown query"}
            end)
      end

      it "connect should be stubbed" do
        expect(Thoughts.Twitter.connect(nil)).to eq({:error, "unknown query"})
      end

      it "should raise an exception" do
        expect(Thoughts.Async.handler(self(), query)) 
        |> to(raise_exception)
      end

      it "should not send any data" do
        spawn_handler.(query)
        assert_receive({:logger, "died because of 'unknown query', sending kill"}, 300)
      end
    end
  end
end
