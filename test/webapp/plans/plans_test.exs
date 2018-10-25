defmodule Webapp.PlansTest do
  use Webapp.DataCase

  alias Webapp.Plans

  describe "plans" do
    alias Webapp.Plans.Plan

    @valid_attrs %{cpu: 42, name: "some name", ram: 42, storage: 42}
    @update_attrs %{cpu: 43, name: "some updated name", ram: 43, storage: 43}
    @invalid_attrs %{cpu: nil, name: nil, ram: nil, storage: nil}

    def plan_fixture(attrs \\ %{}) do
      {:ok, plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Plans.create_plan()

      plan
    end

    test "list_plans/0 returns all plans" do
      plan = plan_fixture()
      assert Plans.list_plans() == [plan]
    end

    test "get_plan!/1 returns the plan with given id" do
      plan = plan_fixture()
      assert Plans.get_plan!(plan.id) == plan
    end

    test "create_plan/1 with valid data creates a plan" do
      assert {:ok, %Plan{} = plan} = Plans.create_plan(@valid_attrs)
      assert plan.cpu == 42
      assert plan.name == "some name"
      assert plan.ram == 42
      assert plan.storage == 42
    end

    test "create_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Plans.create_plan(@invalid_attrs)
    end

    test "update_plan/2 with valid data updates the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{} = plan} = Plans.update_plan(plan, @update_attrs)

      assert plan.cpu == 43
      assert plan.name == "some updated name"
      assert plan.ram == 43
      assert plan.storage == 43
    end

    test "update_plan/2 with invalid data returns error changeset" do
      plan = plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Plans.update_plan(plan, @invalid_attrs)
      assert plan == Plans.get_plan!(plan.id)
    end

    test "delete_plan/1 deletes the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{}} = Plans.delete_plan(plan)
      assert_raise Ecto.NoResultsError, fn -> Plans.get_plan!(plan.id) end
    end

    test "change_plan/1 returns a plan changeset" do
      plan = plan_fixture()
      assert %Ecto.Changeset{} = Plans.change_plan(plan)
    end
  end
end
