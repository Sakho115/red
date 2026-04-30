defmodule EngHub.Notifications.EmailNotification do
  @moduledoc """
  Defines email templates for notifications.
  """
  import Swoosh.Email

  def delivery(user, subject, body) do
    new()
    |> to({user.username || user.email, user.email})
    |> from({"EngHub", "no-reply@enghub.io"})
    |> subject(subject)
    |> html_body("<div><h1>EngHub Notification</h1><p>#{body}</p></div>")
    |> text_body("EngHub Notification: #{body}")
  end
end
