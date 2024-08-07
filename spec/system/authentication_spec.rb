# frozen_string_literal: true

require "spec_helper"

describe "Authentication", type: :system do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    context "when using email and password" do
      it "creates a new User" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter

          find("*[type=submit]").click
        end

        expect(page).to have_content("A message with a code has been sent to your email address. ")
      end
    end

    context "when using another langage" do
      before do
        within_language_menu do
          click_link "Français"
        end
      end

      it "keeps the locale settings" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter

          find("*[type=submit]").click
        end

        expect(page).to have_content("Vous devriez recevoir un code à 4 chiffres")
        expect(last_user.locale).to eq("fr")
      end
    end

    context "when being a robot" do
      it "denies the sign up" do
        find(".sign-up-link").click

        within ".new_user" do
          page.execute_script("$($('.new_user > div > input')[0]).val('Ima robot :D')")
          fill_in :registration_user_email, with: "user@example.org"
          fill_in :registration_user_name, with: "Responsible Citizen"
          fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
          check :registration_user_tos_agreement
          check :registration_user_newsletter

          find("*[type=submit]").click
        end

        expect(page).not_to have_content("confirmation link")
      end
    end

    context "when sign up is disabled" do
      let(:organization) { create(:organization, users_registration_mode: :existing) }

      it "redirects to the sign in when accessing the sign up page" do
        visit decidim.new_user_registration_path
        expect(page).not_to have_content("Sign Up")
      end

      it "don't allow the user to sign up" do
        find(".sign-in-link").click
        expect(page).not_to have_content("Create an account")
      end
    end
  end

  describe "Confirm email" do
    it "confirms the user" do
      perform_enqueued_jobs { create(:user, organization: organization) }

      visit last_email_link

      expect(page).to have_content("You need to confirm your email address")
      expect(last_user).not_to be_confirmed
    end
  end

  context "when confirming the account" do
    let!(:user) { create(:user, organization: organization) }

    before do
      perform_enqueued_jobs { user.confirm }
      switch_to_host(user.organization.host)
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "sends a welcome notification" do
      find("a.topbar__notifications").click

      within "#notifications" do
        expect(page).to have_content("Welcome")
        expect(page).to have_content("thanks for joining #{organization.name}")
      end

      expect(last_email_body).to include("thanks for joining #{organization.name}")
    end
  end

  describe "Resend confirmation instructions" do
    let(:user) do
      perform_enqueued_jobs { create(:user, organization: organization) }
    end

    it "sends an email with the instructions" do
      visit decidim.new_user_confirmation_path

      within ".new_user" do
        fill_in :confirmation_user_email, with: user.email
        perform_enqueued_jobs { find("*[type=submit]").click }
      end

      expect(emails.count).to eq(2)
      expect(page).to have_content("You should receive a 4 digit code at #{user.email}")
    end
  end

  context "when a user is already registered" do
    let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL", organization: organization) }

    describe "Sign in" do
      it "authenticates an existing User" do
        find(".sign-in-link").click

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Signed in successfully")
        expect(page).to have_content(user.name)
      end
    end

    describe "Forgot password" do
      it "sends a password recovery email" do
        visit decidim.new_user_password_path

        within ".new_user" do
          fill_in :password_user_email, with: user.email
          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        expect(page).to have_content("If your email address exists in our database")
        expect(emails.count).to eq(1)
      end

      it "says it sends a password recovery email when is a non-existing email" do
        visit decidim.new_user_password_path

        within ".new_user" do
          fill_in :password_user_email, with: "nonexistent@example.org"
          find("*[type=submit]").click
        end

        expect(page).to have_content("If your email address exists in our database")
      end
    end

    describe "Reset password" do
      before do
        perform_enqueued_jobs { user.send_reset_password_instructions }
      end

      it "sets a new password for the user" do
        visit last_email_link

        within ".new_user" do
          fill_in :password_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("Your password has been successfully changed")
        expect(page).to have_current_path "/"
      end

      it "enforces rules when setting a new password for the user" do
        visit last_email_link

        within ".new_user" do
          fill_in :password_user_password, with: "whatislove"
          find("*[type=submit]").click
        end

        expect(page).to have_content("10 characters minimum")
        expect(page).to have_content("must be different from your nickname and your email")
        expect(page).to have_content("must not be too common")
        expect(page).to have_current_path %r{/users/password}
      end

      it "enforces the minimum length for the password in the front-end" do
        visit last_email_link

        within ".new_user" do
          fill_in :password_user_password, with: "example"
          find("*[type=submit]").click
        end

        expect(page).to have_content("is too short")
        expect(page).not_to have_content("Password confirmation must match the password.")
      end
    end

    describe "Sign Out" do
      before do
        ### MANUAL SIGN IN TO FIX ISSUE WITH METHOD `login_as` ###
        find(".sign-in-link").click

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end
      end

      it "signs out the user" do
        within_user_menu do
          find(".sign-out-link").click
        end

        expect(page).to have_content("Signed out successfully.")
        expect(page).to have_no_content(user.name)
      end
    end

    context "with lockable account" do
      Devise.maximum_attempts = 3
      let!(:maximum_attempts) { Devise.maximum_attempts }

      describe "when attempting to login with failing password" do
        describe "before locking" do
          before do
            visit decidim.root_path
            find(".sign-in-link").click

            (maximum_attempts - 2).times do
              within ".new_user" do
                fill_in :session_user_email, with: user.email
                fill_in :session_user_password, with: "not-the-pasword"
                find("*[type=submit]").click
              end
            end
          end

          it "doesn't show the last attempt warning before locking the account" do
            within ".new_user" do
              fill_in :session_user_email, with: user.email
              fill_in :session_user_password, with: "not-the-pasword"
              find("*[type=submit]").click
            end

            expect(page).to have_content("Invalid")
          end
        end

        describe "locks the account" do
          before do
            visit decidim.root_path
            find(".sign-in-link").click

            (maximum_attempts - 1).times do
              within ".new_user" do
                fill_in :session_user_email, with: user.email
                fill_in :session_user_password, with: "not-the-pasword"
                find("*[type=submit]").click
              end
            end
          end

          it "when reached maximum failed attempts" do
            within ".new_user" do
              fill_in :session_user_email, with: user.email
              fill_in :session_user_password, with: "not-the-pasword"
              perform_enqueued_jobs { find("*[type=submit]").click }
            end

            expect(page).to have_content("Invalid")
            expect(emails.count).to eq(1)
          end
        end
      end

      describe "Resend unlock instructions email" do
        before do
          user.lock_access!

          visit decidim.new_user_unlock_path
        end

        it "resends the unlock instructions" do
          within ".new_user" do
            fill_in :unlock_user_email, with: user.email
            perform_enqueued_jobs { find("*[type=submit]").click }
          end

          expect(page).to have_content("If your account exists")
          expect(emails.count).to eq(1)
        end

        it "says it resends the unlock instructions when is a non-existing user account" do
          within ".new_user" do
            fill_in :unlock_user_email, with: user.email
            find("*[type=submit]").click
          end

          expect(page).to have_content("If your account exists")
        end
      end

      describe "Unlock account" do
        before do
          user.lock_access!
          perform_enqueued_jobs { user.send_unlock_instructions }
        end

        it "unlocks the user account" do
          visit last_email_link

          expect(page).to have_content("Your account has been successfully unlocked. Please sign in to continue")
        end
      end
    end
  end

  context "when a user is already registered in another organization with the same email" do
    let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL") }

    describe "Sign Up" do
      context "when using the same email" do
        it "creates a new User" do
          find(".sign-up-link").click

          within ".new_user" do
            fill_in :registration_user_email, with: user.email
            fill_in :registration_user_name, with: "Responsible Citizen"
            fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
            check :registration_user_tos_agreement
            check :registration_user_newsletter

            find("*[type=submit]").click
          end

          expect(page).to have_content("A message with a code has been sent to your email address.")
        end
      end
    end
  end

  context "when a user with the same email is already registered in another organization" do
    let(:organization2) { create(:organization) }

    let!(:user2) { create(:user, :confirmed, email: "fake@user.com", name: "Wrong user", organization: organization2, password: "DfyvHn425mYAy2HL") }
    let!(:user) { create(:user, :confirmed, email: "fake@user.com", name: "Right user", organization: organization, password: "DfyvHn425mYAy2HL") }

    describe "Sign in" do
      it "authenticates the right user" do
        find(".sign-in-link").click

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Right user")
      end
    end
  end
end
