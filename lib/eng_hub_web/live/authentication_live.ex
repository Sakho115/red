defmodule EngHubWeb.AuthenticationLive do
  @moduledoc """
  LiveView for authenticating users via Passwordless Email OTP.
  """
  use EngHubWeb, :live_view
  require Logger

  alias EngHub.Identity

  alias EngHub.Identity.UserToken

  def mount(_params, _session, socket) do
    if socket.assigns[:current_user] do
      {:ok, push_navigate(socket, to: ~p"/", replace: true)}
    else
      {:ok,
       socket
       |> assign(:page_title, "Sign In")
       # :email or :otp
       |> assign(:step, :email)
       |> assign(:email, nil)
       |> assign(:user, nil)
       |> assign(:token_form, nil)}
    end
  end

  def handle_event("validate", %{"email" => email}, socket) do
    {:noreply, assign(socket, :email, email)}
  end

  def handle_event("submit_email", %{"email" => email}, socket) do
    case Identity.create_or_get_user(email) do
      {:ok, user} ->
        case Identity.generate_user_otp(user) do
          {:ok, code} ->
            # Deliver the OTP asynchronously using Oban
            %{to: email, code: code}
            |> EngHub.Workers.EmailWorker.new()
            |> Oban.insert()

            {:noreply,
             socket
             |> assign(:step, :otp)
             |> assign(:email, email)
             |> assign(:user, user)
             |> put_flash(:info, "A 6-digit code has been sent to your email.")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Could not generate OTP. Please try again.")}
        end

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Invalid email format.")}
    end
  end

  def handle_event("submit_magic_link", %{"email" => email}, socket) do
    case Identity.create_or_get_user(email) do
      {:ok, user} ->
        case Identity.generate_user_magic_link(user) do
          {:ok, token} ->
            # Deliver the Magic Link asynchronously using Oban
            %{to: email, token: token}
            |> EngHub.Workers.EmailWorker.new()
            |> Oban.insert()

            {:noreply,
             socket
             |> put_flash(
               :info,
               "A magic link has been sent to your email. You can close this tab."
             )}

          {:error, _} ->
            {:noreply,
             put_flash(socket, :error, "Could not generate Magic Link. Please try again.")}
        end

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Invalid email format.")}
    end
  end

  def handle_event("submit_otp", %{"otp" => otp}, socket) do
    %{user: user} = socket.assigns

    case Identity.verify_user_otp(user, otp) do
      {:ok, user} ->
        case Identity.create_token(%{user_id: user.id, type: :session}) do
          {:ok, %UserToken{value: token_value}} ->
            encoded_token = Base.encode64(token_value, padding: false)
            token_attrs = %{"value" => encoded_token}

            {:noreply, assign(socket, :token_form, to_form(token_attrs, as: "token"))}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to establish a secure session.")}
        end

      {:error, :invalid_or_expired} ->
        {:noreply, put_flash(socket, :error, "Invalid or expired OTP. Please request a new one.")}
    end
  end

  def handle_event("back_to_email", _params, socket) do
    {:noreply,
     socket
     |> assign(:step, :email)
     |> assign(:user, nil)}
  end
end
