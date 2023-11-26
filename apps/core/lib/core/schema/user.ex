defmodule GoEscuelaLms.Core.Schema.User do
  @moduledoc """
  This module represents the audit schema. Audits are the read models for events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Enrollment}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "users" do
    field(:full_name, :string)
    field(:email, :string)
    field(:birth_date, :date)
    field(:role, :string)
    field(:password_hash, :string)
    has_many(:enrollments, Enrollment, foreign_key: :user_id)

    timestamps()
  end

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :email, :birth_date, :role, :password_hash])
    |> validate_required([:full_name, :password_hash])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password_hash: password_hash}} = changeset
       ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password_hash))
  end

  defp put_password_hash(changeset), do: changeset
end
