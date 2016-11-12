defmodule ThoughtsSpec do
  use ESpec

  describe "thought spec", skip: "found bug where the wrapping thought spec makes other specs non-determinstic" do
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

      allow(Thoughts).
        to accept(:_die,fn(_,_) ->
          IO.puts "exiting"
        end)
    end

    describe "when successfully connected" do
      before do
        parent = self()
        allow(Thoughts.Async).
          to accept(:handler,
          fn(_, _) ->
          messages = [%{"text" => "wow this actually works"},
                      %{"text" => "hi mom!"},
                      %{"text" => "things are looking pretty good right now"}]
          spawn_link(fn() -> messages |> Enum.map(&(send(parent, {:message, &1}))) end)
        end)
      end

      it "should send out tweets it receives" do
        pid = Thoughts.on("nice things")
        expect(Process.alive?(pid)).to eq(true)
        assert_receive({:message, %{"text" => "wow this actually works"}}, 300)
      end
    end

    context "when no successful connection" do
      before do
        allow(Thoughts.Async).
        to accept(:handler,fn(parent,_) ->
          spawn_link(fn()->
                  send(parent, {:kill, "failed to connect"})
                end)
        end)
      end

      it "should not even attempt to start processing" do
        pid = spawn( fn()-> Thoughts.on("nice things") end)
        assert_receive({:logger, "killing process for this reason: failed to connect"}, 300)
      end
    end
  end
end
