defmodule Webapp.Factory do
  use ExMachina.Ecto, repo: Webapp.Repo

  @password Argon2.hash_pwd_salt("password")

  def user_factory() do
    %Webapp.Accounts.User{
      email: Faker.Internet.email(),
      name: Faker.Internet.user_name(),
      password_hash: @password,
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      role: "User"
    }
  end

  def team_factory() do
    name = Faker.Team.name()

    %Webapp.Accounts.Team{
      name: name,
      namespace: Faker.Internet.slug([name])
    }
  end

  def team_member_factory(user, team, role \\ "User") do
    %Webapp.Accounts.Member{
      role: role,
      team: team,
      user: user
    }
  end

  def region_factory do
    %Webapp.Regions.Region{
      name: Faker.Address.country()
    }
  end

  def hypervisor_factory do
    %Webapp.Hypervisors.Hypervisor{
      name: Faker.Internet.domain_word(),
      fqdn: Faker.Internet.domain_name(),
      region: build(:region),
      hypervisor_type: get_hypervisor_type(:bhyve)
    }
  end

  def plan_factory do
    %Webapp.Plans.Plan{
      cpu: :rand.uniform(64),
      name: Faker.Superhero.name(),
      ram: (1024 * :math.pow(2, :rand.uniform(16))) |> round(),
      storage: 1024 * :rand.uniform(1024),
      price: :rand.uniform(99)
    }
  end

  def distribution_factory do
    %Webapp.Distributions.Distribution{
      image: Faker.Internet.url(),
      loader: Enum.random(["grub", "bhyveload", "uefi-csm"]),
      name: Faker.App.name(),
      version: Faker.App.semver()
    }
  end

  def machine_factory() do
    %Webapp.Machines.Machine{
      name: Faker.App.name(),
      distribution: build(:distribution),
      hypervisor: build(:hypervisor),
      plan: build(:plan),
      team: build(:team)
    }
  end

  defp get_hypervisor_type(:bhyve) do
    case Webapp.Repo.get_by(Webapp.Hypervisors.Type, name: "bhyve") do
      %Webapp.Hypervisors.Type{} = hypervisor_type -> hypervisor_type
      nil -> Webapp.Repo.insert!(%Webapp.Hypervisors.Type{name: "bhyve"})
    end
  end
end
