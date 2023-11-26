defmodule Core.UserTest do
  use ExUnit.Case

  alias GoEscuelaLms.Core.Schema.User

  describe "users" do
    @valid_attrs %{
      full_name: "Jhon doe",
      email: "jhon.doe@example.com",
      password_hash: "pass123",
      role: "student"
    }
    @invalid_attrs %{}

    test "create/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = User.create(@valid_attrs)
      assert user.full_name == "Jhon doe"
      assert user.email == "jhon.doe@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = User.create(@invalid_attrs)
    end

    test "email must be valid" do
      attrs = %{@valid_attrs | email: "example"}
      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
    end
  end
end
