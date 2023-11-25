defmodule GoEscuelaLms.Core.Schema.Course do
  @moduledoc """
  This module represents the audit schema. Audits are the read models for events.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "users" do
    field :full_name, :string
    field :email, :string
    field :birth_date, :date
    field :role, :string

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:full_name, :email, :birth_date, :role])
    |> validate_required([:full_name])
  end
end
