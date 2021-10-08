namespace :data do
  namespace :studio do
    namespace :digest do
      desc 'Refresh materialized view for application digests'
      task refresh: :environment do
        ActiveRecord::Base.connection.execute 'REFRESH MATERIALIZED VIEW application_digests'
      end
    end
  end
end
