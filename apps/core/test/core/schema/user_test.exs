defmodule Core.UserTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias Core.Repo
  alias Core.Schema.User

  describe "schema" do
    test "metadata" do
      assert User.__schema__(:source) == "users"

      assert User.__schema__(:fields) == [
               :uuid,
               :full_name,
               :email,
               :birth_date,
               :role,
               :password_hash,
               :inserted_at,
               :updated_at
             ]
    end

    test "associations" do
      assert User.__schema__(:association, :enrollments).__struct__ == Ecto.Association.Has
    end
  end

  describe "find/1" do
    test "when exist" do
      user = insert!(:user) |> Repo.preload(:enrollments)

      assert User.find(user.uuid) == user
    end

    test "when does not exist" do
      assert User.find(Faker.UUID.v4()) == nil
    end
  end

  describe("all/1") do
    test "should return all users" do
      Enum.each(0..3, fn _ ->
        insert!(:user)
      end)

      assert User.all() |> Enum.count() == 4
    end
  end

  describe "create/1" do
    test "create valid user" do
      user =
        build(:user) |> Map.from_struct()

      {:ok, user_created} = User.create(user)

      assert user_created.full_name == user.full_name
      assert user_created.email == user.email
      assert user_created.role == user.role
    end

    test "invalid create question" do
      {:error, errors} = User.create(%{})
      assert errors.valid? == false
    end
  end

  describe "update/1" do
    test "update valid" do
      user = insert!(:user)
      attrs = %{full_name: Faker.Person.name()}

      {:ok, user_updated} = User.update(user, attrs)

      assert user_updated.full_name == attrs.full_name
    end

    test "invalid create course" do
      user = insert!(:user)

      {:error, errors} = User.update(user, %{full_name: nil})

      assert errors.valid? == false
    end
  end

  describe "get_account_by_email/1" do
    test "find account" do
      user = insert!(:user)
      assert User.get_account_by_email(user.email) == {:ok, user}
    end

    test "does not exist" do
      assert User.get_account_by_email(Faker.Internet.email()) == {:error, :not_found}
      assert User.get_account_by_email(Faker.Lorem.word()) == {:error, :not_found}
    end
  end

  describe "student?/1" do
    test "return true" do
      user = insert!(:user, role: :student)

      assert user |> User.student?() == true
    end
  end

  describe "organizer?/1" do
    test "return true" do
      user = insert!(:user, role: :organizer)

      assert user |> User.organizer?() == true
    end
  end

  describe "instructor?/1" do
    test "return true" do
      user = insert!(:user, role: :instructor)

      assert user |> User.instructor?() == true
    end
  end

  describe "roles/0" do
    test "return all roles" do
      assert User.roles() == ~w(student instructor organizer)
    end
  end
end
