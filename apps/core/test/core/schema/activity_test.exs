defmodule Core.ActivityTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias GoEscuelaLms.Core.Schema.Activity

  describe "schema" do
    test "metadata" do
      assert Activity.__schema__(:source) == "activities"

      assert Activity.__schema__(:fields) == [
               :uuid,
               :name,
               :enabled,
               :feedback,
               :start_date,
               :end_date,
               :max_attempts,
               :grade_pass,
               :activity_type,
               :topic_id,
               :inserted_at,
               :updated_at
             ]
    end

    test "types metadata" do
      assert Activity.__schema__(:type, :uuid) == Ecto.UUID
      assert Activity.__schema__(:type, :name) == :string
      assert Activity.__schema__(:type, :enabled) == :boolean
      assert Activity.__schema__(:type, :feedback) == :string
      assert Activity.__schema__(:type, :start_date) == :utc_datetime
      assert Activity.__schema__(:type, :end_date) == :utc_datetime
      assert Activity.__schema__(:type, :max_attempts) == :integer
    end

    test "associations" do
      assert Activity.__schema__(:association, :topic).__struct__ == Ecto.Association.BelongsTo
      assert Activity.__schema__(:association, :questions).__struct__ == Ecto.Association.Has
    end
  end

  describe " all/0" do
    test "should return all activities" do
      Enum.each(0..3, fn _ -> insert!(:activity) end)

      assert Activity.all() |> Enum.count() == 4
    end
  end
end
