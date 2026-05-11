require "rails_helper"

RSpec.describe EntraIdToken do
  describe "encrypted sensitive attributes" do
    %i[
      access_token
      refresh_token
      id_token
      scope
    ].each do |attribute|
      it "encrypts #{attribute}" do
        token = create(:entra_id_token, attribute => "secret")

        raw = described_class.connection.select_value(<<~SQL.squish)
          SELECT #{attribute}
          FROM entra_id_tokens
          WHERE id = '#{token.id}'
        SQL

        expect(raw).not_to eq("secret")
        expect(token.reload.public_send(attribute)).to eq("secret")
      end
    end
  end

  describe "#store!" do
    context "when credentials from OAuthHash are provided on first time login" do
      let(:entra_id_token) do
        build(:entra_id_token, access_token: nil, access_token_expires_at: nil, refresh_token: nil, id_token: nil, scope: nil)
      end

      # Note the use of `token`` not `access_token` which mimics real behaviour of OmniAuth::AuthHash
      let(:credentials) do
        OmniAuth::AuthHash.new(
          {
            token: "a_fake_access_token",
            expires_in: 3666,
            refresh_token: "a_fake_refresh_token",
            id_token: "a_fake_id_token",
            scope: "fake_scope1 fake_scope2",
          },
        )
      end

      it "updates the token object with new token details" do
        expect { entra_id_token.store!(credentials:) }
          .to change { entra_id_token.slice("id_token", "access_token", "refresh_token", "scope") }
            .from(
              "id_token" => nil,
              "access_token" => nil,
              "refresh_token" => nil,
              "scope" => nil,
            )
            .to(
              "id_token" => "a_fake_id_token",
              "access_token" => "a_fake_access_token",
              "refresh_token" => "a_fake_refresh_token",
              "scope" => "fake_scope1 fake_scope2",
            )
          .and change(entra_id_token, :access_token_expires_at)
            .from(nil)
            .to(a_value > Time.current)
      end
    end

    context "when credentials from a refresh token response are provided" do
      let(:entra_id_token) { create(:entra_id_token, access_token_expires_at: 1.minute.ago) }

      let(:credentials) do
        instance_double(Datastore::TokenResponse,
                        access_token: "new_fake_access_token",
                        expires_in: 3666,
                        refresh_token: "new_fake_refresh_token",
                        id_token: "new_fake_id_token",
                        scope: "new_fake_scope")
      end

      it "updates the token object with new token details" do
        expect { entra_id_token.store!(credentials:) }
          .to change { entra_id_token.reload.slice("id_token", "access_token", "refresh_token", "scope") }
            .from(
              "id_token" => "fake_id_token",
              "access_token" => "fake_access_token",
              "refresh_token" => "fake_refresh_token",
              "scope" => "fake_scope1 fake_scope2",
            )
            .to(
              "id_token" => "new_fake_id_token",
              "access_token" => "new_fake_access_token",
              "refresh_token" => "new_fake_refresh_token",
              "scope" => "new_fake_scope",
            )
          .and change { entra_id_token.reload.access_token_expires_at }
            .from(a_value < Time.current)
            .to(a_value > Time.current)
      end

      context "when expires_in is not provided" do
        let(:credentials) do
          instance_double(Datastore::TokenResponse,
                          access_token: "new_fake_access_token",
                          expires_in: nil,
                          refresh_token: "new_fake_refresh_token",
                          id_token: "new_fake_id_token",
                          scope: "new_fake_scope")
        end

        it "defaults access_token_expires_at to 1 hour from now" do
          freeze_time do
            expect { entra_id_token.store!(credentials:) }
              .to change { entra_id_token.reload.access_token_expires_at }
                .from(a_value < Time.current)
                .to(a_value == 1.hour.from_now)
          end
        end
      end
    end
  end
end
