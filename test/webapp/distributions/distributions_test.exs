defmodule Webapp.DistributionsTest do
  use Webapp.DataCase

  alias Webapp.Distributions

  describe "distributions" do
    alias Webapp.Distributions.Distribution

    @valid_attrs %{
      name: "FreeBSD",
      version: "12.0",
      loader: "bhyveload",
      image:
        "http://ftp.icm.edu.pl/pub/FreeBSD/releases/VM-IMAGES/12.0-RELEASE/amd64/Latest/FreeBSD-12.0-RELEASE-amd64.raw.xz"
    }
    @update_attrs %{
      name: "Ubuntu",
      version: "18.04",
      loader: "grub",
      image:
        "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64-uefi1.img"
    }
    @archive_attrs %{
      name: "Ubuntu",
      version: "19.04",
      loader: "grub",
      archived_at: DateTime.utc_now() |> DateTime.truncate(:second),
      image:
        "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64-uefi1.img"
    }
    @invalid_attrs %{name: "FreeBSD", version: "", loader: "", image: ""}

    def distribution_fixture(attrs \\ %{}) do
      {:ok, distribution} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Distributions.create_distribution()

      distribution
    end

    test "list_distributions/0 returns all distributions" do
      distribution = distribution_fixture()
      assert Distributions.list_distributions() == [distribution]
    end

    test "get_distribution!/1 returns the distribution with given id" do
      distribution = distribution_fixture()
      assert Distributions.get_distribution!(distribution.id) == distribution
    end

    test "get_img_name/1 returns valid file name" do
      distribution = distribution_fixture()
      assert Distributions.get_img_name(distribution) == "FreeBSD-12.0-RELEASE-amd64.raw"

      assert {:ok, %Distribution{} = distribution} =
               Distributions.update_distribution(distribution, @update_attrs)

      assert Distributions.get_img_name(distribution) ==
               "ubuntu-18.04-server-cloudimg-amd64-uefi1.img"
    end

    test "create_distribution/1 with valid data creates a distribution" do
      assert {:ok, %Distribution{} = distribution} =
               Distributions.create_distribution(@valid_attrs)

      assert distribution.name == "FreeBSD"
      assert distribution.version == "12.0"
      assert distribution.loader == "bhyveload"

      assert distribution.image ==
               "http://ftp.icm.edu.pl/pub/FreeBSD/releases/VM-IMAGES/12.0-RELEASE/amd64/Latest/FreeBSD-12.0-RELEASE-amd64.raw.xz"
    end

    test "create_distribution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Distributions.create_distribution(@invalid_attrs)
    end

    test "update_distribution/2 with valid data updates the distribution" do
      distribution = distribution_fixture()

      assert {:ok, %Distribution{} = distribution} =
               Distributions.update_distribution(distribution, @update_attrs)

      assert distribution.name == "Ubuntu"
      assert distribution.version == "18.04"
      assert distribution.loader == "grub"

      assert distribution.image ==
               "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64-uefi1.img"
    end

    test "list_active_distributions/0 doesn't list archived distributions" do
      distribution = distribution_fixture()

      assert {:ok, %Distribution{} = distribution} =
               Distributions.update_distribution(distribution, @archive_attrs)

      assert Distributions.list_active_distributions() == []
    end

    test "update_distribution/2 with invalid data returns error changeset" do
      distribution = distribution_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Distributions.update_distribution(distribution, @invalid_attrs)

      assert distribution == Distributions.get_distribution!(distribution.id)
    end

    test "delete_distribution/1 deletes the distribution" do
      distribution = distribution_fixture()
      assert {:ok, %Distribution{}} = Distributions.delete_distribution(distribution)
      assert_raise Ecto.NoResultsError, fn -> Distributions.get_distribution!(distribution.id) end
    end

    test "change_distribution/1 returns a distribution changeset" do
      distribution = distribution_fixture()
      assert %Ecto.Changeset{} = Distributions.change_distribution(distribution)
    end
  end
end
