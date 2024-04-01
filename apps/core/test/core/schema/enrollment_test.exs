defmodule Core.EnrollmentTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias Core.Repo
  alias Core.Schema.Enrollment

  describe "schema" do
    test "metadata" do
      assert Enrollment.__schema__(:source) == "enrollments"

      assert Enrollment.__schema__(:fields) == [
               :uuid,
               :course_id,
               :user_id,
               :inserted_at,
               :updated_at
             ]
    end

    test "associations", _context do
      assert Enrollment.__schema__(:association, :course).__struct__ == Ecto.Association.BelongsTo
      assert Enrollment.__schema__(:association, :user).__struct__ == Ecto.Association.BelongsTo
    end
  end

  describe("all/1") do
    test "should return all enrollments" do
      Enum.each(0..3, fn _ ->
        user = insert!(:user)
        course = insert!(:course)
        insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)
      end)

      assert Enrollment.all() |> Enum.count() == 4
    end
  end

  describe "find/1" do
    test "when exist" do
      user = insert!(:user)
      course = insert!(:course)

      enrollment =
        insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)
        |> Repo.preload(:course)
        |> Repo.preload(:user)

      assert Enrollment.find(enrollment.uuid) == enrollment
    end

    test "when does not exist", _context do
      assert Enrollment.find(Faker.UUID.v4()) == nil
    end
  end

  describe "create/1" do
    test "create valid enrollment" do
      user = insert!(:user)
      course = insert!(:course)

      {:ok, enrollment} = Enrollment.create(%{course_id: course.uuid, user_id: user.uuid})

      assert enrollment.course_id == course.uuid
      assert enrollment.user_id == user.uuid
    end

    test "invalid" do
      {:error, errors} = Enrollment.create(%{})

      assert errors.valid? == false
    end
  end

  describe "delete/1" do
    test "valid deleted" do
      user = insert!(:user)
      course = insert!(:course)
      enrollment = insert!(:enrollment, course_id: course.uuid, user_id: user.uuid)

      {:ok, _} = Enrollment.delete(enrollment)

      assert Enrollment.find(enrollment.uuid) == nil
    end
  end
end
