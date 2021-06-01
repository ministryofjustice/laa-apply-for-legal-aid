guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(scss|js|html|haml))).*}) { |m| "/assets/#{m[3]}" }
end

guard :rspec, cmd: 'bundle exec rspec', all_on_start: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^app/controllers/(.+)\.rb$}) { |m| "spec/requests/#{m[1]}_spec.rb".gsub(/_controller/, '') }
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/interfaces/api/(.+)\.rb$}) { |m| "spec/api/#{m[1]}_spec.rb" }
end

guard :rubocop, all_on_start: false do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.(rubocop|rubocop_todo)\.yml$}) { |m| File.dirname(m[0]) }
end

guard :cucumber, cmd: 'bundle exec cucumber --publish-quiet', notification: false, all_on_start: false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }

  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || 'features'
  end
end
