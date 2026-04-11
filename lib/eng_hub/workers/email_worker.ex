defmodule EngHub.Workers.EmailWorker do
  use Oban.Worker, queue: :mailers

  alias Swoosh.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "code" => code}}) do
    Email.new()
    |> Email.to(to)
    |> Email.from({"EngHub", "noreply@enghub.com"})
    |> Email.subject("Your EngHub Authentication Code")
    |> Email.html_body("""
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 8px;">
        <h2 style="color: #1e293b;">Welcome to EngHub</h2>
        <p style="color: #475569;">Your one-time password (OTP) is:</p>
        <div style="background-color: #f1f5f9; padding: 15px; border-radius: 6px; text-align: center; margin: 20px 0;">
          <strong style="font-size: 24px; color: #4f46e5; letter-spacing: 2px;">#{code}</strong>
        </div>
        <p style="color: #64748b; font-size: 14px;">This code will expire in 5 minutes.</p>
      </div>
    """)
    |> Email.text_body("Your EngHub OTP is: #{code}")
    |> EngHub.Mailer.deliver()

    :ok
  end

  def perform(%Oban.Job{args: %{"to" => to, "token" => token}}) do
    url = EngHubWeb.Endpoint.url() <> "/auth/magic/#{token}"

    Email.new()
    |> Email.to(to)
    |> Email.from({"EngHub", "noreply@enghub.com"})
    |> Email.subject("Sign in to EngHub")
    |> Email.html_body("""
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 8px;">
        <h2 style="color: #1e293b;">Welcome to EngHub</h2>
        <p style="color: #475569;">Click the button below to sign in to your account:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="#{url}" style="background-color: #4f46e5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;">Sign in to EngHub</a>
        </div>
        <p style="color: #64748b; font-size: 14px;">If the button doesn't work, copy and paste this link into your browser:</p>
        <p style="color: #64748b; font-size: 12px; word-break: break-all;">#{url}</p>
        <p style="color: #64748b; font-size: 14px; margin-top: 20px;">This link will expire in 15 minutes.</p>
      </div>
    """)
    |> Email.text_body("Sign in to EngHub: #{url}")
    |> EngHub.Mailer.deliver()

    :ok
  end
end
