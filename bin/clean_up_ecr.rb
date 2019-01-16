require 'json'

repo = 'laa-apply-for-legal-aid/applyforlegalaid-service'
delete_if_older_than = 30 # days

json_output = `aws ecr describe-images --repository-name #{repo} --output json`
images = JSON.parse(json_output)['imageDetails']

images_to_delete = []
images.each do |i|
  date_pushed = DateTime.strptime(i['imagePushedAt'].to_s, '%s')
  age_in_days = (DateTime.now - date_pushed).to_i
  images_to_delete << i if age_in_days > delete_if_older_than
end

puts "There are #{images_to_delete.size} images that will be deleted. Is that okay?"
input = STDIN.gets.strip
exit 5 unless input =~ /^y/i

images_to_delete.each_slice(100) do |batch|
  image_ids = batch.map { |i| "imageDigest=#{i['imageDigest']}" }.join(' ')
  puts `aws ecr batch-delete-image --repository-name #{repo} --image-ids #{image_ids}`
end

puts 'Done!'
