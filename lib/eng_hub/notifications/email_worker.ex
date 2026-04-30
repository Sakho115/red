defmodule EngHub.Notifications.EmailWorker do
  @moduledoc """
  An Oban worker for sending email notifications asynchronously.
  """
  use Oban.Worker, queue: :mailers, max_attempts: 3
  alias EngHub.Identity
  alias EngHub.Mailer
  alias EngHub.Notifications.EmailNotification

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id, "subject" => subject, "body" => body}}) do
    case Identity.get(user_id) do
      {:ok, user} ->
        EmailNotification.delivery(user, subject, body)
        |> Mailer.deliver()

        :ok

      _ ->
        {:error, :user_not_found}
    end
  end
end
