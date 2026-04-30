defmodule EngHub.Integrations.GitHub do
  @moduledoc """
  Provides integration with the GitHub API via `Req`.
  Used for fetching repository commits and metadata for Project Spaces.
  """

  @base_url "https://api.github.com"

  @doc """
  Returns a configured Req.Request struct with base headers.
  If an access token is provided, it sets the Authorization header.
  """
  def client(access_token \\ nil) do
    req = 
      Req.new(base_url: @base_url)
      |> Req.Request.put_header("Accept", "application/vnd.github.v3+json")
      |> Req.Request.put_header("X-GitHub-Api-Version", "2022-11-28")

    if access_token do
      Req.Request.put_header(req, "Authorization", "Bearer #{access_token}")
    else
      req
    end
  end

  @doc """
  Fetches the latest commits for a given repository.
  `repo` should be in the format "owner/repo"
  """
  def list_commits(repo, access_token \\ nil) do
    client(access_token)
    |> Req.get(url: "/repos/#{repo}/commits", params: [per_page: 5])
    |> case do
      {:ok, %{status: 200, body: commits}} when is_list(commits) ->
        {:ok, commits}
      
      {:ok, %{status: status, body: body}} ->
        {:error, "GitHub API error: status #{status}, body: #{inspect(body)}"}
      
      {:error, exception} ->
        {:error, "Request failed: #{inspect(exception)}"}
    end
  end
end
