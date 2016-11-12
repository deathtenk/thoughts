defmodule ProcessorSpec do
  use ESpec
  describe "processor spec" do
    context "when data's correct" do
      before do
        parent = self()
        pid = spawn(fn -> Thoughts.Message.processor(parent) end)
        tweet_chunks |> Enum.map(&(send(pid, &1)))
      end


      context "when data is broken" do
        let(:tweet_chunks) do
          [{:http, {1234, :stream, ~s|{"text":"this is a twitter message"}\r\n|}}]
        end
        
        it "twitter message processor should process json" do
          assert_receive({:message, %{"text" => "this is a twitter message"}}, 300)
        end
      end

      context "for chunked tweets" do
        let(:tweet_chunks) do
          [{:http, {1234, :stream, ~s|{"text":"this is a chunked |}},
           {:http, {1235, :stream, ~s|twitter message"}\r\n|}}]
        end
        
        it "twitter message processor should process json" do
          assert_receive({:message, %{"text" => "this is a chunked twitter message"} }, 300)
        end
      end

      context "for empty messages" do
        let(:tweet_chunks) do
          [{:http, {1234, :stream, ~s|\r\n|}}]
        end

        it "should not receive anything" do
          refute_receive({:message, %{} }, 300)
        end
      end
    end


    context "when data is broken" do
      let(:processor) do
        fn(process) ->
          spawn(fn -> Thoughts.Message.processor(process) end)
        end
      end

      let(:start_processor) do
        processor.(self())
      end

      let(:send_messages) do
        fn(messages, pid)->
          messages |> Enum.map(&(send(pid, &1)))
        end
      end

      context "for an invalid json object" do
        # todo: put this in the spec_helper
        before do
          parent = self()
          allow(Thoughts).
            to accept(:logger,
            fn(message)->
              case message do
                {:info, text} ->
                send(parent,{:logger, text})
              end
            end)
        end

        let(:tweet_chunks) do
          [{:http, {1234, :stream, ~s|"text":"this message is invalid}\r\n|}}]
        end

        it "should log the error message" do
          pid = start_processor
          send_messages.(tweet_chunks,pid)
          assert_receive({:logger, "parse error due to 'invalid', emptying list"}, 100)
        end

        it "should not raise an error" do
          start_processing = fn() ->
            pid = start_processor
            send_messages.(tweet_chunks,pid)
          end
          expect start_processing |> to_not(raise_exception())
        end


        it "should not receive anything" do
          refute_receive({:message, %{}}, 300)
        end
      end
    end
  end
end
