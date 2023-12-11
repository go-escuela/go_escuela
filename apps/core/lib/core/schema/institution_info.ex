defmodule GoEscuelaLms.Core.Schema.InstitutionInfo do
  @moduledoc """
  This module represents the audit schema. Audits are the read models for events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "institution_info" do
    field(:name, :string)

    timestamps()
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
