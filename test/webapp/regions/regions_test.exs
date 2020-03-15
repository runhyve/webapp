defmodule Webapp.RegionsTest do
  use Webapp.DataCase

  alias Webapp.Regions

  describe "regions" do
    alias Webapp.Regions.Region

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_regions/0 returns all regions" do
      region = fixture_region(@valid_attrs)
      assert Regions.list_regions() == [region]
    end

    test "list_usable_regions/0 returns empty when no hypervisors in database" do
      _region = fixture_region(@valid_attrs)
      assert Regions.list_usable_regions() == []
    end

    test "list_usable_regions/0 returns regions with hypervisors" do
      _region_empty = fixture_region(@valid_attrs)
      region_with_hypervisor = fixture_region(%{name: "region with hv"})
      hv_type= fixture_hypervisor_type(%{name: "bhyve"})
      _hypervisor_1 = fixture_hypervisor(%{name: "hv-1", region_id: region_with_hypervisor.id, fqdn: "hv-1", webhook_token: "test", hypervisor_type_id: hv_type.id})
      _hypervisor_2 = fixture_hypervisor(%{name: "hv-2", region_id: region_with_hypervisor.id, fqdn: "hv-2", webhook_token: "test", hypervisor_type_id: hv_type.id})
      assert Regions.list_usable_regions() == [region_with_hypervisor]
    end

    test "list_region_hypervisors/1 returns empty when no hypervisors in database" do
      region = fixture_region(@valid_attrs)
      assert Regions.list_region_hypervisors(region) == []
    end

    test "list_region_hypervisors/1 returns hypervisors associated with region" do
      region_empty = fixture_region(@valid_attrs)
      region_with_hypervisor = fixture_region(%{name: "region with hv"})
      hv_type= fixture_hypervisor_type(%{name: "bhyve"})
      _hypervisor_1 = fixture_hypervisor(%{name: "hv-1", region_id: region_with_hypervisor.id, fqdn: "hv-1", webhook_token: "test", hypervisor_type_id: hv_type.id})
      _hypervisor_2 = fixture_hypervisor(%{name: "hv-2", region_id: region_with_hypervisor.id, fqdn: "hv-2", webhook_token: "test", hypervisor_type_id: hv_type.id})
      assert Regions.list_region_hypervisors(region_with_hypervisor) |> Enum.count == 2
      assert Regions.list_region_hypervisors(region_empty) == [] 
    end

    test "get_region!/1 returns the region with given id" do
      region = fixture_region(@valid_attrs)
      assert Regions.get_region!(region.id) == region
    end

    test "create_region/1 with valid data creates a region" do
      assert {:ok, %Region{} = region} = Regions.create_region(@valid_attrs)
      assert region.name == "some name"
    end

    test "create_region/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_region(@invalid_attrs)
    end

    test "update_region/2 with valid data updates the region" do
      region = fixture_region(@valid_attrs)
      assert {:ok, %Region{} = region} = Regions.update_region(region, @update_attrs)
      assert region.name == "some updated name"
    end

    test "update_region/2 with invalid data returns error changeset" do
      region = fixture_region(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Regions.update_region(region, @invalid_attrs)
      assert region == Regions.get_region!(region.id)
    end

    test "delete_region/1 deletes the region" do
      region = fixture_region(@valid_attrs)
      assert {:ok, %Region{}} = Regions.delete_region(region)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_region!(region.id) end
    end

    test "change_region/1 returns a region changeset" do
      region = fixture_region(@valid_attrs)
      assert %Ecto.Changeset{} = Regions.change_region(region)
    end
  end
end
