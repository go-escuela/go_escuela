defmodule Core.ActivityTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory
  import Mock

  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.Activity
  alias GoEscuelaLms.Core.GCP.Manager, as: GCPManager

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

  describe "all/0" do
    test "should return all activities" do
      topic = insert!(:topic)
      Enum.each(0..3, fn _ -> insert!(:activity, topic_id: topic.uuid) end)

      assert Activity.all() |> Enum.count() == 4
    end
  end

  describe "find/1" do
    test "when exist" do
      topic = insert!(:topic)
      activity = insert!(:activity, topic_id: topic.uuid) |> Repo.preload(questions: :answers)

      assert Activity.find(activity.uuid) == activity
    end

    test "when does not exist" do
      assert Activity.find("28a11d64-5fd9-4028-8707-aeac06c7d10e") == nil
    end

    test "with invalid uuid" do
      assert Activity.find("xxxx") == nil
      assert Activity.find(nil) == nil
    end
  end

  describe "create_with_resource/1" do
    test "create valid activity" do
      topic = insert!(:topic)

      activity =
        build(:activity, activity_type: :resource, topic_id: topic.uuid) |> Map.from_struct()

      with_mocks [
        {GCPManager, [:passthrough], upload: fn _, _ -> {:ok, "resource"} end}
      ] do
        {:ok, resource_activity} = Activity.create_with_resource(activity)

        assert resource_activity.activity_type == activity.activity_type
        assert resource_activity.enabled == activity.enabled
        assert resource_activity.end_date == activity.end_date
        assert resource_activity.feedback == activity.feedback
        assert resource_activity.grade_pass == activity.grade_pass
        assert resource_activity.max_attempts == activity.max_attempts
        assert resource_activity.name == activity.name
        assert resource_activity.start_date == activity.start_date
        assert resource_activity.topic_id == activity.topic_id
      end
    end

    # test "invalid create activity" do
    #   with_mocks [
    #     {GCPManager, [:passthrough], upload: fn _, _ -> {:error, "resource"} end}
    #   ] do
    #     activity = build(:activity, activity_type: :resource)

    #     assert Activity.create_with_resource(activity) == activity
    #   end
    # end
  end
end
