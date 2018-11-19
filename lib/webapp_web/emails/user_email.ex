defmodule WebappWeb.Emails.UserEmail do
  @moduledoc """
  A module for sending emails to the user.

  This module provides functions to be used with the Phauxth authentication
  library when confirming users or handling password resets. It uses
  Bamboo, with the LocalAdapter, which is a good development tool.
  For tests, it uses a test adapter, which is configured in the
  config/test.exs file.

  For production, you will need to setup a different email adapter.

  ## Bamboo with a different adapter

  Bamboo has adapters for Mailgun, Mailjet, Mandrill, Sendgrid, SMTP,
  SparkPost, PostageApp, Postmark and Sendcloud.

  There is also a LocalAdapter, which is great for local development.

  See [Bamboo](https://github.com/thoughtbot/bamboo) for more information.

  ## Other email library

  If you do not want to use Bamboo, follow the instructions below:

  1. Edit this file, using the email library of your choice
  2. Remove the lib/webapp/mailer.ex file
  3. Remove the Bamboo entries in the config/config.exs and config/test.exs files
  4. Remove bamboo from the deps section in the mix.exs file

  """

  import Bamboo.Email
  alias Webapp.Mailer
  use Bamboo.Phoenix, view: WebappWeb.UserView

  @doc """
  An email with a confirmation link in it.
  """
  def confirm_request(address, key) do
    prep_mail(address)
    |> subject("Confirm your account")
    |> assign(:body, "Confirm your email here http://www.example.com/confirm?key=#{key}")
    |> render("email/default.html")
    |> Mailer.deliver_now()
  end

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, nil) do
    prep_mail(address)
    |> subject("Reset your password")
    |> assign(:body, "You requested a password reset, but no user is associated with the email you provided.")
    |> render("email/default.html")
    |> Mailer.deliver_now()
  end

  def reset_request(address, key) do
    prep_mail(address)
    |> subject("Reset your password")
    |> assign(:body, "Reset your password at http://www.example.com/password_resets/edit?key=#{key}")
    |> render("email/default.html")
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def confirm_success(address) do
    prep_mail(address)
    |> subject("Confirmed account")
    |> assign(:body, "Your account has been confirmed.")
    |> render("email/default.html")
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address) do
    prep_mail(address)
    |> subject("Password reset")
    |> assign(:body, "Your password has been reset.")
    |> render("email/default.html")
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    new_email()
    |> to(address)
    |> from("admin@example.com")
    |> put_html_layout({WebappWeb.LayoutView, "email.html"})
  end
end
