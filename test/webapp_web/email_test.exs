defmodule WebappWeb.Emails.UserEmailTest do
  use ExUnit.Case
  use Bamboo.Test

  import WebappWeb.AuthCase
  alias WebappWeb.Emails.UserEmail, as: Email

  setup do
    email = "deirdre@example.com"
    {:ok, %{email: email, key: gen_key(email)}}
  end

  test "sends confirmation request email", %{email: email, key: key} do
    {:ok, sent_email} = Email.confirm_request(email, key)
    assert sent_email.subject =~ "Confirm your account"
    assert sent_email.html_body =~ "user/confirm?key="
    assert_delivered_email(sent_email)
  end

  test "sends no user found message for password reset attempt" do
    {:ok, sent_email} = Email.reset_request("gladys@example.com", nil)
    assert sent_email.html_body =~ "but no user is associated with the email you provided"
  end

  test "sends reset password request email", %{email: email, key: key} do
    {:ok, sent_email} = Email.reset_request(email, key)
    assert sent_email.subject =~ "Reset your password"
    assert sent_email.html_body =~ "user/password_resets/edit?key="
    assert_delivered_email(sent_email)
  end

  test "sends receipt confirmation email", %{email: email} do
    {:ok, sent_email} = Email.confirm_success(email)
    assert sent_email.html_body =~ "account has been confirmed"
    assert_delivered_email(sent_email)
  end

  test "sends password reset email", %{email: email} do
    {:ok, sent_email} = Email.reset_success(email)
    assert sent_email.html_body =~ "password has been reset"
    assert_delivered_email(sent_email)
  end
end
