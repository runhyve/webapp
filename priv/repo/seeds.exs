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
Webapp.Repo.insert!(%Webapp.Plans.Plan{name: "1C-512MB-30HDD", ram: 512, storage: 30, cpu: 1})
Webapp.Repo.insert!(%Webapp.Plans.Plan{name: "1C-1024MB-50HDD", ram: 1024, storage: 50, cpu: 1})
Webapp.Repo.insert!(%Webapp.Plans.Plan{name: "2C-2048MB-100HDD", ram: 2048, storage: 100, cpu: 2})

Webapp.Repo.insert!(%Webapp.Distributions.Distribution{name: "Ubuntu", version: "16.04", loader: "grub", image: "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-uefi1.img"})
Webapp.Repo.insert!(%Webapp.Distributions.Distribution{name: "Ubuntu", version: "18.04", loader: "grub", image: "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"})
Webapp.Repo.insert!(%Webapp.Distributions.Distribution{name: "FreeBSD", version: "12.0", loader: "bhyveload", image: "http://ftp.icm.edu.pl/pub/FreeBSD/releases/VM-IMAGES/12.0-RELEASE/amd64/Latest/FreeBSD-12.0-RELEASE-amd64.raw.xz"})
Webapp.Repo.insert!(%Webapp.Distributions.Distribution{name: "Fedora", version: "29", loader: "grub-fedora", image: "https://download.fedoraproject.org/pub/fedora/linux/releases/29/Cloud/x86_64/images/Fedora-Cloud-Base-29-1.2.x86_64.raw.xz"})
Webapp.Repo.insert!(%Webapp.Distributions.Distribution{name: "Debian", version: "9", loader: "grub", image: "https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2"})
