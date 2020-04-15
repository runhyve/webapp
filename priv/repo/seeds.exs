# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Webapp.Repo.insert!(%Webapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
accounts = [
  %{
    user_email: "admin@runateam.com",
    user_name: "Runhyve Admin",
    user_password: "aeja9aif9oNg",
    team_name: "Runateam",
    team_namespace: "runateam",
    role: "Administrator"
  },
  %{
    user_email: "user@runateam.com",
    user_name: "Runhyve user",
    user_password: "aeja9aif9oNg",
    team_name: "Runhyve",
    team_namespace: "runhyve",
    role: "User"
  }
]

for account <- accounts do
  {:ok, %{user: user}} = Webapp.Accounts.register_user(account)
  Webapp.Accounts.confirm_user(user)
  Webapp.Accounts.update_user(user, %{role: account.role})
end

Webapp.Repo.insert!(%Webapp.Hypervisors.Type{name: "bhyve"})

# Test dummy data
Webapp.Repo.insert!(%Webapp.Plans.Plan{
  name: "1C-512MB-30HDD",
  ram: 512,
  storage: 30,
  cpu: 1,
  price: 10
})

Webapp.Repo.insert!(%Webapp.Plans.Plan{
  name: "1C-1024MB-50HDD",
  ram: 1024,
  storage: 50,
  cpu: 1,
  price: 20
})

Webapp.Repo.insert!(%Webapp.Plans.Plan{
  name: "2C-2048MB-100HDD",
  ram: 2048,
  storage: 100,
  cpu: 2,
  price: 30
})

Webapp.Repo.insert!(%Webapp.Distributions.Distribution{
  name: "Ubuntu",
  version: "18.04",
  loader: "grub",
  image: "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
})

Webapp.Repo.insert!(%Webapp.Distributions.Distribution{
  name: "FreeBSD",
  version: "12.1",
  loader: "bhyveload",
  image:
    "http://ftp.icm.edu.pl/pub/FreeBSD/releases/VM-IMAGES/12.1-RELEASE/amd64/Latest/FreeBSD-12.1-RELEASE-amd64.raw.xz"
})

Webapp.Repo.insert!(%Webapp.Distributions.Distribution{
  name: "Fedora",
  version: "31",
  loader: "uefi-csm",
  image:
    "https://download.fedoraproject.org/pub/fedora/linux/releases/31/Cloud/x86_64/images/Fedora-Cloud-Base-31-1.9.x86_64.qcow2"
})

Webapp.Repo.insert!(%Webapp.Distributions.Distribution{
  name: "CentOS",
  version: "8",
  loader: "uefi-csm",
  image:
    "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"
})
Webapp.Repo.insert!(%Webapp.Distributions.Distribution{
  name: "Debian",
  version: "9",
  loader: "grub",
  image: "https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2"
})

Webapp.Repo.insert!(%Webapp.Distributions.Distribution{
  name: "Debian",
  version: "10",
  loader: "grub",
  image: "https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2"
})

for region <- ~w(Europe Asia America) do
  Webapp.Repo.insert!(%Webapp.Regions.Region{name: region})
end

if File.exists?("priv/repo/seeds.local.exs") do
  Code.require_file("priv/repo/seeds.local.exs")
end
