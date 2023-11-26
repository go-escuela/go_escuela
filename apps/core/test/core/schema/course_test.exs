defmodule Core.CourseTest do
  use ExUnit.Case
  use Core.DataCase

  alias GoEscuelaLms.Core.Schema.Course

  describe "courses" do
    @valid_attrs %{name: "Course I", description: "lorem ipsum", enabled: true}
    @invalid_attrs %{name: nil, description: nil}

    test "create_course/1 with valid data creates a user" do
      assert {:ok, %Course{} = course} = Course.create(@valid_attrs)
      assert course.name == "Course I"
      assert course.description == "lorem ipsum"
      assert course.enabled == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Course.create(@invalid_attrs)
    end
  end
end
