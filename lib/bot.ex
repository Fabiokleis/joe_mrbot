defmodule JoeMrbot.Bot do
  use Nostrum.Consumer

  import Nostrum.Struct.Embed

  alias Nostrum.Api

  @git_hub_api_issue_url "https://api.github.com/issues"
  @tel %Nostrum.Struct.Emoji{name: ":telephone_receiver:"}

  def git_hub_api_headers() do
    [
      {~c"Authorization", Application.get_env(:joemrbot, :ghtoken)},
      {~c"Accept", "application/vnd.github+json"},
      {~c"User-Agent", "DiscordBot (https://github.com/fabiokleis/joe-mrbot, 0.1.0)"},
      {~c"X-GitHub-Api-Version", "2022-11-28"}
    ]
  end

  def transform_assignees(assignees) do
    case Enum.map(assignees, fn user -> user["login"] end) do
      [] -> "no one"
      any -> Enum.join(any, ", ")
    end
  end

  def parse_issues(issues) do
    issues
    |> Enum.map(fn issue ->
      %Nostrum.Struct.Embed{}
      |> put_title("#{issue["repository"]["name"]} - Issue ##{issue["number"]}")
      |> put_description("mr. joe bot generated ... #{@tel}")
      |> put_url("#{issue["url"]}")
      |> put_timestamp(DateTime.to_iso8601(DateTime.utc_now()))
      |> put_color(3_447_003)
      |> put_field("Title", issue["title"])
      |> put_field("State", issue["state"])
      |> put_field("Description", issue["body"])
      |> put_field(
        "Assignees",
        transform_assignees(issue["assignees"])
      )
    end)
  end

  def get() do
    :httpc.request(
      :get,
      {@git_hub_api_issue_url, git_hub_api_headers()},
      [],
      []
    )
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!ping" ->
        Api.create_message(
          msg.channel_id,
          "olar I'm mr john bot, an elixir discord application.... #{@tel}"
        )

      "!issue" ->
        case get() do
          {:ok, res} ->
            {status, _res_headers, body} = res
            Logger.info("[joe] #{inspect(status)}")

            issues = parse_issues(:jiffy.decode(body, [:return_maps]))

            Enum.each(issues, fn embed ->
              Logger.info("[joe] #{inspect(embed)}")
              Api.create_message(msg.channel_id, embed: embed)
            end)

          {:error, reason} ->
            Logger.error("[joe] #{inspect(reason)}")
        end

      "📞" ->
        Api.create_message(
          msg.channel_id,
          "Hello, mike ?"
        )

      _ ->
        :ignore
    end
  end
end
