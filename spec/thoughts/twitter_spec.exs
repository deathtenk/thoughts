defmodule TwitterSpec do
  use ESpec
  describe "twitter spec" do
    let(:consumer, do: {Application.get_env(:thoughts, :consumer_key), Application.get_env(:thoughts, :consumer_secret), :hmac_sha1})
    let :access_token, do: Application.get_env(:thoughts, :access_token)
    let :access_secret, do: Application.get_env(:thoughts, :access_secret)  
    let :base_url, do: 'https://stream.twitter.com/1.1'
    let :params, do: [{'foo', 'bar'}]
    let :path, do: 'example'
    let :complete_url, do: '#{base_url}/#{path}'
    let :response, do: 'success'
    let :get_data, do: {:http, {'1234', :stream, 'get data'}}
    let :post_data, do: {:http, {'1234', :stream, 'post data'}}
    let :query, do: %{method: :post, uri: path, params: params}
    let :stream_options, do: [{:sync, false}, {:stream, :self}]

    before do
      parent = self()
      allow Thoughts.Twitter |> 
        to(accept :post, 
           fn(complete_url, params, consumer, access_token, access_secret, stream_options) -> 
             send(parent, post_data) 
             'success'
           end)

      allow Thoughts.Twitter |> 
        to(accept :get, 
           fn(complete_url, params, consumer, access_token, access_secret, stream_options) -> 
             send(parent, get_data) 
             'success'
           end)
    end

    context "for a post method" do
      let :query, do: %{method: :post, uri: path, params: params}

      it "should return :ok with a response" do
        expect(Thoughts.Twitter.connect(query)).to eq({:ok, response})
        assert_received post_data
      end
    end

    context "for a get method" do
      let :query, do: %{method: :get, uri: path, params: params}

      it "should return :ok with a response" do
        expect(Thoughts.Twitter.connect(query)).to eq({:ok, response})
        assert_received get_data
      end
    end

    context "for a bad query" do
      let :bad_query, do: %{}
      
      it "should return an :error" do
        expect(Thoughts.Twitter.connect(bad_query)).to eq({:error, "unkown query"})
      end
    end
  end
end
