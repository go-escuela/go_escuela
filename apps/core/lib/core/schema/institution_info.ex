defmodule Core.Schema.InstitutionInfo do
  @moduledoc """
  This module represents the institution info schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Core.Repo, as: Repo

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "institution_info" do
    field(:name, :string)

    timestamps()
  end

  def exist? do
    !is_nil(InstitutionInfo.get!())
  end

  def get! do
    InstitutionInfo |> Ecto.Query.first() |> Repo.one()
  end

  def create(attrs \\ %{}) do
    %InstitutionInfo{}
    |> InstitutionInfo.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
