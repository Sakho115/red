defmodule EngHub.Identity.UserToken do
  @moduledoc """
  Schema representing a token generated for a `User`.

  ## Considerations

  - NaiveDateTime is used by default, and this may result in token validation errors in systems distributed across multiple regions.
  - Email confirmation, invite codes, and other tokens may be implemented by updating the `:type` values and writing additional code in the `Identity` context.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias EngHub.Identity.User

  @type t :: %__MODULE__{
          id: binary(),
          type: atom(),
          value: binary(),
          user_id: binary(),
          inserted_at: NaiveDateTime.t()
        }

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "user_tokens" do
    field :type, Ecto.Enum, values: [:session, :otp, :magic_link_token], default: :session
    field :value, :binary
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(%__MODULE__{} = user_token, attrs) do
    fields = __MODULE__.__schema__(:fields)

    user_token
    |> cast(attrs, fields)
    |> validate_required([:type])
    |> put_default_value()
    |> validate_required([:value])
    |> foreign_key_constraint(:user_id)
  end

  defp put_default_value(changeset) do
    case get_change(changeset, :type) || changeset.data.type do
      type when type in [:session, :magic_link_token] ->
        if get_change(changeset, :value) do
          changeset
        else
          put_change(changeset, :value, :crypto.strong_rand_bytes(64))
        end

      :otp ->
        changeset

      _ ->
        changeset
    end
  end
end
