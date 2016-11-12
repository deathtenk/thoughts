# Thoughts

Thoughts is an elixir based twitter streaming client I built to teach myself how to write elixir.
I called it thoughts because I like to think about twitter as an API to the human mind.

## Installation (Not available yet)

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `thoughts` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:thoughts, "~> 0.1.0"}]
    end
    ```

  2. Ensure `thoughts` is started before your application:

    ```elixir
    def application do
      [applications: [:thoughts]]
    end
    ```

## Environment Variables Needed

  1. TWITTER_CONSUMER_KEY
  2. TWITTER_CONSUMER_SECRET
  3. TWITTER_ACCESS_TOKEN
  4. TWITTER_ACCESS_SECRET  

## Usage

  1. first clone the repo:
  
    `$ git clone https://github.com/deathtenk/thoughts`

  2. then from within the thoughts directory run:
  
    `$ iex -S mix`

  3. from within iex run the following
  
    ```
       iex(1)> Thoughts.on("Hockey")

        22:59:13.511 [info]  finding thoughts on Hockey...
        #PID<0.142.0>
        RT @GoldenBlogs: Golden Medals: Post @alexmorgan13 pep talk, @CalWomensSoccer opens NCAA tourney Sat #GoBears
        ____________
        RT @BarSouthNCelly: Dear, Mitch Marner:

        Can you please prance like this for every celly you ever do?

        Sincerely Hockey Fans 🐴🚨 https://t.c…
        ____________
        Beaver men's hockey beats Mankato in OT. Go Bemidji Beavers!
        ____________
        Jake Muzzin: Blocks five shots against Ottawa
        ____________ 
    ```
