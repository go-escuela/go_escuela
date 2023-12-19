defmodule GoEscuelaLms.Core.Schema.User do
  @moduledoc """
  This module represents  User schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, warn: false
  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Enrollment}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field(:full_name, :string)
    field(:email, :string)
    field(:birth_date, :date)
    field(:role, Ecto.Enum, values: [:organizer, :instructor, :student])
    field(:password_hash, :string)
    has_many(:enrollments, Enrollment, foreign_key: :user_id, on_delete: :delete_all)

    timestamps()
  end

  def all, do: Repo.all(User)

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(%User{} = user) do
    user |> Repo.delete()
  end

  def find(uuid) when uuid in ["", nil], do: nil

  def find(uuid) do
    Repo.get(User, uuid)
  end

  def get_account_by_email(email) do
    from(u in User,
      where: u.email == ^email,
      select: u
    )
    |> first()
    |> one_or_not_found
  end

  def student?(user) do
    user.role == :student
  end

  def organizer?(user) do
    user.role == :organizer
  end

  def instructor?(user) do
    user.role == :instructor
  end

  def roles, do: ~w(student instructor organizer)

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :email, :birth_date, :role, :password_hash])
    |> validate_required([:full_name, :email, :role, :password_hash])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password_hash: password_hash}} = changeset
       ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password_hash))
  end

  defp put_password_hash(changeset), do: changeset

  defp one_or_not_found(query) do
    query
    |> Repo.one()
    |> case do
      %{} = ret ->
        {:ok, ret}

      nil ->
        {:error, :not_found}
    end
  end
end
