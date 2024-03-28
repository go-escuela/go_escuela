defmodule Web.ErrorJSONTest do
  use Web.ConnCase, async: true

  test "renders 404" do
    assert Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end

  test "renders 401" do
    assert Web.ErrorJSON.render("401.json", %{}) ==
             %{errors: %{detail: "invalid credentials"}}
  end

  test "renders 403" do
    assert Web.ErrorJSON.render("403.json", %{}) ==
             %{errors: %{detail: "Forbidden resource"}}
  end

  test "renders 422" do
    assert Web.ErrorJSON.render("422.json", %{})
  end
end
