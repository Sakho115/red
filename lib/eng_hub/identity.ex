defmodule EngHub.Identity do
  @moduledoc """
  Functions for managing users.
  """
  alias Ecto.Changeset
  alias EngHub.Repo
  alias EngHub.Identity.User
  alias EngHub.Identity.UserToken
  import Ecto.Query

  @token_expiration {24, :hour}

  @doc """
  Returns all `User` records with optional preloads.
  """
  @spec list(preloads :: list()) :: [User.t()]
  def list(preloads \\ []) when is_list(preloads) do
    User
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Inserts a new `User` into the repo.
  """
  @spec create(attrs :: map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves a `User` from the repo.
  """
  @spec get(id :: binary(), preloads :: list()) :: {:ok, User.t()} | {:error, :not_found}
  def get(id, preloads \\ []) do
    result =
      User
      |> Repo.get(id)
      |> Repo.preload(preloads)

    case result do
      %User{} ->
        {:ok, result}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Retrieves a `User` by their username.
  Raises if not found.
  """
  def get_user_by_username!(username, preloads \\ []) do
    User
    |> Repo.get_by!(username: username)
    |> Repo.preload(preloads)
  end

  defp get_expiration_timestamp({expiration, unit} \\ @token_expiration) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-expiration, unit)
  end

  @doc """
  Retrieves a `User` by querying a valid token.
  """
  @spec get_by_token(raw_value :: binary(), type :: atom()) ::
          {:ok, User.t()} | {:error, :not_found}
  def get_by_token(raw_value, type \\ :session) when is_binary(raw_value) do
    expiration_timestamp = get_expiration_timestamp()

    query =
      from(user in User,
        join: token in assoc(user, :tokens),
        where:
          token.value == ^raw_value and
            token.type == ^type and
            token.inserted_at > ^expiration_timestamp,
        order_by: [desc: token.inserted_at],
        limit: 1
      )

    case Repo.one(query) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Deletes a single `UserToken`.
  """
  @spec delete_token(token :: UserToken.t()) :: {:ok, UserToken.t()} | {:error, Changeset.t()}
  def delete_token(%UserToken{} = token) do
    Repo.delete(token)
  end

  @doc """
  Deletes all `UserToken`s which have expired.
  """
  @spec delete_all_expired_tokens :: {non_neg_integer(), term()}
  def delete_all_expired_tokens do
    expiration_timestamp = get_expiration_timestamp()

    UserToken
    |> where([t], t.inserted_at <= ^expiration_timestamp)
    |> Repo.delete_all()
  end

  @doc """
  Retrieves a `User` by querying an associated `:key_id`.
  """
  @spec get_by_key_id(key_id :: binary()) :: {:ok, User.t()} | {:error, :not_found}
  def get_by_key_id(key_id) when is_binary(key_id) do
    query =
      from(user in User,
        join: key in assoc(user, :keys),
        preload: [:keys],
        where: key.key_id == ^key_id
      )

    case Repo.one(query) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Modifies an existing `User` in the repo.
  """
  @spec update(user :: User.t(), attrs :: map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Removes an existing `User` from the repo.
  """
  @spec delete(user :: User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def delete(%User{} = user) do
    Repo.delete(user)
  end

  # USER TOKENS

  @doc """
  Inserts a new `UserToken` into the repo.
  """
  @spec create_token(attrs :: map()) :: {:ok, UserToken.t()} | {:error, Changeset.t()}
  def create_token(attrs) do
    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes all session tokens belonging to a user.
  """
  def delete_all_user_sessions(user_id) do
    from(token in UserToken, where: token.user_id == ^user_id and token.type == :session)
    |> Repo.delete_all()
  end

  # ============================
  # PASSWORDLESS / OTP FLOW
  # ============================

  @doc """
  Finds a user by email, or creates one if it doesn't exist.
  """
  def create_or_get_user(email) when is_binary(email) do
    email = String.downcase(email)

    case Repo.get_by(User, email: email) do
      %User{} = user ->
        {:ok, user}

      nil ->
        [username_base | _] = String.split(email, "@")
        create(%{email: email, username: "#{username_base}_#{:rand.uniform(9999)}"})
    end
  end

  @doc """
  Generates a 6-digit OTP for the given user, stores its hash,
  and returns the raw 6-digit code to be emailed.
  """
  def generate_user_otp(%User{} = user) do
    # Generate 6 digit random number (as string)
    code = Integer.to_string(Enum.random(100_000..999_999))
    hashed_code = :crypto.hash(:sha256, code)

    token_attrs = %{
      type: :otp,
      value: hashed_code,
      user_id: user.id
    }

    case create_token(token_attrs) do
      {:ok, _token} -> {:ok, code}
      error -> error
    end
  end

  @doc """
  Verifies a 6-digit OTP provided by the user (valid for 5 minutes).
  """
  def verify_user_otp(%User{} = user, code) when is_binary(code) do
    hashed_code = :crypto.hash(:sha256, code)
    expiration_timestamp = get_expiration_timestamp({5, :minute})

    query =
      from(token in UserToken,
        where:
          token.user_id == ^user.id and
            token.type == :otp and
            token.value == ^hashed_code and
            token.inserted_at > ^expiration_timestamp,
        order_by: [desc: token.inserted_at],
        limit: 1
      )

    case Repo.one(query) do
      %UserToken{} = token ->
        # Optional: delete the token once it's used so it can't be reused
        Repo.delete(token)
        {:ok, user}

      nil ->
        {:error, :invalid_or_expired}
    end
  end

  @doc """
  Generates a magic link token. Since the changeset automatically populates
  the `value` for magic link tokens, we just grab it.
  """
  def generate_user_magic_link(%User{} = user) do
    token_attrs = %{
      type: :magic_link_token,
      user_id: user.id
    }

    case create_token(token_attrs) do
      {:ok, token} -> {:ok, Base.encode64(token.value, padding: false)}
      error -> error
    end
  end

  @doc """
  Verifies a magic link token (valid for 15 minutes).
  """
  def verify_user_magic_link(encoded_token) when is_binary(encoded_token) do
    expiration_timestamp = get_expiration_timestamp({15, :minute})

    case Base.decode64(encoded_token, padding: false) do
      {:ok, decoded_value} ->
        query =
          from(user in User,
            join: token in assoc(user, :tokens),
            where:
              token.type == :magic_link_token and
                token.value == ^decoded_value and
                token.inserted_at > ^expiration_timestamp,
            order_by: [desc: token.inserted_at],
            limit: 1
          )

        case Repo.one(query) do
          %User{} = user ->
            {:ok, user}

          nil ->
            {:error, :invalid_or_expired}
        end

      _ ->
        {:error, :invalid_token_format}
    end
  end
end
