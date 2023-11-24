defmodule GoEscuelaLms.Core.Schema.Course do
  @moduledoc """
  This module represents the audit schema. Audits are the read models for events.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "courses" do
    field :name, :string
    field :description, :string
    field :enabled, :boolean, default: false

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
