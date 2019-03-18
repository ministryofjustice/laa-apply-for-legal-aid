#!/usr/bin/env ruby

if ARGV.empty?
  puts "Specify one of the following pod names to SSH into. "
  pipe = IO.popen("kubectl get pods")
  results = pipe.readlines
  pipe.close

  pods = results.select{ |line| line !~ /-postgres/ }
  pods.each do | line |
    puts line
  end
  exit
end

command = "kubectl exec -c apply-for-legal-aid-uat --stdin --tty --namespace laa-apply-for-legalaid-uat #{ARGV[0]} -- /bin/bash"
puts "Executing command: #{command}"
puts " "
system command



