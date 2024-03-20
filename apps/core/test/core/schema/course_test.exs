defmodule Core.CourseTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.Course

  describe "schema" do
    test "metadata" do
      assert Course.__schema__(:source) == "courses"

      assert Course.__schema__(:fields) == [
               :uuid,
               :name,
               :description,
               :enabled,
               :inserted_at,
               :updated_at
             ]
    end

    test "types metadata" do
      assert Course.__schema__(:type, :uuid) == Ecto.UUID
      assert Course.__schema__(:type, :name) == :string
      assert Course.__schema__(:type, :description) == :string
    end

    test "associations", _context do
      assert Course.__schema__(:association, :enrollments).__struct__ == Ecto.Association.Has
      assert Course.__schema__(:association, :topics).__struct__ == Ecto.Association.Has
    end
  end

  describe "all/0" do
    test "should return all courses" do
      Enum.each(0..3, fn _ -> insert!(:course) end)

      assert Course.all() |> Enum.count() == 4
    end
  end

  describe("all/1") do
    test "should return all courses enrollment to user" do
      user = insert!(:user)
      course = insert!(:course)
      insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      assert Course.all(user.uuid) == [course]
    end
  end

  describe "find/1" do
    test "when exist" do
      course = insert!(:course) |> Repo.preload(:topics) |> Repo.preload(:enrollments)

      assert Course.find(course.uuid) == course
    end

    test "when does not exist", _context do
      assert Course.find(Faker.UUID.v4()) == nil
    end

    test "with invalid uuid" do
      assert Course.find("xxxx") == nil
      assert Course.find(nil) == nil
    end
  end

  describe "create/1" do
    test "create valid course" do
      course =
        build(:course) |> Map.from_struct()

      {:ok, course_created} = Course.create(course)

      assert course_created.name == course.name
      assert course_created.description == course.description
      assert course_created.enabled == course.enabled
    end

    test "invalid create course" do
      {:error, errors} = Course.create(%{})

      assert errors.valid? == false
    end
  end

  describe "update/1" do
    test "update valid course" do
      course = insert!(:course)
      attrs = %{name: Faker.Lorem.word(), enabled: true, description: Faker.Lorem.sentence()}

      {:ok, course_updated} = Course.update(course, attrs)

      assert course_updated.name == attrs.name
      assert course_updated.description == attrs.description
      assert course_updated.enabled == attrs.enabled
    end

    test "invalid create course" do
      course = insert!(:course)

      {:error, errors} = Course.update(course, %{name: nil})

      assert errors.valid? == false
    end
  end
end
