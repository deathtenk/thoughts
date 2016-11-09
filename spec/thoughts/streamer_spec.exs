defmodule ProcessorSpec do
  use ESpec

  before do
    parent = self()
    pid = spawn(fn -> Thoughts.Processor.message_processor(parent) end)
    tweet_chunks |> Enum.map(&(send(pid, &1)))
  end


  context "for a complete tweet" do
    let(:tweet_chunks) do
      [{:http, {1234, :stream, ~s|{"text":"this is a twitter message"}\r\n|}}]
    end
    
    it "twitter message processor should process json" do
      assert_receive({:message, %{text: "this is a twitter message"}}, 300)
    end
  end

  context "for chunked tweets" do
    let(:tweet_chunks) do
      [{:http, {1234, :stream, ~s|{"text":"this is a chunked |}},
       {:http, {1235, :stream, ~s|twitter message"}\r\n|}}]
    end
    
    it "twitter message processor should process json" do
      assert_receive({:message, %{text: "this is a chunked twitter message"} }, 300)
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
