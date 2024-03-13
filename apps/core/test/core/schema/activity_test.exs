defmodule Core.ActivityTest do
  use ExUnit.Case

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
  end
end
