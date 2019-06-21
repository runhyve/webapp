defmodule Webapp.Networks.Ip_pool do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Machines.Machine,
    Networks.Network,
    Networks.Ipv4
  }

  schema "ip_pools" do
    field(:name, :string)
    field(:ip_range, :string, virtual: true)
    field(:list, :string, virtual: true)
    field(:gateway, EctoNetwork.INET)
    field(:netmask, EctoNetwork.INET)

    belongs_to(:network, Network)
    has_many(:ipv4, Ipv4)
    timestamps()
  end

  @doc false
  def changeset(ip_pool, attrs) do
    ip_pool
    |> cast(attrs, [:name, :ip_range, :netmask, :gateway, :network_id, :list])
    |> validate_required([:name, :ip_range, :netmask, :gateway, :network_id, :list])
    |> assoc_constraint(:network)
    |> validate_ipv4_list(:list)
    |> validate_ipv4_range(:ip_range)
    |> validate_ipv4_list_in_range(:ip_range, :list)
    |> change(%{ip_range: nil, list: nil})
  end

  def validate_ipv4_list(%Ecto.Changeset{valid?: true} = changeset, field) do
    list = get_field(changeset, field)
           |> String.split(["\r", "\n", "\r\n"])
           |> Enum.filter(fn ip -> String.length(ip) > 4 end)
           |> Enum.map(fn ip -> String.trim(ip) end)

    list_length = Enum.count(list)

    list = Enum.filter(list, &is_valid_ipv4?/1)

    case list_length == Enum.count(list) do
      true -> change(changeset, %{field => list})
        _ -> add_error(changeset, field, "Please provide valid IP addresses")
    end
  end
  def validate_ipv4_list(%Ecto.Changeset{} = changeset, field), do: changeset

  def validate_ipv4_range(%Ecto.Changeset{valid?: true} = changeset, field) do
    ip_range = get_field(changeset, field)

    case parse_ipv4_range(ip_range) do
      {:ok, cidr_range} -> change(changeset, %{field => cidr_range})
      {:error, _} -> add_error(changeset, field, "Please provide valid IP Range")
    end
  end
  def validate_ipv4_range(%Ecto.Changeset{} = changeset, range_field), do: changeset

  def validate_ipv4_list_in_range(%Ecto.Changeset{valid?: true} = changeset, range_field, list_field) do
    ip_range = get_field(changeset, range_field)
    list = get_field(changeset, list_field)
    list_length = Enum.count(list)

    {start_address, end_address, prefix} = ip_range

    list = Enum.filter(list, fn ip ->
      Iptools.is_between?(ip, "#{:inet.ntoa(start_address)}", "#{:inet.ntoa(end_address)}")
    end)

    case list_length == Enum.count(list) do
      true -> changeset
      _ -> add_error(changeset, list_field, "Provided IP addresses does not match IP Range")
    end
  end
  def validate_ipv4_list_in_range(%Ecto.Changeset{} = changeset, range_field, list_field), do: changeset

  defp parse_ipv4_range(ip_range) do
    try do
      {:ok, InetCidr.parse(ip_range)}
    rescue
      _ ->
        parse_ipv4_string_range(ip_range)
    end
  end

  defp parse_ipv4_string_range(ip_range_string) do
    [ip_range, prefix_length_str] = String.split(ip_range_string, "/", parts: 2)
    {prefix_length,_} = Integer.parse(prefix_length_str)

    [start_address, end_address] = String.split(ip_range, "-", parts: 2)

    case is_valid_ipv4?(end_address) do
      true ->
        {:ok, {InetCidr.parse_address!(start_address), InetCidr.parse_address!(end_address), prefix_length}}
      false ->
        [first, second, third, fourth] = String.split(start_address, ".", parts: 4)

        if (Integer.parse(fourth) < Integer.parse(end_address)) do
          end_address = "#{first}.#{second}.#{third}.#{end_address}"

          {:ok, {InetCidr.parse_address!(start_address), InetCidr.parse_address!(end_address), prefix_length}}
        else
          {:error, "Range is not valid"}
        end
    end
  end

  defp is_valid_ipv4?(end_address) do
    end_address =~ ~r/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
  end
end
