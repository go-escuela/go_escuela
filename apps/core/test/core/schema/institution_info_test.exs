defmodule Core.InstitutionInfoTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias GoEscuelaLms.Core.Schema.InstitutionInfo

  describe "schema" do
    test "metadata" do
      assert InstitutionInfo.__schema__(:source) == "institution_info"

      assert InstitutionInfo.__schema__(:fields) == [
               :uuid,
               :name,
               :inserted_at,
               :updated_at
             ]
    end
  end

  describe "exists?/1" do
    test "when exist" do
      insert!(:institution_info)

      assert InstitutionInfo.exist?() == true
    end

    test "when does not exist" do
      assert InstitutionInfo.exist?() == false
    end
  end

  describe "get!/1" do
    test "when exist" do
      institution = insert!(:institution_info)

      assert InstitutionInfo.get!() == institution
    end
  end

  describe "create/1" do
    test "valid create" do
      attrs = %{name: Faker.App.name()}
      {:ok, institution_created} = InstitutionInfo.create(attrs)
      assert institution_created.name == attrs.name
    end
  end
end
