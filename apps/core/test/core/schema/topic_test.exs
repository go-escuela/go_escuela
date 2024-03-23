defmodule Core.TopicTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.Topic

  setup do
    course = insert!(:course)
    {:ok, course: course}
  end

  describe "schema" do
    test "metadata", _context do
      assert Topic.__schema__(:source) == "topics"

      assert Topic.__schema__(:fields) == [
               :uuid,
               :name,
               :course_id,
               :inserted_at,
               :updated_at
             ]
    end

    test "associations", _context do
      assert Topic.__schema__(:association, :activities).__struct__ == Ecto.Association.Has
      assert Topic.__schema__(:association, :course).__struct__ == Ecto.Association.BelongsTo
    end
  end

  describe "find/1" do
    test "when exist", %{course: course} do
      topic = insert!(:topic, course_id: course.uuid) |> Repo.preload(:activities)

      assert Topic.find(topic.uuid) == topic
    end

    test "when does not exist", _context do
      assert Topic.find(Faker.UUID.v4()) == nil
    end
  end

  describe "create/1" do
    test "create valid topic", %{course: course} do
      topic =
        build(:topic, course_id: course.uuid) |> Map.from_struct()

      {:ok, topic_created} = Topic.create(topic)

      assert topic_created.name == topic.name
    end

    test "invalid create question", _context do
      {:error, errors} = Topic.create(%{})
      assert errors.valid? == false
    end
  end

  describe "update/1" do
    test "update valid", %{course: course} do
      topic = insert!(:topic, course_id: course.uuid)
      attrs = %{name: Faker.Lorem.word()}

      {:ok, topic_updated} = Topic.update(topic, attrs)

      assert topic_updated.name == attrs.name
    end

    test "invalid create course", %{course: course} do
      topic = insert!(:topic, course_id: course.uuid)

      {:error, errors} = Topic.update(topic, %{name: nil})

      assert errors.valid? == false
    end
  end

  describe "delete/1" do
    test "valid deleted", %{course: course} do
      topic = insert!(:topic, course_id: course.uuid)

      {:ok, _} = Topic.delete(topic)

      assert Topic.find(topic.uuid) == nil
    end
  end
end
